import { COLORS } from '../common/Constants';

/**
 * 爆炸效果类
 */
export class Explosion {
  x: number;
  y: number;
  size: number;
  frame: number = 0;
  maxFrames: number = 10; // 爆炸持续帧数
  isAlive: boolean = true;

  constructor(x: number, y: number, size: number) {
    this.x = x;
    this.y = y;
    this.size = size;
  }

  /**
   * 更新爆炸效果
   */
  update(): void {
    this.frame++;
    if (this.frame >= this.maxFrames) {
      this.isAlive = false;
    }
  }

  /**
   * 渲染爆炸效果
   */
  render(ctx: CanvasRenderingContext2D, offsetY: number): void {
    if (!this.isAlive) return;

    ctx.save();

    // 根据帧数改变颜色和大小，模拟爆炸效果
    const progress = this.frame / this.maxFrames;
    const currentSize = this.size * (1 + progress * 0.5);
    const offset = (currentSize - this.size) / 2;

    // 外层爆炸
    ctx.fillStyle = `rgba(255, ${Math.floor(100 * (1 - progress))}, 0, ${1 - progress})`;
    ctx.fillRect(this.x - offset, this.y + offsetY - offset, currentSize, currentSize);

    // 内层爆炸
    if (progress < 0.5) {
      ctx.fillStyle = `rgba(255, 255, 0, ${1 - progress * 2})`;
      const innerSize = currentSize * 0.6;
      const innerOffset = (currentSize - innerSize) / 2;
      ctx.fillRect(this.x - innerOffset, this.y + offsetY - innerOffset, innerSize, innerSize);
    }

    ctx.restore();
  }
}
