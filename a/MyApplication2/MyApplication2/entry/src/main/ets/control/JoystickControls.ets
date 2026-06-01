import { Direction } from '../map/TileType';
import { VirtualJoystick } from './VirtualJoystick';
import { FireButton } from './FireButton';

/**
 * 摇杆控制组件 - 性能优化版
 * - 移除定时器，直接在触摸事件中处理
 * - 优化触摸响应
 * - 减少Canvas绘制
 */
@Component
export struct JoystickControls {
  // 方向回调
  onDirectionChange?: (direction: Direction | null) => void;
  // 发射回调
  onFire?: () => void;
  
  // 摇杆和发射按钮
  private joystick: VirtualJoystick = new VirtualJoystick();
  private fireButton: FireButton = new FireButton();
  
  // Canvas上下文
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  // 是否已初始化
  @State isInitialized: boolean = false;
  
  aboutToAppear(): void {
    // 设置摇杆参数 - 高灵敏度
    this.joystick.radius = 70;
    this.joystick.deadZone = 3; // 极小死区，超高灵敏度
    
    // 设置发射按钮参数
    this.fireButton.radius = 45;
  }
  
  build() {
    Stack() {
      // Canvas绘制摇杆和发射按钮
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.initializeControls();
        })
        .onTouch((event: TouchEvent) => {
          this.handleTouch(event);
        })
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 初始化控制器位置
   */
  private initializeControls(): void {
    // 获取Canvas尺寸
    const width = this.canvasContext.width;
    const height = this.canvasContext.height;
    
    // 设置摇杆位置（左侧）
    this.joystick.centerX = width * 0.25;
    this.joystick.centerY = height * 0.5;
    
    // 设置发射按钮位置（右侧）
    this.fireButton.centerX = width * 0.75;
    this.fireButton.centerY = height * 0.5;
    
    this.isInitialized = true;
    
    // 初始绘制
    this.draw();
  }
  
  /**
   * 处理触摸事件（优化版）
   */
  private handleTouch(event: TouchEvent): void {
    if (!this.isInitialized) return;
    
    const touch = event.touches[0];
    const x = touch.x;
    const y = touch.y;
    
    if (event.type === TouchType.Down) {
      // 检查是否触摸了发射按钮
      if (this.fireButton.onTouchStart(x, y)) {
        // 触发射击
        if (this.onFire) {
          this.onFire();
        }
        this.fireButton.markTriggered();
      } else {
        // 扩大摇杆检测范围
        const joystickDist = Math.sqrt(
          (x - this.joystick.centerX) ** 2 + 
          (y - this.joystick.centerY) ** 2
        );
        
        // 扩大检测范围到2.5倍半径
        if (joystickDist <= this.joystick.radius * 2.5) {
          this.joystick.onTouchStart(x, y);
          const direction = this.joystick.onTouchMove(x, y);
          if (direction && this.onDirectionChange) {
            this.onDirectionChange(direction);
          }
        }
      }
    } else if (event.type === TouchType.Move) {
      // 处理移动
      if (this.fireButton.isPressed) {
        this.fireButton.onTouchMove(x, y);
      } else if (this.joystick.isTouching) {
        const direction = this.joystick.onTouchMove(x, y);
        if (this.onDirectionChange) {
          this.onDirectionChange(direction);
        }
      }
    } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      // 处理释放
      if (this.fireButton.isPressed) {
        this.fireButton.onTouchEnd();
      }
      
      if (this.joystick.isTouching) {
        this.joystick.onTouchEnd();
        if (this.onDirectionChange) {
          this.onDirectionChange(null);
        }
      }
    }
    
    // 重新绘制
    this.draw();
  }
  
  /**
   * 绘制摇杆和发射按钮
   */
  private draw(): void {
    if (!this.isInitialized) return;
    
    // 清空画布
    this.canvasContext.clearRect(0, 0, this.canvasContext.width, this.canvasContext.height);
    
    // 绘制摇杆
    this.joystick.draw(this.canvasContext, 0, 0);
    
    // 绘制发射按钮
    this.fireButton.draw(this.canvasContext);
  }
}
