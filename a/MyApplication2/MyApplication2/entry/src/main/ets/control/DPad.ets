import { Direction } from '../map/TileType';

/**
 * 按钮位置接口
 */
interface ButtonPosition {
  x: number;
  y: number;
}

/**
 * 方向键控制器（D-Pad）
 * 十字形布局：上、下、左、右四个按钮
 */
export class DPad {
  // 中心点位置
  centerX: number = 0;
  centerY: number = 0;
  
  // 按钮半径（增大检测范围）
  buttonRadius: number = 40;
  
  // 按钮间距
  buttonSpacing: number = 50;
  
  // 当前按下的方向
  pressedDirection: Direction | null = null;
  
  // 各按钮的按下状态
  upPressed: boolean = false;
  downPressed: boolean = false;
  leftPressed: boolean = false;
  rightPressed: boolean = false;

  /**
   * 获取各按钮的位置
   */
  getButtonPositions(): Map<string, ButtonPosition> {
    const positions = new Map<string, ButtonPosition>();
    
    // 上按钮
    positions.set('up', {x: this.centerX, y: this.centerY - this.buttonSpacing});
    
    // 下按钮
    positions.set('down', {x: this.centerX, y: this.centerY + this.buttonSpacing});
    
    // 左按钮
    positions.set('left', {x: this.centerX - this.buttonSpacing, y: this.centerY});
    
    // 右按钮
    positions.set('right', {x: this.centerX + this.buttonSpacing, y: this.centerY});
    
    return positions;
  }

  /**
   * 处理触摸开始
   */
  onTouchStart(x: number, y: number): Direction | null {
    console.info(`[DPad] onTouchStart: x=${x}, y=${y}, center=(${this.centerX}, ${this.centerY})`);
    const positions = this.getButtonPositions();
    
    // 检查是否点击了某个按钮
    for (const entry of positions.entries()) {
      const key = entry[0];
      const pos = entry[1];
      const distance = Math.sqrt((x - pos.x) ** 2 + (y - pos.y) ** 2);
      
      console.info(`[DPad] Checking button ${key}: pos=(${pos.x}, ${pos.y}), distance=${distance}, radius=${this.buttonRadius}`);
      
      if (distance <= this.buttonRadius) {
        this.updatePressState(key, true);
        console.info(`[DPad] Button ${key} PRESSED, direction=${this.pressedDirection}`);
        return this.pressedDirection;
      }
    }
    
    console.info(`[DPad] No button pressed`);
    return null;
  }

  /**
   * 处理触摸移动
   */
  onTouchMove(x: number, y: number): Direction | null {
    const positions = this.getButtonPositions();
    
    // 检查当前触摸点在哪个按钮上
    for (const entry of positions.entries()) {
      const key = entry[0];
      const pos = entry[1];
      const distance = Math.sqrt((x - pos.x) ** 2 + (y - pos.y) ** 2);
      
      if (distance <= this.buttonRadius) {
        this.updatePressState(key, true);
        console.info(`[DPad] onTouchMove: detected button ${key}, direction=${this.pressedDirection}`);
        return this.pressedDirection;
      }
    }
    
    // 如果不在任何按钮上，保持当前按下的状态不变（不重置）
    console.info(`[DPad] onTouchMove: not on any button, keeping current direction=${this.pressedDirection}`);
    return this.pressedDirection;
  }

  /**
   * 处理触摸结束
   */
  onTouchEnd(): void {
    this.upPressed = false;
    this.downPressed = false;
    this.leftPressed = false;
    this.rightPressed = false;
    this.pressedDirection = null;
  }

  /**
   * 更新按钮按下状态
   */
  private updatePressState(buttonKey: string, pressed: boolean): void {
    switch (buttonKey) {
      case 'up':
        this.upPressed = pressed;
        if (pressed) {
          this.pressedDirection = Direction.UP;
        }
        break;
      case 'down':
        this.downPressed = pressed;
        if (pressed) {
          this.pressedDirection = Direction.DOWN;
        }
        break;
      case 'left':
        this.leftPressed = pressed;
        if (pressed) {
          this.pressedDirection = Direction.LEFT;
        }
        break;
      case 'right':
        this.rightPressed = pressed;
        if (pressed) {
          this.pressedDirection = Direction.RIGHT;
        }
        break;
    }
    
    // 如果没有按钮被按下，清除方向
    if (!this.upPressed && !this.downPressed && 
        !this.leftPressed && !this.rightPressed) {
      this.pressedDirection = null;
    }
  }

  /**
   * 绘制方向键
   */
  draw(canvas: CanvasRenderingContext2D): void {
    const positions = this.getButtonPositions();
    
    // 绘制中心圆（像素风格）
    canvas.fillStyle = '#2A2A4A';
    canvas.beginPath();
    canvas.arc(this.centerX, this.centerY, 28, 0, Math.PI * 2);
    canvas.fill();
    
    // 绘制中心圆边框
    canvas.strokeStyle = '#4A4A6A';
    canvas.lineWidth = 3;
    canvas.stroke();
    
    // 绘制四个方向的按钮
    for (const entry of positions.entries()) {
      const key = entry[0];
      const pos = entry[1];
      let isPressed = false;
      let label = '';
      
      switch (key) {
        case 'up':
          isPressed = this.upPressed;
          label = '▲';
          break;
        case 'down':
          isPressed = this.downPressed;
          label = '▼';
          break;
        case 'left':
          isPressed = this.leftPressed;
          label = '◀';
          break;
        case 'right':
          isPressed = this.rightPressed;
          label = '▶';
          break;
      }
      
      // 绘制按钮背景（像素风格）
      if (isPressed) {
        // 按下状态 - 亮黄色
        canvas.fillStyle = '#FFD700';
      } else {
        // 正常状态 - 深色
        canvas.fillStyle = '#3A3A5A';
      }
      
      canvas.beginPath();
      canvas.arc(pos.x, pos.y, this.buttonRadius, 0, Math.PI * 2);
      canvas.fill();
      
      // 绘制边框
      canvas.strokeStyle = isPressed ? '#FFA500' : '#5A5A7A';
      canvas.lineWidth = 4;
      canvas.stroke();
      
      // 绘制内圈（增加立体感）
      if (!isPressed) {
        canvas.fillStyle = '#2A2A4A';
        canvas.beginPath();
        canvas.arc(pos.x, pos.y, this.buttonRadius - 8, 0, Math.PI * 2);
        canvas.fill();
        
        canvas.strokeStyle = '#4A4A6A';
        canvas.lineWidth = 2;
        canvas.stroke();
      }
      
      // 绘制箭头文字
      canvas.fillStyle = isPressed ? '#000000' : '#FFFFFF';
      canvas.font = 'bold 28px monospace';
      canvas.textAlign = 'center';
      canvas.textBaseline = 'middle';
      canvas.fillText(label, pos.x, pos.y);
    }
  }
}
