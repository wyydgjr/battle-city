import { SCREEN_WIDTH, SCREEN_HEIGHT } from '../common/Constants';

@Entry
@Component
struct TestCanvasPage {
  // 直接创建Canvas上下文，不依赖onReady
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  aboutToAppear(): void {
    console.info('TestCanvasPage aboutToAppear');
    // 延迟绘制，确保UI已渲染
    setTimeout(() => this.drawTest(), 100);
  }

  drawTest(): void {
    console.info('TestCanvasPage: drawTest called');
    
    try {
      // 清空画布
      this.context.fillStyle = '#000000';
      this.context.fillRect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
      console.info('Cleared canvas');
      
      // 绘制大红色矩形
      this.context.fillStyle = '#FF0000';
      this.context.fillRect(50, 100, 260, 200);
      console.info('Drawn red rectangle at (50, 100, 260, 200)');
      
      // 绘制大蓝色矩形
      this.context.fillStyle = '#0000FF';
      this.context.fillRect(80, 130, 200, 140);
      console.info('Drawn blue rectangle at (80, 130, 200, 140)');
      
      // 绘制黄色文字
      this.context.fillStyle = '#FFD700';
      this.context.font = 'bold 24px sans-serif';
      this.context.textAlign = 'center';
      this.context.fillText('Canvas 工作正常！', 180, 80);
      console.info('Drawn text');
      
      console.info('TestCanvasPage: Drawing completed successfully');
    } catch (error) {
      console.error('TestCanvasPage: Drawing error - ' + JSON.stringify(error));
    }
  }

  build() {
    Stack() {
      Canvas(this.context)
        .width(SCREEN_WIDTH)
        .height(SCREEN_HEIGHT)
        .backgroundColor('#000000')
    }
    .width(SCREEN_WIDTH)
    .height(SCREEN_HEIGHT)
  }
}
