import { SCREEN_WIDTH, SCREEN_HEIGHT, INFO_BAR_HEIGHT, GAME_AREA_HEIGHT, CONTROL_AREA_HEIGHT, MENU_BAR_HEIGHT, COLORS } from '../common/Constants';
import { GameRenderer } from '../game/GameRenderer';
import { GameMap } from '../map/GameMap';
import { Tank } from '../entity/Tank';
import { PlayerTank } from '../entity/PlayerTank';
import { EnemyTank } from '../entity/EnemyTank';
import { Bullet } from '../entity/Bullet';
import { Direction } from '../map/TileType';
import { JoystickControls } from '../control/JoystickControls';
import { ImageManager } from '../utils/ImageManager';
import { common } from '@kit.AbilityKit';
import { LEVELS } from './LevelSelectPage';

/**
 * 游戏主页面 - 实现四区基础布局
 */
@Component
export struct GamePage {
  // 开始关卡（从关卡选择页面传入）
  startLevel: number = 1;
  // 返回主页的回调函数
  onReturnToHome?: () => void;
  
  private renderer: GameRenderer = new GameRenderer();
  private gameMap: GameMap = new GameMap();
  private playerTank: PlayerTank | null = null;
  private enemyTanks: EnemyTank[] = [];
  // 直接创建Canvas上下文，不依赖onReady
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  
  // 游戏状态
  @State score: number = 0;
  @State lives: number = 3;
  @State currentLevel: number = 1;
  
  // 积分榜：记录每关得分
  @State levelScores: Map<number, number> = new Map<number, number>();
  @State totalScore: number = 0;
  @State showScoreBoard: boolean = false;

  aboutToAppear(): void {
    console.info(`GamePage aboutToAppear, startLevel: ${this.startLevel}`);
    
    // 初始化图片资源管理器
    try {
      const context = getContext(this) as common.UIAbilityContext;
      ImageManager.getInstance().setContext(context);
      ImageManager.getInstance().init();
    } catch (e) {
      console.error('[GamePage] ImageManager init failed:', e);
    }
    
    // 设置当前关卡
    this.currentLevel = this.startLevel;
    
    // 加载关卡地图
    this.gameMap.loadLevel(this.startLevel);
    
    // 获取关卡配置
    const levelConfig = LEVELS.find(l => l.id === this.startLevel);
    const enemyCount = levelConfig ? levelConfig.enemyCount : 3;
    
    // 创建玩家坦克（底部中央，确保在空地上）
    this.playerTank = new PlayerTank(170, 280);
    console.info(`PlayerTank created at (${this.playerTank.x}, ${this.playerTank.y})`);
    
    // 根据关卡配置创建敌方坦克
    this.createEnemyTanks(enemyCount);
    console.info(`Created ${this.enemyTanks.length} enemy tanks for level ${this.startLevel}`);
    
    // 添加坦克到渲染器
    if (this.playerTank) {
      this.renderer.addTank(this.playerTank!);
    }
    for (const enemy of this.enemyTanks) {
      this.renderer.addTank(enemy);
    }
    
    // 延迟初始化渲染器，确保UI已渲染
    setTimeout(() => {
      this.renderer.init(this.canvasContext, this.gameMap);
      
      // 设置回调函数
      this.renderer.setOnScoreChange((scoreIncrement: number) => {
        this.score += scoreIncrement;
        console.info(`Score updated: ${this.score}`);
        
        // 更新当前关卡得分
        this.levelScores.set(this.currentLevel, this.score);
        
        // 更新总分
        this.updateTotalScore();
      });
      
      this.renderer.setOnLivesChange((lives: number) => {
        this.lives = lives;
        console.info(`Lives updated: ${this.lives}`);
      });
      
      this.renderer.start();
      console.info('Game renderer started');
    }, 100);
  }

  onPageShow(): void {
    console.info('GamePage onPageShow');
    // 重新启动渲染器
    if (this.renderer.getTanks().length > 0) {
      this.renderer.start();
    }
  }
  
  onPageHide(): void {
    // 停止渲染器
    this.renderer.stop();
  }
  
  /**
   * 根据数量创建敌方坦克
   */
  createEnemyTanks(count: number): void {
    this.enemyTanks = [];
    
    // 根据关卡数量创建敌方坦克，分散在顶部区域
    const positions: number[][] = [
      [30, 30],    // 左上
      [170, 30],   // 中上
      [310, 30],   // 右上
      [80, 30],    // 左中
      [260, 30],   // 右中
      [50, 60],    // 左下
      [170, 60],   // 中下
      [290, 60],   // 右下
      [120, 30],   // 中左
      [220, 30],   // 中右
      [100, 60],   // 第二排左
      [240, 60]    // 第二排右
    ];
    
    // 根据数量创建敌方坦克（循环使用不同类型）
    for (let i = 0; i < count && i < positions.length; i++) {
      const x = positions[i][0];
      const y = positions[i][1];
      const tankType = (i % 4) + 1; // 坦克类型1-4循环
      this.enemyTanks.push(new EnemyTank(x, y, tankType));
    }
  }

  /**
   * 重新开始游戏
   */
  restartGame(): void {
    console.info('重新开始游戏');
    
    // 保存当前关卡得分到积分榜
    if (this.score > 0) {
      this.levelScores.set(this.currentLevel, this.score);
      this.updateTotalScore();
    }
    
    // 停止渲染器
    this.renderer.stop();
    
    // 清理渲染器中的所有对象
    this.renderer.clear();
    
    // 重置游戏状态
    this.score = 0;
    this.lives = 3;
    
    // 重新加载当前关卡
    this.gameMap.loadLevel(this.currentLevel);
    this.gameMap.resetEagle();
    
    // 获取关卡配置
    const levelConfig = LEVELS.find(l => l.id === this.currentLevel);
    const enemyCount = levelConfig ? levelConfig.enemyCount : 3;
    
    // 重置玩家坦克位置
    if (this.playerTank) {
      this.playerTank.x = 170;
      this.playerTank.y = 280;
      this.playerTank.isAlive = true;
      this.playerTank.lives = 3;
      this.playerTank.direction = Direction.UP;
      this.playerTank.clearBullets();
    }
    
    // 重新创建敌方坦克
    this.createEnemyTanks(enemyCount);
    
    // 重新添加坦克到渲染器
    if (this.playerTank) {
      this.renderer.addTank(this.playerTank!);
    }
    for (const enemy of this.enemyTanks) {
      this.renderer.addTank(enemy);
    }
    
    // 重新启动渲染器
    this.renderer.start();
    
    console.info(`游戏已重置，敌方数量: ${enemyCount}`);
  }
  
  /**
   * 更新总分
   */
  updateTotalScore(): void {
    let total = 0;
    this.levelScores.forEach((score) => {
      total += score;
    });
    this.totalScore = total;
  }

  /**
   * 返回主页
   */
  returnToHome(): void {
    console.info('返回主页');
    // 停止游戏渲染
    this.renderer.stop();
    
    // 调用回调函数返回主页
    if (this.onReturnToHome) {
      this.onReturnToHome();
    }
  }

  build() {
    Stack() {
      Column() {
        // 1. 顶端信息条 (10% = 78vp)
        this.buildInfoBar()

        // 2. 游戏画面区 (60% = 468vp)
        this.buildGameArea()

        // 3. 操控区 (20% = 156vp)
        this.buildControlArea()

        // 4. 底部菜单栏 (10% = 78vp)
        this.buildMenuBar()
      }
      .width(SCREEN_WIDTH)
      .height(SCREEN_HEIGHT)
      .backgroundColor(COLORS.BLACK)
      
      // 积分榜弹窗（覆盖在游戏界面上方）
      if (this.showScoreBoard) {
        this.buildScoreBoard()
      }
    }
    .width(SCREEN_WIDTH)
    .height(SCREEN_HEIGHT)
  }

  /**
   * 构建顶端信息条
   */
  @Builder
  buildInfoBar() {
    Row() {
      // 左侧：生命值显示（像素风坦克图标）
      Row() {
        // 像素风坦克图标
        Column() {
          Row() {
            Column().width(3).height(3).backgroundColor('#FFD700')
            Column().width(3).height(3).backgroundColor('#000000')
            Column().width(3).height(3).backgroundColor('#FFD700')
          }
          Row() {
            Column().width(3).height(6).backgroundColor('#FFD700')
          }
          Row() {
            Column().width(3).height(3).backgroundColor('#FFD700')
            Column().width(3).height(3).backgroundColor('#FFD700')
            Column().width(3).height(3).backgroundColor('#FFD700')
          }
        }
        .margin({ right: 8 })
        
        Text(`×${this.lives}`)
          .fontSize(20)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .fontFamily('monospace')
      }
      .width(80)
      
      Blank()
      
      // 中间：关卡显示（像素风）
      Column() {
        Text('关卡')
          .fontSize(14)
          .fontColor('#888888')
          .fontWeight(FontWeight.Bold)
          .fontFamily('monospace')
        Text(`${this.currentLevel.toString().padStart(2, '0')}`)
          .fontSize(28)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
          .fontFamily('monospace')
          .textShadow({ radius: 4, color: '#FF6B00', offsetX: 2, offsetY: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      
      Blank()
      
      // 右侧：得分显示（像素风）+ 积分榜按钮
      Column() {
        Row() {
          Text('最高分')
            .fontSize(12)
            .fontColor('#888888')
            .fontWeight(FontWeight.Bold)
            .fontFamily('monospace')
          
          // 积分榜按钮（小图标）
          Text('📊')
            .fontSize(14)
            .margin({ left: 4 })
            .onClick(() => {
              this.showScoreBoard = !this.showScoreBoard;
            })
        }
        
        Text(`${this.score.toString().padStart(6, '0')}`)
          .fontSize(20)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .fontFamily('monospace')
      }
      .alignItems(HorizontalAlign.End)
      .width(110)
    }
    .width(SCREEN_WIDTH)
    .height(INFO_BAR_HEIGHT)
    .linearGradient({
      angle: 180,
      colors: [['#2A2A4A', 0], ['#1A1A2E', 1]]
    })
    .padding({ left: 15, right: 15 })
    .border({ width: { bottom: 2 }, color: { bottom: '#3A3A5A' } })
  }

  /**
   * 构建游戏画面区
   */
  @Builder
  buildGameArea() {
    Stack() {
      // Canvas渲染区域
      Canvas(this.canvasContext)
        .width(SCREEN_WIDTH)
        .height(GAME_AREA_HEIGHT)
        .backgroundColor('#000000')
    }
    .width(SCREEN_WIDTH)
    .height(GAME_AREA_HEIGHT)
  }

  /**
   * 构建操控区 - 使用摇杆控制
   */
  @Builder
  buildControlArea() {
    Stack() {
      // 背景（原版风格渐变）
      Column()
        .width(SCREEN_WIDTH)
        .height(CONTROL_AREA_HEIGHT)
        .linearGradient({
          angle: 180,
          colors: [['#1A1A2E', 0], ['#0A0A1E', 1]]
        })
        .border({ width: { top: 2, bottom: 2 }, color: { top: '#3A3A5A', bottom: '#3A3A5A' } })
        .hitTestBehavior(HitTestMode.None)
      
      // 摇杆控制组件
      JoystickControls({
        onDirectionChange: (direction: Direction | null) => {
          if (this.playerTank) {
            this.playerTank.setMoveDirection(direction);
          }
        },
        onFire: () => {
          if (this.playerTank) {
            const bullet = this.playerTank.shoot();
            if (bullet) {
              this.renderer.addBullet(bullet);
            }
          }
        }
      })
    }
    .width(SCREEN_WIDTH)
    .height(CONTROL_AREA_HEIGHT)
  }

  /**
   * 构建底部菜单栏
   */
  @Builder
  buildMenuBar() {
    Row() {
      // 重新玩按钮（像素风）
      Button('重试')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#4A4A6A')
        .borderRadius(4)
        .border({ width: 3, color: '#6A6A8A' })
        .width(120)
        .height(48)
        .shadow({ radius: 6, color: '#000000', offsetX: 2, offsetY: 2 })
        .onClick(() => {
          console.info('点击重新玩');
          this.restartGame();
        })
      
      Blank()
      
      // 返回主页按钮（像素风）
      Button('退出')
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor('#4A4A6A')
        .borderRadius(4)
        .border({ width: 3, color: '#6A6A8A' })
        .width(120)
        .height(48)
        .shadow({ radius: 6, color: '#000000', offsetX: 2, offsetY: 2 })
        .onClick(() => {
          console.info('点击返回主页');
          this.returnToHome();
        })
    }
    .width(SCREEN_WIDTH)
    .height(MENU_BAR_HEIGHT)
    .linearGradient({
      angle: 180,
      colors: [['#1A1A2E', 0], ['#0A0A1E', 1]]
    })
    .padding({ left: 30, right: 30 })
    .justifyContent(FlexAlign.SpaceBetween)
  }
  
  /**
   * 构建积分榜弹窗
   */
  @Builder
  buildScoreBoard() {
    // 半透明背景
    Column()
      .width(SCREEN_WIDTH)
      .height(SCREEN_HEIGHT)
      .backgroundColor('rgba(0, 0, 0, 0.7)')
      .onClick(() => {
        this.showScoreBoard = false;
      })
    
    // 积分榜面板（在右侧显示，不遮挡中心游戏区域）
    Column() {
      // 标题
      Text('积分榜')
        .fontSize(18)
        .fontColor('#FFD700')
        .fontWeight(FontWeight.Bold)
        .fontFamily('monospace')
        .margin({ bottom: 15 })
      
      // 分隔线
      Column()
        .width(140)
        .height(2)
        .backgroundColor('#3A3A5A')
        .margin({ bottom: 15 })
      
      // 各关卡得分
      ForEach(Array.from(this.levelScores.entries()), (item: [number, number]) => {
        Row() {
          Text(`LV ${item[0].toString().padStart(2, '0')}`)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontFamily('monospace')
            .width(60)
          
          Text(`${item[1].toString().padStart(6, '0')}`)
            .fontSize(14)
            .fontColor('#FFD700')
            .fontFamily('monospace')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 8 })
      })
      
      // 如果没有记录
      if (this.levelScores.size === 0) {
        Text('暂无记录')
          .fontSize(14)
          .fontColor('#888888')
          .fontFamily('monospace')
          .margin({ top: 10 })
      }
      
      // 分隔线
      Column()
        .width(140)
        .height(2)
        .backgroundColor('#3A3A5A')
        .margin({ top: 15, bottom: 15 })
      
      // 总分
      Row() {
        Text('总计')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontFamily('monospace')
          .fontWeight(FontWeight.Bold)
          .width(60)
        
        Text(`${this.totalScore.toString().padStart(7, '0')}`)
          .fontSize(16)
          .fontColor('#00FF00')
          .fontFamily('monospace')
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      
      // 关闭按钮
      Button('关闭')
        .fontSize(14)
        .fontColor('#FFFFFF')
        .backgroundColor('#4A4A6A')
        .borderRadius(4)
        .border({ width: 2, color: '#6A6A8A' })
        .width(100)
        .height(36)
        .margin({ top: 20 })
        .onClick(() => {
          this.showScoreBoard = false;
        })
    }
    .width(180)
    .padding(20)
    .backgroundColor('#1A1A2E')
    .borderRadius(8)
    .border({ width: 3, color: '#3A3A5A' })
    .position({ x: SCREEN_WIDTH - 200, y: INFO_BAR_HEIGHT + 20 }) // 右上角位置
  }
}
