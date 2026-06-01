import { Direction, TileType } from '../map/TileType';
import { TANK_SIZE, TILE_SIZE, COLORS, SCREEN_WIDTH } from '../common/Constants';
import { GameMap } from '../map/GameMap';
import { ImageManager } from '../utils/ImageManager';

/**
 * 坦克基类 - 图片渲染版
 */
export class Tank {
  x: number;
  y: number;
  size: number = TANK_SIZE;
  direction: Direction = Direction.UP;
  speed: number = 1.5;
  color: string = COLORS.YELLOW;
  isAlive: boolean = true;
  
  private static imageManager: ImageManager | null = null;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
    
    if (!Tank.imageManager) {
      Tank.imageManager = ImageManager.getInstance();
    }
  }

  move(gameMap: GameMap, newDirection?: Direction, otherTanks?: Tank[]): boolean {
    if (newDirection) {
      switch (newDirection) {
        case Direction.UP_LEFT:
        case Direction.UP_RIGHT:
          this.direction = Direction.UP;
          break;
        case Direction.DOWN_LEFT:
        case Direction.DOWN_RIGHT:
          this.direction = Direction.DOWN;
          break;
        default:
          this.direction = newDirection;
          break;
      }
    }

    let newX = this.x;
    let newY = this.y;

    switch (this.direction) {
      case Direction.UP:
        newY -= this.speed;
        break;
      case Direction.DOWN:
        newY += this.speed;
        break;
      case Direction.LEFT:
        newX -= this.speed;
        break;
      case Direction.RIGHT:
        newX += this.speed;
        break;
    }

    if (newX < 0 || newX + this.size > SCREEN_WIDTH || newY < 0 || newY + this.size > SCREEN_WIDTH) {
      return false;
    }

    const canEnter = gameMap.canTankEnter(newX, newY, this.size);
    if (!canEnter) {
      return false;
    }

    if (otherTanks && this.wouldCollideWithTanks(newX, newY, otherTanks)) {
      return false;
    }

    this.x = newX;
    this.y = newY;
    return true;
  }

  wouldCollideWithTanks(newX: number, newY: number, otherTanks: Tank[]): boolean {
    const len = otherTanks.length;
    for (let i = 0; i < len; i++) {
      const tank = otherTanks[i];
      if (tank === this || !tank.isAlive) continue;
      
      if (newX < tank.x + tank.size &&
          newX + this.size > tank.x &&
          newY < tank.y + tank.size &&
          newY + this.size > tank.y) {
        return true;
      }
    }
    return false;
  }

  render(ctx: CanvasRenderingContext2D, offsetY: number): void {
    if (!this.isAlive) return;

    const tankY = this.y + offsetY;
    const imageManager = Tank.imageManager || ImageManager.getInstance();
    
    // 尝试使用图片渲染
    let tankImage: ImageBitmap | null = null;
    if (this.isEnemy) {
      tankImage = imageManager.getEnemyTankImage();
    } else {
      tankImage = imageManager.getPlayerTankImage();
    }
    
    if (tankImage) {
      // 使用图片渲染
      ctx.save();
      ctx.translate(this.x + this.size / 2, tankY + this.size / 2);
      
      // 根据方向旋转
      let rotation = 0;
      switch (this.direction) {
        case Direction.UP: rotation = 0; break;
        case Direction.RIGHT: rotation = Math.PI / 2; break;
        case Direction.DOWN: rotation = Math.PI; break;
        case Direction.LEFT: rotation = -Math.PI / 2; break;
      }
      ctx.rotate(rotation);
      
      ctx.drawImage(tankImage, -this.size / 2, -this.size / 2, this.size, this.size);
      ctx.restore();
    } else {
      // 备用：使用颜色渲染
      this.renderWithColor(ctx, tankY);
    }
  }
  
  private renderWithColor(ctx: CanvasRenderingContext2D, tankY: number): void {
    // 坦克主体
    ctx.fillStyle = this.color;
    ctx.fillRect(this.x, tankY, this.size, this.size);
    
    // 炮管
    ctx.fillStyle = this.isEnemy ? '#404040' : '#DAA520';
    const barrelWidth = this.size * 0.25;
    const barrelLength = this.size * 0.5;
    
    switch (this.direction) {
      case Direction.UP:
        ctx.fillRect(this.x + this.size / 2 - barrelWidth / 2, tankY - barrelLength + this.size / 2, barrelWidth, barrelLength);
        break;
      case Direction.DOWN:
        ctx.fillRect(this.x + this.size / 2 - barrelWidth / 2, tankY + this.size / 2, barrelWidth, barrelLength);
        break;
      case Direction.LEFT:
        ctx.fillRect(this.x - barrelLength + this.size / 2, tankY + this.size / 2 - barrelWidth / 2, barrelLength, barrelWidth);
        break;
      case Direction.RIGHT:
        ctx.fillRect(this.x + this.size / 2, tankY + this.size / 2 - barrelWidth / 2, barrelLength, barrelWidth);
        break;
    }
    
    // 履带装饰
    ctx.fillStyle = this.isEnemy ? '#303030' : '#B8860B';
    const trackWidth = this.size * 0.15;
    ctx.fillRect(this.x, tankY, trackWidth, this.size);
    ctx.fillRect(this.x + this.size - trackWidth, tankY, trackWidth, this.size);
  }
  
  get isEnemy(): boolean {
    return false;
  }
  
  get tankType(): number {
    return 1;
  }
}
