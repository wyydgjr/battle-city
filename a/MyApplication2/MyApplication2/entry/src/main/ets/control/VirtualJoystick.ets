import { Direction } from '../map/TileType';

/**
 * 虚拟摇杆类 - 性能优化版
 * - 移除所有日志输出
 * - 优化方向计算
 * - 简化逻辑
 */
export class VirtualJoystick {
  // 摇杆中心位置
  centerX: number = 0;
  centerY: number = 0;
  
  // 摇杆半径和死区
  radius: number = 60;
  deadZone: number = 5;
  
  // 触摸状态
  isTouching: boolean = false;
  private touchX: number = 0;
  private touchY: number = 0;
  
  // 当前方向
  private currentDirection: Direction | null = null;

  /**
   * 处理触摸开始
   */
  onTouchStart(x: number, y: number): void {
    this.isTouching = true;
    this.touchX = x;
    this.touchY = y;
  }

  /**
   * 处理触摸移动（优化版）
   */
  onTouchMove(x: number, y: number): Direction | null {
    if (!this.isTouching) {
      return null;
    }

    this.touchX = x;
    this.touchY = y;

    const deltaX = this.touchX - this.centerX;
    const deltaY = this.touchY - this.centerY;
    const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);

    // 在死区内不响应
    if (distance < this.deadZone) {
      return this.currentDirection;
    }

    // 计算角度
    const angle = Math.atan2(deltaY, deltaX);
    const degrees = angle * 180 / Math.PI;
    
    // 简化方向映射（4方向）
    let newDirection: Direction | null = null;
    
    if (degrees >= -45 && degrees < 45) {
      newDirection = Direction.RIGHT;
    } else if (degrees >= 45 && degrees < 135) {
      newDirection = Direction.DOWN;
    } else if (degrees >= -135 && degrees < -45) {
      newDirection = Direction.UP;
    } else {
      newDirection = Direction.LEFT;
    }
    
    if (newDirection !== this.currentDirection) {
      this.currentDirection = newDirection;
    }

    return this.currentDirection;
  }

  /**
   * 处理触摸结束
   */
  onTouchEnd(): void {
    this.isTouching = false;
    this.currentDirection = null;
  }

  /**
   * 获取当前方向
   */
  getDirection(): Direction | null {
    return this.currentDirection;
  }

  /**
   * 绘制摇杆（优化版）
   */
  draw(canvas: CanvasRenderingContext2D, offsetX: number, offsetY: number): void {
    // 绘制摇杆底座
    canvas.strokeStyle = '#6A6A8A';
    canvas.lineWidth = 3;
    canvas.beginPath();
    canvas.arc(this.centerX, this.centerY, this.radius, 0, Math.PI * 2);
    canvas.stroke();

    // 绘制摇杆中心圆
    if (this.isTouching) {
      // 限制摇杆圆在底座内
      const deltaX = this.touchX - this.centerX;
      const deltaY = this.touchY - this.centerY;
      const distance = Math.sqrt(deltaX * deltaX + deltaY * deltaY);
      
      let knobX = this.touchX;
      let knobY = this.touchY;
      
      if (distance > this.radius) {
        const ratio = this.radius / distance;
        knobX = this.centerX + deltaX * ratio;
        knobY = this.centerY + deltaY * ratio;
      }
      
      // 绘制摇杆圆（按下状态）
      canvas.fillStyle = '#FFFFFF';
      canvas.beginPath();
      canvas.arc(knobX, knobY, 25, 0, Math.PI * 2);
      canvas.fill();
      
      // 绘制方向指示
      if (this.currentDirection) {
        canvas.fillStyle = '#FFD700';
        canvas.beginPath();
        canvas.arc(knobX, knobY, 15, 0, Math.PI * 2);
        canvas.fill();
      }
    } else {
      // 绘制摇杆圆（默认状态）
      canvas.fillStyle = '#AAAAAA';
      canvas.beginPath();
      canvas.arc(this.centerX, this.centerY, 25, 0, Math.PI * 2);
      canvas.fill();
    }
  }
}
