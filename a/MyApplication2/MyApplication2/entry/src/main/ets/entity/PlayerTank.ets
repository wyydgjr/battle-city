import { Tank } from './Tank';
import { Direction } from '../map/TileType';
import { COLORS } from '../common/Constants';
import { Bullet } from './Bullet';
import { GameMap } from '../map/GameMap';
import { SoundManager } from '../audio/SoundManager';

/**
 * 玩家坦克类 - 性能优化版
 */
export class PlayerTank extends Tank {
  lives: number = 3;
  score: number = 0;
  private bullets: Bullet[] = [];
  private lastShootTime: number = 0;
  private shootCooldown: number = 400; // 射击冷却
  private currentMoveDirection: Direction | null = null;

  constructor(x: number, y: number) {
    super(x, y);
    this.color = COLORS.YELLOW;
    this.speed = 2.0; // 移动速度
  }

  setMoveDirection(direction: Direction | null): void {
    this.currentMoveDirection = direction;
    if (direction) {
      this.direction = direction;
    }
  }

  update(gameMap: GameMap, otherTanks?: Tank[]): void {
    if (this.currentMoveDirection && this.isAlive) {
      this.move(gameMap, this.currentMoveDirection, otherTanks);
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

    const bullet = new Bullet(bulletX, bulletY, this.direction, 'player');
    this.bullets.push(bullet);
    this.lastShootTime = currentTime;
    
    SoundManager.getInstance().playShootSound();

    return bullet;
  }

  updateBullets(gameMap: GameMap): void {
    this.bullets = this.bullets.filter(b => b.isAlive);
    
    const len = this.bullets.length;
    for (let i = 0; i < len; i++) {
      this.bullets[i].update(gameMap);
    }
  }

  getBullets(): Bullet[] {
    return this.bullets.filter(b => b.isAlive);
  }
  
  clearBullets(): void {
    this.bullets = [];
  }
}
