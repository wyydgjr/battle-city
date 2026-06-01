import window from '@ohos.window';
import { GamePage } from './GamePage';
import { LevelSelectPage } from './LevelSelectPage';
import { SoundManager } from '../audio/SoundManager';

@Entry
@Component
struct Index {
  @State pageState: number = 0;
  @State selectedLevel: number = 1;
  @State showSettings: boolean = false;
  
  // 设置状态
  @State bgmEnabled: boolean = false;
  @State sfxEnabled: boolean = true;
  @State bgmVolume: number = 50;
  @State sfxVolume: number = 70;

  aboutToAppear(): void {
    console.info('Index aboutToAppear');
    
    // 初始化音频设置
    const soundManager = SoundManager.getInstance();
    this.bgmEnabled = soundManager.isBGMEnabled();
    this.sfxEnabled = soundManager.isSoundEnabled();
    this.bgmVolume = soundManager.getBGMVolume();
    this.sfxVolume = soundManager.getSFXVolume();
    
    setTimeout(() => {
      try {
        const context = this.getUIContext();
        if (context && context.getHostContext()) {
          window.getLastWindow(context.getHostContext()!, (err, win) => {
            if (err) {
              console.error('获取窗口失败: ' + JSON.stringify(err));
              return;
            }
            win.setWindowSystemBarProperties({
              statusBarColor: '#000000',
              statusBarContentColor: '#FFFFFF',
              navigationBarColor: '#000000',
              navigationBarContentColor: '#FFFFFF'
            });
          });
        }
      } catch (err) {
        console.error('设置系统UI异常: ' + JSON.stringify(err));
      }
    }, 100);
  }

  build() {
    Stack() {
      Column() {
        if (this.pageState === 2) {
          GamePage({
            startLevel: this.selectedLevel,
            onReturnToHome: () => {
              console.info('GamePage返回主页');
              this.pageState = 0;
            }
          })
        } else if (this.pageState === 1) {
          LevelSelectPage({
            onLevelSelected: (levelId: number) => {
              console.info(`选择关卡: ${levelId}`);
              this.selectedLevel = levelId;
              this.pageState = 2;
            },
            onReturnToHome: () => {
              console.info('返回主页');
              this.pageState = 0;
            }
          })
        } else {
          this.buildHomePage()
        }
      }
      .width('100%')
      .height('100%')
      
      // 设置弹窗
      if (this.showSettings) {
        this.buildSettingsDialog()
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildHomePage() {
    Column() {
      Column()
        .width('100%')
        .height(80)
        .linearGradient({
          angle: 180,
          colors: [['#1A1A2E', 0], ['#0A0A1E', 1]]
        })
      
      Column() {
        Text('坦克')
          .fontSize(56)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .letterSpacing(8)
          .textShadow({ radius: 8, color: '#FF6B00', offsetX: 3, offsetY: 3 })
        
        Text('大战')
          .fontSize(56)
          .fontColor('#FFD700')
          .fontWeight(FontWeight.Bold)
          .letterSpacing(8)
          .textShadow({ radius: 8, color: '#FF6B00', offsetX: 3, offsetY: 3 })
          .margin({ top: 5 })
        
        Text('BATTLE CITY')
          .fontSize(20)
          .fontColor('#FF6347')
          .fontWeight(FontWeight.Medium)
          .letterSpacing(12)
          .margin({ top: 20 })
      }
      .margin({ top: 40 })
      
      Row() {
        Column() {
          Row() {
            Column().width(8).height(8).backgroundColor('#FFD700')
            Column().width(8).height(8).backgroundColor('#000000')
            Column().width(8).height(8).backgroundColor('#FFD700')
          }
          Row() {
            Column().width(8).height(16).backgroundColor('#FFD700')
          }
          Row() {
            Column().width(8).height(8).backgroundColor('#FFD700')
            Column().width(8).height(8).backgroundColor('#FFD700')
            Column().width(8).height(8).backgroundColor('#FFD700')
          }
        }
        .margin({ right: 80 })
        
        Column() {
          Row() {
            Column().width(8).height(8).backgroundColor('#FF4444')
            Column().width(8).height(8).backgroundColor('#000000')
            Column().width(8).height(8).backgroundColor('#FF4444')
          }
          Row() {
            Column().width(8).height(16).backgroundColor('#FF4444')
          }
          Row() {
            Column().width(8).height(8).backgroundColor('#FF4444')
            Column().width(8).height(8).backgroundColor('#FF4444')
            Column().width(8).height(8).backgroundColor('#FF4444')
          }
        }
      }
      .margin({ top: 50 })
      
      Column() {
        Button('选择关卡')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .backgroundColor('#4CAF50')
          .borderRadius(4)
          .border({ width: 3, color: '#388E3C' })
          .width(220)
          .height(50)
          .shadow({ radius: 8, color: '#000000', offsetX: 3, offsetY: 3 })
          .onClick(() => {
            console.info('用户点击选择关卡');
            this.pageState = 1;
          })
        
        Button('快速开始')
          .fontSize(20)
          .fontColor('#FFFFFF')
          .backgroundColor('#1E90FF')
          .borderRadius(4)
          .border({ width: 3, color: '#4169E1' })
          .width(220)
          .height(50)
          .shadow({ radius: 8, color: '#000000', offsetX: 3, offsetY: 3 })
          .margin({ top: 15 })
          .onClick(() => {
            console.info('用户点击快速开始');
            this.selectedLevel = 1;
            this.pageState = 2;
          })
        
        // 设置按钮
        Button('⚙ 设置')
          .fontSize(18)
          .fontColor('#FFFFFF')
          .backgroundColor('#FF9800')
          .borderRadius(4)
          .border({ width: 2, color: '#F57C00' })
          .width(220)
          .height(45)
          .shadow({ radius: 6, color: '#000000', offsetX: 2, offsetY: 2 })
          .margin({ top: 15 })
          .onClick(() => {
            this.showSettings = true;
          })
        
        Text('▶')
          .fontSize(24)
          .fontColor('#FFD700')
          .margin({ top: 15 })
      }
      .margin({ top: 50 })
      
      Column() {
        Text('© 1980-1990 NAMCO')
          .fontSize(12)
          .fontColor('#666666')
          .margin({ bottom: 5 })
        
        Text('鸿蒙版')
          .fontSize(14)
          .fontColor('#888888')
          .fontWeight(FontWeight.Medium)
      }
      .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#000000')
  }
  
  @Builder
  buildSettingsDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.7)')
        .onClick(() => {
          this.showSettings = false;
        })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
    
    // 设置面板
    Column() {
      // 标题
      Text('⚙ 音频设置')
        .fontSize(28)
        .fontColor('#FFD700')
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
      
      // 背景音乐设置
      Column() {
        Row() {
          Text('背景音乐')
            .fontSize(18)
            .fontColor('#FFFFFF')
            .width(100)
          
          Toggle({ type: ToggleType.Switch, isOn: this.bgmEnabled })
            .selectedColor('#4CAF50')
            .onChange((isOn: boolean) => {
              this.bgmEnabled = isOn;
              SoundManager.getInstance().setBGMEnabled(isOn);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 15 })
        
        // BGM音量滑块
        if (this.bgmEnabled) {
          Row() {
            Text('音量')
              .fontSize(16)
              .fontColor('#AAAAAA')
              .width(100)
            
            Slider({
              value: this.bgmVolume,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .blockColor('#FFD700')
              .trackColor('#333333')
              .selectedColor('#4CAF50')
              .width(150)
              .onChange((value: number) => {
                this.bgmVolume = Math.round(value);
                SoundManager.getInstance().setBGMVolume(this.bgmVolume);
              })
            
            Text(`${this.bgmVolume}%`)
              .fontSize(14)
              .fontColor('#FFD700')
              .width(50)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 20 })
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor('rgba(50, 50, 50, 0.8)')
      .borderRadius(8)
      .margin({ bottom: 20 })
      
      // 音效设置
      Column() {
        Row() {
          Text('游戏音效')
            .fontSize(18)
            .fontColor('#FFFFFF')
            .width(100)
          
          Toggle({ type: ToggleType.Switch, isOn: this.sfxEnabled })
            .selectedColor('#4CAF50')
            .onChange((isOn: boolean) => {
              this.sfxEnabled = isOn;
              SoundManager.getInstance().setSoundEnabled(isOn);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 15 })
        
        // 音效音量滑块
        if (this.sfxEnabled) {
          Row() {
            Text('音量')
              .fontSize(16)
              .fontColor('#AAAAAA')
              .width(100)
            
            Slider({
              value: this.sfxVolume,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .blockColor('#FFD700')
              .trackColor('#333333')
              .selectedColor('#4CAF50')
              .width(150)
              .onChange((value: number) => {
                this.sfxVolume = Math.round(value);
                SoundManager.getInstance().setSFXVolume(this.sfxVolume);
              })
            
            Text(`${this.sfxVolume}%`)
              .fontSize(14)
              .fontColor('#FFD700')
              .width(50)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ bottom: 10 })
        }
      }
      .width('100%')
      .padding(15)
      .backgroundColor('rgba(50, 50, 50, 0.8)')
      .borderRadius(8)
      .margin({ bottom: 30 })
      
      // 关闭按钮
      Button('关闭')
        .fontSize(18)
        .fontColor('#FFFFFF')
        .backgroundColor('#FF5722')
        .borderRadius(8)
        .width(150)
        .height(45)
        .onClick(() => {
          this.showSettings = false;
        })
    }
    .width(320)
    .padding(30)
    .backgroundColor('rgba(20, 20, 20, 0.95)')
    .borderRadius(16)
    .border({ width: 2, color: '#FFD700' })
    .shadow({ radius: 20, color: '#000000', offsetX: 0, offsetY: 10 })
  }
}
