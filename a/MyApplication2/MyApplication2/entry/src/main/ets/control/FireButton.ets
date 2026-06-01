/**
 * 发射按钮控制器
 */
export class FireButton {
  // 按钮位置
  centerX: number = 0;
  centerY: number = 0;
  
  // 按钮半径
  radius: number = 45;
  
  // 是否正在按下
  isPressed: boolean = false;
  
  // 是否已触发（防止连发）
  hasTriggered: boolean = false;

  /**
   * 处理触摸开始
   */
  onTouchStart(x: number, y: number): boolean {
    const distance = Math.sqrt((x - this.centerX) ** 2 + (y - this.centerY) ** 2);
    
    console.info(`[FireButton] onTouchStart: x=${x}, y=${y}, center=(${this.centerX}, ${this.centerY})`);
    console.info(`[FireButton] Distance: ${distance.toFixed(1)}, Radius: ${this.radius}`);
    
    if (distance <= this.radius) {
      this.isPressed = true;
      this.hasTriggered = false;
      console.info(`[FireButton] Button PRESSED!`);
      return true;
    }
    
    console.info(`[FireButton] Button NOT pressed (outside radius)`);
    return false;
  }

  /**
   * 处理触摸移动
   */
  onTouchMove(x: number, y: number): void {
    if (!this.isPressed) return;
    
    const distance = Math.sqrt((x - this.centerX) ** 2 + (y - this.centerY) ** 2);
    const wasPressed = this.isPressed;
    this.isPressed = distance <= this.radius;
    
    console.info(`[FireButton] onTouchMove: distance=${distance.toFixed(1)}, isPressed=${this.isPressed}`);
  }

  /**
   * 处理触摸结束
   */
  onTouchEnd(): boolean {
    const wasTriggered = this.hasTriggered;
    this.isPressed = false;
    this.hasTriggered = false;
    return wasTriggered;
  }

  /**
   * 标记为已触发
   */
  markTriggered(): void {
    this.hasTriggered = true;
  }

  /**
   * 获取触发状态
   */
  shouldFire(): boolean {
    return this.isPressed && !this.hasTriggered;
  }

  /**
   * 绘制按钮
   */
  draw(canvas: CanvasRenderingContext2D): void {
    // 绘制按钮底座（像素风格）
    if (this.isPressed) {
      canvas.fillStyle = '#FFD700';
    } else {
      canvas.fillStyle = '#3A3A5A';
    }
    
    canvas.beginPath();
    canvas.arc(this.centerX, this.centerY, this.radius, 0, Math.PI * 2);
    canvas.fill();
    
    // 绘制边框
    canvas.strokeStyle = this.isPressed ? '#FFA500' : '#5A5A7A';
    canvas.lineWidth = 4;
    canvas.stroke();
    
    // 绘制内部圆形（像素风格）
    if (this.isPressed) {
      canvas.fillStyle = '#FFA500';
    } else {
      canvas.fillStyle = '#2A2A4A';
    }
    
    canvas.beginPath();
    canvas.arc(this.centerX, this.centerY, this.radius * 0.75, 0, Math.PI * 2);
    canvas.fill();
    
    // 绘制内圆边框
    canvas.strokeStyle = this.isPressed ? '#FF8C00' : '#4A4A6A';
    canvas.lineWidth = 3;
    canvas.stroke();
    
    // 绘制中心圆（增加立体感）
    if (!this.isPressed) {
      canvas.fillStyle = '#1A1A2E';
      canvas.beginPath();
      canvas.arc(this.centerX, this.centerY, this.radius * 0.5, 0, Math.PI * 2);
      canvas.fill();
      
      canvas.strokeStyle = '#3A3A5A';
      canvas.lineWidth = 2;
      canvas.stroke();
    }
    
    // 绘制文字
    canvas.fillStyle = this.isPressed ? '#000000' : '#FFFFFF';
    canvas.font = 'bold 20px monospace';
    canvas.textAlign = 'center';
    canvas.textBaseline = 'middle';
    canvas.fillText('FIRE', this.centerX, this.centerY);
  }
}
