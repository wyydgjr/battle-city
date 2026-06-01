import { Direction, TileType } from '../map/TileType';
import { COLORS, SCREEN_WIDTH, GAME_AREA_HEIGHT, TILE_SIZE, MAP_GRID_COUNT } from '../common/Constants';
import { GameMap } from '../map/GameMap';
import { Tank } from '../entity/Tank';
import { SoundManager } from '../audio/SoundManager';
import { ImageManager } from '../utils/ImageManager';

/**
 * 子弹类 - 精确碰撞版（路径检测）
 */
export class Bullet {
  x: number;
  y: number;
  size: number = 8; // 增加子弹大小
  direction: Direction;
  speed: number = 6; // 降低子弹速度
  isAlive: boolean = true;
  owner: 'player' | 'enemy';

  constructor(x: number, y: number, direction: Direction, owner: 'player' | 'enemy') {
    this.x = x;
    this.y = y;
    this.direction = direction;
    this.owner = owner;
  }

  update(gameMap: GameMap): void {
    if (!this.isAlive) return;

    // 保存移动前的位置
    const prevX = this.x;
    const prevY = this.y;

    // 移动子弹
    switch (this.direction) {
      case Direction.UP:
        this.y -= this.speed;
        break;
      case Direction.DOWN:
        this.y += this.speed;
        break;
      case Direction.LEFT:
        this.x -= this.speed;
        break;
      case Direction.RIGHT:
        this.x += this.speed;
        break;
    }

    // 边界检测
    if (this.x < 0 || this.x > SCREEN_WIDTH || 
        this.y < 0 || this.y > GAME_AREA_HEIGHT) {
      this.isAlive = false;
      return;
    }

    // 检测路径上的碰撞（从prev到current）
    this.checkPathCollision(gameMap, prevX, prevY, this.x, this.y);
  }

  /**
   * 检测子弹路径上的碰撞（找到第一个障碍物）
   */
  private checkPathCollision(gameMap: GameMap, fromX: number, fromY: number, toX: number, toY: number): void {
    // 沿着子弹路径，逐步检测每个格子
    const distance = Math.sqrt((toX - fromX) ** 2 + (toY - fromY) ** 2);
    const steps = Math.ceil(distance / (TILE_SIZE / 4)); // 每步检测1/4格子
    
    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const checkX = fromX + (toX - fromX) * t;
      const checkY = fromY + (toY - fromY) * t;
      
      // 检查这个位置所在的格子
      const col = Math.floor(checkX / TILE_SIZE);
      const row = Math.floor(checkY / TILE_SIZE);
      
      if (col < 0 || col >= MAP_GRID_COUNT || row < 0 || row >= MAP_GRID_COUNT) {
        continue;
      }
      
      const tile = gameMap.getTile(col, row);
      if (!tile) continue;
      
      // 检测到障碍物，立即处理并停止
      if (tile.type === TileType.BRICK) {
        // 计算子弹进入格子的方向
        const enterDir = this.getEnterDirection(fromX, fromY, col, row);
        
        // 破坏墙壁
        gameMap.damageBrick(col, row, enterDir);
        
        // 将子弹位置设置到碰撞点
        this.x = checkX;
        this.y = checkY;
        this.isAlive = false;
        
        SoundManager.getInstance().playHitBrickSound();
        return;
      }
      
      if (tile.type === TileType.STEEL) {
        this.x = checkX;
        this.y = checkY;
        this.isAlive = false;
        SoundManager.getInstance().playHitBrickSound();
        return;
      }
      
      if (tile.type === TileType.EAGLE) {
        console.info('[Bullet] 基地被击中！Game Over!');
        this.x = checkX;
        this.y = checkY;
        this.isAlive = false;
        gameMap.destroyEagle();
        return;
      }
    }
  }

  /**
   * 获取子弹进入格子的方向
   */
  private getEnterDirection(fromX: number, fromY: number, col: number, row: number): Direction {
    const tileCenterX = col * TILE_SIZE + TILE_SIZE / 2;
    const tileCenterY = row * TILE_SIZE + TILE_SIZE / 2;
    
    const dx = fromX - tileCenterX;
    const dy = fromY - tileCenterY;
    
    // 判断子弹从哪个方向进入格子
    if (Math.abs(dx) > Math.abs(dy)) {
      // 水平方向为主
      return dx > 0 ? Direction.RIGHT : Direction.LEFT;
    } else {
      // 垂直方向为主
      return dy > 0 ? Direction.DOWN : Direction.UP;
    }
  }

  /**
   * 检测与坦克的碰撞（使用路径检测）
   */
  checkTankCollision(tanks: Tank[]): Tank | null {
    if (!this.isAlive) return null;

    for (const tank of tanks) {
      if (!tank.isAlive) continue;

      // AABB碰撞检测
      if (this.x < tank.x + tank.size &&
          this.x + this.size > tank.x &&
          this.y < tank.y + tank.size &&
          this.y + this.size > tank.y) {
        
        if ((this.owner === 'player' && tank.constructor.name === 'EnemyTank') ||
            (this.owner === 'enemy' && tank.constructor.name === 'PlayerTank')) {
          this.isAlive = false;
          return tank;
        }
      }
    }

    return null;
  }

  /**
   * 检测路径上与坦克的碰撞
   */
  checkPathTankCollision(tanks: Tank[], fromX: number, fromY: number, toX: number, toY: number): Tank | null {
    if (!this.isAlive) return null;

    const distance = Math.sqrt((toX - fromX) ** 2 + (toY - fromY) ** 2);
    const steps = Math.ceil(distance / 2); // 每2像素检测一次
    
    for (let i = 0; i <= steps; i++) {
      const t = i / steps;
      const checkX = fromX + (toX - fromX) * t;
      const checkY = fromY + (toY - fromY) * t;
      
      for (const tank of tanks) {
        if (!tank.isAlive) continue;
        
        // AABB碰撞检测
        if (checkX < tank.x + tank.size &&
            checkX + this.size > tank.x &&
            checkY < tank.y + tank.size &&
            checkY + this.size > tank.y) {
          
          if ((this.owner === 'player' && tank.constructor.name === 'EnemyTank') ||
              (this.owner === 'enemy' && tank.constructor.name === 'PlayerTank')) {
            this.x = checkX;
            this.y = checkY;
            this.isAlive = false;
            return tank;
          }
        }
      }
    }

    return null;
  }

  render(ctx: CanvasRenderingContext2D, offsetY: number): void {
    if (!this.isAlive) return;

    const imageManager = ImageManager.getInstance();
    const bulletImage = imageManager.getBulletImage();
    
    if (bulletImage) {
      ctx.drawImage(bulletImage, this.x, this.y + offsetY, this.size, this.size);
    } else {
      // 备用：使用颜色渲染
      ctx.fillStyle = this.owner === 'player' ? '#FFD700' : '#FFFFFF';
      ctx.fillRect(this.x, this.y + offsetY, this.size, this.size);
    }
  }
}
