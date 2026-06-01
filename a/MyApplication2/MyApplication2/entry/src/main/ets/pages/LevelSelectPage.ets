import { SCREEN_WIDTH, SCREEN_HEIGHT } from '../common/Constants';

/**
 * 关卡数据接口
 */
export interface LevelData {
  id: number;
  name: string;
  enemyCount: number;
  description: string;
  unlocked: boolean;
}

/**
 * 关卡配置列表
 */
export const LEVELS: LevelData[] = [
  { id: 1, name: '关卡 1', enemyCount: 3, description: '初级训练场', unlocked: true },
  { id: 2, name: '关卡 2', enemyCount: 4, description: '城市巷战', unlocked: true },
  { id: 3, name: '关卡 3', enemyCount: 6, description: '迷宫要塞', unlocked: true },
  { id: 4, name: '关卡 4', enemyCount: 8, description: '沙漠风暴', unlocked: true },
  { id: 5, name: '关卡 5', enemyCount: 11, description: '终极挑战', unlocked: true }
];

/**
 * 关卡选择页面
 */
@Component
export struct LevelSelectPage {
  // 关卡选择回调
  onLevelSelected?: (levelId: number) => void;
  // 返回主页回调
  onReturnToHome?: () => void;
  
  build() {
    Column() {
      // 标题
      Row() {
        Text('选择关卡')
          .fontSize(28)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .letterSpacing(4)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 30, bottom: 20 })
      
      // 关卡列表
      Column({ space: 12 }) {
        ForEach(LEVELS, (level: LevelData) => {
          this.buildLevelCard(level)
        }, (level: LevelData) => level.id.toString())
      }
      .width('90%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)
      .padding({ top: 10 })
      
      // 返回按钮
      Button('返回')
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#666666')
        .borderRadius(4)
        .width(120)
        .height(40)
        .margin({ bottom: 30 })
        .onClick(() => {
          if (this.onReturnToHome) {
            this.onReturnToHome();
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0A0A1E')
  }
  
  /**
   * 构建关卡卡片
   */
  @Builder
  buildLevelCard(level: LevelData) {
    Row() {
      // 关卡编号
      Column() {
        Text(level.id.toString())
          .fontSize(32)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
      }
      .width(60)
      .height(60)
      .backgroundColor('#1A1A3E')
      .borderRadius(8)
      .justifyContent(FlexAlign.Center)
      
      // 关卡信息
      Column() {
        Text(level.name)
          .fontSize(18)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
        
        Text(level.description)
          .fontSize(12)
          .fontColor('#888888')
          .margin({ top: 4 })
        
        // 敌方数量
        Row() {
          Text('敌人: ')
            .fontSize(12)
            .fontColor('#FF6B6B')
          
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], (i: number) => {
            if (i <= level.enemyCount) {
              Column()
                .width(8)
                .height(8)
                .backgroundColor('#FF4444')
                .borderRadius(4)
                .margin({ left: 2 })
            }
          })
        }
        .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 15 })
      
      // 选择箭头
      Text('▶')
        .fontSize(20)
        .fontColor(level.unlocked ? '#4CAF50' : '#666666')
    }
    .width('100%')
    .height(80)
    .backgroundColor('#1A1A2E')
    .borderRadius(8)
    .padding({ left: 15, right: 15 })
    .opacity(level.unlocked ? 1 : 0.5)
    .onClick(() => {
      if (level.unlocked && this.onLevelSelected) {
        this.onLevelSelected(level.id);
      }
    })
  }
}
