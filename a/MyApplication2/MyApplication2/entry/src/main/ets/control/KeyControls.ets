import { Direction } from '../map/TileType';

/**
 * 按键控制组件
 * 使用ArkUI Button组件实现方向键和发射按钮
 */
@Component
export struct KeyControls {
  // 方向回调
  onDirectionChange?: (direction: Direction | null) => void;
  // 发射回调
  onFire?: () => void;
  
  // 当前按下的按键
  @State upPressed: boolean = false;
  @State downPressed: boolean = false;
  @State leftPressed: boolean = false;
  @State rightPressed: boolean = false;
  @State firePressed: boolean = false;
  
  // 按键样式参数
  private buttonSize: number = 56;
  private fireButtonSize: number = 70;
  
  build() {
    Row() {
      // 左侧：方向键区域
      Column() {
        // 上方向键
        this.DirectionButton('▲', this.upPressed, () => {
          this.handleDirectionPress(Direction.UP);
        }, () => {
          this.handleDirectionRelease();
        })
        
        // 左右方向键行
        Row() {
          this.DirectionButton('◀', this.leftPressed, () => {
            this.handleDirectionPress(Direction.LEFT);
          }, () => {
            this.handleDirectionRelease();
          })
          
          // 中间空白
          Column()
            .width(this.buttonSize + 10)
            .height(this.buttonSize)
          
          this.DirectionButton('▶', this.rightPressed, () => {
            this.handleDirectionPress(Direction.RIGHT);
          }, () => {
            this.handleDirectionRelease();
          })
        }
        .margin({ top: 5, bottom: 5 })
        
        // 下方向键
        this.DirectionButton('▼', this.downPressed, () => {
          this.handleDirectionPress(Direction.DOWN);
        }, () => {
          this.handleDirectionRelease();
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      
      // 右侧：发射按钮区域
      Column() {
        // 发射按钮
        Column() {
          Text('FIRE')
            .fontSize(18)
            .fontColor(this.firePressed ? '#000000' : '#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .fontFamily('monospace')
        }
        .width(this.fireButtonSize)
        .height(this.fireButtonSize)
        .borderRadius(this.fireButtonSize / 2)
        .backgroundColor(this.firePressed ? '#FFD700' : '#3A3A5A')
        .border({
          width: 4,
          color: this.firePressed ? '#FFA500' : '#5A5A7A'
        })
        .shadow({
          radius: this.firePressed ? 4 : 8,
          color: '#000000',
          offsetX: 2,
          offsetY: 2
        })
        .justifyContent(FlexAlign.Center)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            // 先触发回调，减少延迟
            if (this.onFire) {
              this.onFire();
            }
            // 再更新状态（用于视觉反馈）
            this.firePressed = true;
          } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
            this.firePressed = false;
          }
        })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 方向按钮构建器
   */
  @Builder
  DirectionButton(
    label: string,
    isPressed: boolean,
    onPress: () => void,
    onRelease: () => void
  ) {
    Column() {
      Text(label)
        .fontSize(24)
        .fontColor(isPressed ? '#000000' : '#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .fontFamily('monospace')
    }
    .width(this.buttonSize)
    .height(this.buttonSize)
    .borderRadius(8)
    .backgroundColor(isPressed ? '#FFD700' : '#3A3A5A')
    .border({
      width: 3,
      color: isPressed ? '#FFA500' : '#5A5A7A'
    })
    .shadow({
      radius: isPressed ? 4 : 6,
      color: '#000000',
      offsetX: 2,
      offsetY: 2
    })
    .justifyContent(FlexAlign.Center)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        onPress();
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        onRelease();
      }
    })
  }
  
  /**
   * 处理方向键按下
   */
  private handleDirectionPress(direction: Direction): void {
    // 直接触发回调，减少状态更新延迟
    if (this.onDirectionChange) {
      this.onDirectionChange(direction);
    }
    
    // 更新按下状态（用于视觉反馈）
    switch (direction) {
      case Direction.UP:
        this.upPressed = true;
        break;
      case Direction.DOWN:
        this.downPressed = true;
        break;
      case Direction.LEFT:
        this.leftPressed = true;
        break;
      case Direction.RIGHT:
        this.rightPressed = true;
        break;
    }
  }
  
  /**
   * 处理方向键释放
   */
  private handleDirectionRelease(): void {
    // 直接触发回调，减少状态更新延迟
    if (this.onDirectionChange) {
      this.onDirectionChange(null);
    }
    
    // 重置所有按下状态
    this.upPressed = false;
    this.downPressed = false;
    this.leftPressed = false;
    this.rightPressed = false;
  }
}
