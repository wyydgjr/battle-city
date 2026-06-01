import { media } from '@kit.MediaKit';
import { common } from '@kit.AbilityKit';

/**
 * 音效管理器 - 完整版（支持音量控制）
 */
export class SoundManager {
  private static instance: SoundManager | null = null;
  private context: common.UIAbilityContext | null = null;
  private isInitialized: boolean = false;
  
  private soundEnabled: boolean = true;
  private bgmEnabled: boolean = false;
  
  // 音量控制（0-100）
  private bgmVolume: number = 50;
  private sfxVolume: number = 70;
  
  private bgmPlayer: media.AVPlayer | null = null;
  private shootPlayer: media.AVPlayer | null = null;
  private explosionPlayer: media.AVPlayer | null = null;
  
  private isBgmPlaying: boolean = false;
  
  // 音效冷却
  private lastShootTime: number = 0;
  private lastExplosionTime: number = 0;
  private readonly SHOOT_COOLDOWN: number = 100;
  private readonly EXPLOSION_COOLDOWN: number = 150;

  static getInstance(): SoundManager {
    if (!SoundManager.instance) {
      SoundManager.instance = new SoundManager();
    }
    return SoundManager.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) return;
    
    this.context = context;
    
    this.preloadSounds().then(() => {
      this.isInitialized = true;
      console.info('[SoundManager] 音效系统初始化完成');
    }).catch((error: Error) => {
      console.error('[SoundManager] 音效系统初始化失败:', error);
      this.soundEnabled = false;
    });
  }

  private async preloadSounds(): Promise<void> {
    if (!this.context) return;
    
    try {
      this.bgmPlayer = await media.createAVPlayer();
      this.shootPlayer = await media.createAVPlayer();
      this.explosionPlayer = await media.createAVPlayer();
    } catch (error) {
      console.error('[SoundManager] 音频播放器创建失败:', error);
    }
  }

  private async playSound(fileName: string, player: media.AVPlayer | null, loop: boolean = false, isBGM: boolean = false): Promise<void> {
    if (!this.context || !player) return;
    if (!isBGM && !this.soundEnabled) return;
    if (isBGM && !this.bgmEnabled) return;
    
    try {
      const fileDescriptor = await this.context.resourceManager.getRawFd(fileName);
      
      player.fdSrc = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      
      player.on('stateChange', async (state: string) => {
        if (state === 'prepared') {
          player.loop = loop;
          // 设置音量
          const volume = isBGM ? this.bgmVolume / 100 : this.sfxVolume / 100;
          player.setVolume(volume);
          await player.play();
        }
      });
      
      await player.prepare();
      await this.context.resourceManager.closeRawFd(fileName);
    } catch (error) {
      // 静默失败
    }
  }

  async playShootSound(): Promise<void> {
    if (!this.soundEnabled || !this.isInitialized) return;
    
    const currentTime = Date.now();
    if (currentTime - this.lastShootTime < this.SHOOT_COOLDOWN) return;
    this.lastShootTime = currentTime;
    
    this.playSound('shoot.mp3', this.shootPlayer, false, false).catch(() => {});
  }

  async playExplosionSound(): Promise<void> {
    if (!this.soundEnabled || !this.isInitialized) return;
    
    const currentTime = Date.now();
    if (currentTime - this.lastExplosionTime < this.EXPLOSION_COOLDOWN) return;
    this.lastExplosionTime = currentTime;
    
    this.playSound('shoot.mp3', this.explosionPlayer, false, false).catch(() => {});
  }

  async playHitBrickSound(): Promise<void> {
    await this.playShootSound();
  }

  async playHitEnemySound(): Promise<void> {
    await this.playExplosionSound();
  }

  async playHitPlayerSound(): Promise<void> {
    await this.playExplosionSound();
  }

  async playGameOverSound(): Promise<void> {
    await this.playExplosionSound();
  }

  async playPickupSound(): Promise<void> {
    await this.playShootSound();
  }

  async playLevelStartSound(): Promise<void> {
    await this.playShootSound();
  }

  async playVictorySound(): Promise<void> {
    await this.playExplosionSound();
  }

  async playMoveSound(): Promise<void> {
    // 移动音效禁用
  }

  async startBGM(): Promise<void> {
    if (!this.bgmEnabled || this.isBgmPlaying || !this.isInitialized) return;
    
    this.isBgmPlaying = true;
    this.playSound('bgm.mp3', this.bgmPlayer, true, true).catch(() => {});
  }

  async stopBGM(): Promise<void> {
    this.isBgmPlaying = false;
    if (this.bgmPlayer) {
      try {
        await this.bgmPlayer.stop();
      } catch (error) {
        // 静默失败
      }
    }
  }

  // ========== 音效开关 ==========
  
  setSoundEnabled(enabled: boolean): void {
    this.soundEnabled = enabled;
  }

  isSoundEnabled(): boolean {
    return this.soundEnabled;
  }

  setBGMEnabled(enabled: boolean): void {
    this.bgmEnabled = enabled;
    if (!enabled && this.isBgmPlaying) {
      this.stopBGM();
    } else if (enabled && !this.isBgmPlaying) {
      this.startBGM();
    }
  }

  isBGMEnabled(): boolean {
    return this.bgmEnabled;
  }

  // ========== 音量控制 ==========
  
  setBGMVolume(volume: number): void {
    this.bgmVolume = Math.max(0, Math.min(100, volume));
    if (this.bgmPlayer && this.isBgmPlaying) {
      try {
        this.bgmPlayer.setVolume(this.bgmVolume / 100);
      } catch (error) {
        // 静默失败
      }
    }
  }

  getBGMVolume(): number {
    return this.bgmVolume;
  }

  setSFXVolume(volume: number): void {
    this.sfxVolume = Math.max(0, Math.min(100, volume));
  }

  getSFXVolume(): number {
    return this.sfxVolume;
  }

  async cleanup(): Promise<void> {
    await this.stopBGM();
    
    if (this.bgmPlayer) {
      await this.bgmPlayer.release();
      this.bgmPlayer = null;
    }
    if (this.shootPlayer) {
      await this.shootPlayer.release();
      this.shootPlayer = null;
    }
    if (this.explosionPlayer) {
      await this.explosionPlayer.release();
      this.explosionPlayer = null;
    }
    
    this.isInitialized = false;
  }
}
