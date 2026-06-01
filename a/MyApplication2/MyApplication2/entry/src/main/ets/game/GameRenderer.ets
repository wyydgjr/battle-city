import { SCREEN_WIDTH, GAME_AREA_HEIGHT, MAP_GRID_COUNT, TILE_SIZE, COLORS } from '../common/Constants';
import { GameMap } from '../map/GameMap';
import { Tank } from '../entity/Tank';
import { Bullet } from '../entity/Bullet';
import { Explosion } from '../entity/Explosion';
import { PlayerTank } from '../entity/PlayerTank';
import { EnemyTank } from '../entity/EnemyTank';
import { Direction, TileType } from '../map/TileType';
import { ImageManager } from '../utils/ImageManager';
import { SoundManager } from '../audio/SoundManager';

/**
 * 游戏渲染器 - 性能优化版（20FPS）
 */
export class GameRenderer {
  private canvas: CanvasRenderingContext2D | null = null;
  private gameMap: GameMap | null = null;
  private tanks: Tank[] = [];
  private bullets: Bullet[] = [];
  private explosions: Explosion[] = [];
  private isRunning: boolean = false;
  private frameCount: number = 0;
  private renderInterval: number = -1;
  
  private offsetY: number = 0;
  private imageManager: ImageManager | null = null;
  
  private onScoreChange?: (score: number) => void;
  private onLivesChange?: (lives: number) => void;
  
  // 性能优化：缓存
  private playerTank: PlayerTank | null = null;
  private lastCleanupFrame: number = 0;
  
  // 子弹数量限制
  private static readonly MAX_BULLETS: number = 30;

  init(canvasContext: CanvasRenderingContext2D, gameMap: GameMap): void {
    this.canvas = canvasContext;
    this.gameMap = gameMap;
    this.imageManager = ImageManager.getInstance();
    
    this.canvas.imageSmoothingEnabled = false;
    
    const battlefieldSize = TILE_SIZE * MAP_GRID_COUNT;
    this.offsetY = (GAME_AREA_HEIGHT - battlefieldSize) / 2;
  }

  setOnScoreChange(callback: (score: number) => void): void {
    this.onScoreChange = callback;
  }

  setOnLivesChange(callback: (lives: number) => void): void {
    this.onLivesChange = callback;
  }

  /**
   * 启动渲染循环（60FPS）
   */
  start(): void {
    if (this.isRunning) return;
    if (!this.canvas) return;
    
    this.isRunning = true;
    this.frameCount = 0;
    
    SoundManager.getInstance().startBGM();
    SoundManager.getInstance().playLevelStartSound();
    
    // 20fps（50ms）- 低帧率高流畅
    this.renderInterval = setInterval(() => {
      if (!this.isRunning || !this.canvas) return;
      
      this.frameCount++;
      this.update();
      this.render();
    }, 50);
  }

  stop(): void {
    this.isRunning = false;
    if (this.renderInterval !== -1) {
      clearInterval(this.renderInterval);
      this.renderInterval = -1;
    }
    SoundManager.getInstance().stopBGM();
  }

  /**
   * 清理所有对象（关卡切换时调用）
   */
  clear(): void {
    this.bullets = [];
    this.explosions = [];
    this.tanks = [];
    this.playerTank = null;
    this.frameCount = 0;
  }

  private update(): void {
    if (!this.gameMap) return;

    // 清理死亡对象（每20帧，约1秒）
    if (this.frameCount - this.lastCleanupFrame >= 20) {
      this.lastCleanupFrame = this.frameCount;
      this.bullets = this.bullets.filter(b => b.isAlive);
      this.explosions = this.explosions.filter(e => e.isAlive);
      // 限制子弹数量
      if (this.bullets.length > GameRenderer.MAX_BULLETS) {
        this.bullets = this.bullets.slice(-GameRenderer.MAX_BULLETS);
      }
    }

    // 更新玩家坦克（每帧）
    if (this.playerTank && this.playerTank.isAlive) {
      this.playerTank.update(this.gameMap, this.tanks);
      this.playerTank.updateBullets(this.gameMap);
      
      // 同步子弹列表（只添加新子弹）
      const playerBullets = this.playerTank.getBullets();
      const pLen = playerBullets.length;
      for (let i = 0; i < pLen; i++) {
        const bullet = playerBullets[i];
        if (!this.bullets.includes(bullet)) {
          this.bullets.push(bullet);
        }
      }
    }

    // 更新敌方坦克（每2帧）
    if (this.frameCount % 2 === 0) {
      const tanksLen = this.tanks.length;
      for (let i = 0; i < tanksLen; i++) {
        const tank = this.tanks[i];
        if (tank instanceof EnemyTank && tank.isAlive) {
          const enemyTank = tank as EnemyTank;
          enemyTank.updateAI(this.gameMap, this.tanks, this.playerTank || undefined);
          enemyTank.updateBullets(this.gameMap);
          
          // 同步子弹列表
          const enemyBullets = enemyTank.getBullets();
          const eLen = enemyBullets.length;
          for (let j = 0; j < eLen; j++) {
            const bullet = enemyBullets[j];
            if (!this.bullets.includes(bullet)) {
              this.bullets.push(bullet);
            }
          }
        }
      }
    }

    // 更新子弹（每帧）
    const bulletsLen = this.bullets.length;
    for (let i = 0; i < bulletsLen; i++) {
      const bullet = this.bullets[i];
      if (bullet.isAlive) {
        bullet.update(this.gameMap);
      }
    }

    // 更新爆炸效果（每帧）
    const explosionsLen = this.explosions.length;
    for (let i = 0; i < explosionsLen; i++) {
      const explosion = this.explosions[i];
      if (explosion.isAlive) {
        explosion.update();
      }
    }

    // 碰撞检测（每帧）- 确保不漏检
    this.checkBulletTankCollisions();
    
    // 检查基地是否被摧毁
    if (this.gameMap && this.gameMap.isEagleDestroyed) {
      SoundManager.getInstance().playGameOverSound();
      this.stop();
    }
  }

  /**
   * 精确碰撞检测（每帧执行）
   */
  private checkBulletTankCollisions(): void {
    const bulletsLen = this.bullets.length;
    const tanksLen = this.tanks.length;
    
    for (let i = 0; i < bulletsLen; i++) {
      const bullet = this.bullets[i];
      if (!bullet.isAlive) continue;
      
      for (let j = 0; j < tanksLen; j++) {
        const tank = this.tanks[j];
        if (!tank.isAlive) continue;
        
        // 扩大碰撞范围（子弹大小的一半）
        const collisionRange = bullet.size / 2;
        
        // AABB碰撞检测（扩大范围）
        if (bullet.x < tank.x + tank.size + collisionRange &&
            bullet.x + bullet.size > tank.x - collisionRange &&
            bullet.y < tank.y + tank.size + collisionRange &&
            bullet.y + bullet.size > tank.y - collisionRange) {
          
          const isPlayerBullet = bullet.owner === 'player';
          const isEnemyTank = tank instanceof EnemyTank;
          
          if ((isPlayerBullet && isEnemyTank) || (!isPlayerBullet && tank instanceof PlayerTank)) {
            bullet.isAlive = false;
            tank.isAlive = false;
            
            this.explosions.push(new Explosion(tank.x, tank.y, tank.size));
            
            if (isPlayerBullet && isEnemyTank) {
              SoundManager.getInstance().playHitEnemySound();
              if (this.onScoreChange) {
                this.onScoreChange(100);
              }
            } else if (!isPlayerBullet && tank instanceof PlayerTank) {
              SoundManager.getInstance().playHitPlayerSound();
              const player = tank as PlayerTank;
              player.lives--;
              if (this.onLivesChange) {
                this.onLivesChange(player.lives);
              }
              if (player.lives > 0) {
                tank.isAlive = true;
              }
            }
            break; // 子弹已消失，跳出内层循环
          }
        }
      }
    }
  }

  private render(): void {
    if (!this.canvas || !this.gameMap) return;
    
    // 清空画布
    this.canvas.clearRect(0, 0, SCREEN_WIDTH, GAME_AREA_HEIGHT);
    
    // 渲染地图
    this.gameMap.render(this.canvas, this.offsetY);
    
    // 渲染坦克
    const tanksLen = this.tanks.length;
    for (let i = 0; i < tanksLen; i++) {
      const tank = this.tanks[i];
      if (tank.isAlive) {
        tank.render(this.canvas, this.offsetY);
      }
    }
    
    // 渲染子弹
    const bulletsLen = this.bullets.length;
    for (let i = 0; i < bulletsLen; i++) {
      const bullet = this.bullets[i];
      if (bullet.isAlive) {
        bullet.render(this.canvas, this.offsetY);
      }
    }
    
    // 渲染爆炸效果
    const explosionsLen = this.explosions.length;
    for (let i = 0; i < explosionsLen; i++) {
      const explosion = this.explosions[i];
      if (explosion.isAlive) {
        explosion.render(this.canvas, this.offsetY);
      }
    }
  }

  addTank(tank: Tank): void {
    this.tanks.push(tank);
    
    // 缓存玩家坦克引用
    if (tank instanceof PlayerTank) {
      this.playerTank = tank as PlayerTank;
    }
  }

  addBullet(bullet: Bullet): void {
    this.bullets.push(bullet);
  }

  getTanks(): Tank[] {
    return this.tanks;
  }

  getBullets(): Bullet[] {
    return this.bullets;
  }
}
