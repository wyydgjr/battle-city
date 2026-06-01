import { Tank } from './Tank';
import { Direction } from '../map/TileType';
import { COLORS } from '../common/Constants';
import { GameMap } from '../map/GameMap';
import { Bullet } from './Bullet';

/**
 * 敌方坦克类 - 性能优化版
 */
export class EnemyTank extends Tank {
  private moveTimer: number = 0;
  private moveInterval: number = 240; // AI决策间隔（帧数）- 进一步增加
  private bullets: Bullet[] = [];
  private lastShootTime: number = 0;
  private shootCooldown: number = 3000; // 射击冷却（毫秒）- 进一步增加
  private stuckCounter: number = 0;
  private lastX: number = 0;
  private lastY: number = 0;
  
  private _tankType: number = 1;

  constructor(x: number, y: number, tankType: number = 1) {
    super(x, y);
    this.color = COLORS.GRAY;
    this.speed = 0.5; // 进一步降低速度
    const directions = [Direction.UP, Direction.DOWN, Direction.LEFT, Direction.RIGHT];
    this.direction = directions[Math.floor(Math.random() * 4)];
    this.lastX = x;
    this.lastY = y;
    this._tankType = tankType;
  }
  
  override get isEnemy(): boolean {
    return true;
  }
  
  override get tankType(): number {
    return this._tankType;
  }

  updateAI(gameMap: GameMap, otherTanks?: Tank[], playerTank?: Tank): void {
    this.moveTimer++;

    // AI决策（每240帧决策一次）
    if (this.moveTimer >= this.moveInterval) {
      this.moveTimer = 0;
      
      // 简化决策：15%概率朝向玩家，85%随机
      if (playerTank && playerTank.isAlive && Math.random() < 0.15) {
        const dx = playerTank.x - this.x;
        const dy = playerTank.y - this.y;
        
        if (Math.abs(dx) > Math.abs(dy)) {
          this.direction = dx > 0 ? Direction.RIGHT : Direction.LEFT;
        } else {
          this.direction = dy > 0 ? Direction.DOWN : Direction.UP;
        }
      } else {
        this.changeDirection();
      }
    }

    // 尝试移动
    const moved = this.move(gameMap, undefined, otherTanks);
    
    // 简化卡住检测（只在移动时检测）
    if (moved) {
      if (Math.abs(this.x - this.lastX) < 0.1 && Math.abs(this.y - this.lastY) < 0.1) {
        this.stuckCounter++;
        if (this.stuckCounter > 8) { // 进一步增加卡住阈值
          this.changeDirection();
          this.stuckCounter = 0;
        }
      } else {
        this.stuckCounter = 0;
      }
      this.lastX = this.x;
      this.lastY = this.y;
    }

    // 射击逻辑
    this.tryShoot();
  }

  private tryShoot(): void {
    const currentTime = Date.now();
    
    // 射击冷却检查
    if (currentTime - this.lastShootTime < this.shootCooldown) {
      return;
    }
    
    // 检查是否已有活跃子弹（限制每个敌方最多1颗子弹）
    let activeBulletCount = 0;
    const len = this.bullets.length;
    for (let i = 0; i < len; i++) {
      if (this.bullets[i].isAlive) {
        activeBulletCount++;
        if (activeBulletCount >= 1) {
          return;
        }
      }
    }

    // 8%概率射击（进一步降低射击频率）
    if (Math.random() < 0.08) {
      this.shoot();
    }
  }

  shoot(): Bullet | null {
    const currentTime = Date.now();
    
    if (currentTime - this.lastShootTime < this.shootCooldown) {
      return null;
    }
    
    const len = this.bullets.length;
    for (let i = 0; i < len; i++) {
      if (this.bullets[i].isAlive) {
        return null;
      }
    }

    let bulletX = this.x + this.size / 2 - 2;
    let bulletY = this.y + this.size / 2 - 2;

    switch (this.direction) {
      case Direction.UP:
        bulletY = this.y - 4;
        break;
      case Direction.DOWN:
        bulletY = this.y + this.size;
        break;
      case Direction.LEFT:
        bulletX = this.x - 4;
        break;
      case Direction.RIGHT:
        bulletX = this.x + this.size;
        break;
    }

    const bullet = new Bullet(bulletX, bulletY, this.direction, 'enemy');
    this.bullets.push(bullet);
    this.lastShootTime = currentTime;

    return bullet;
  }

  updateBullets(gameMap: GameMap): void {
    // 清理死亡子弹
    this.bullets = this.bullets.filter(b => b.isAlive);
    
    const len = this.bullets.length;
    for (let i = 0; i < len; i++) {
      this.bullets[i].update(gameMap);
    }
  }

  getBullets(): Bullet[] {
    return this.bullets.filter(b => b.isAlive);
  }

  private changeDirection(): void {
    const directions = [Direction.UP, Direction.DOWN, Direction.LEFT, Direction.RIGHT];
    this.direction = directions[Math.floor(Math.random() * 4)];
  }
}
