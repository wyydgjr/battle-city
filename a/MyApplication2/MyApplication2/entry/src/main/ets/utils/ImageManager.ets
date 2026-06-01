import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';

/**
 * 图片资源管理器 - 极简版
 * 只加载必要的图片，减少内存占用
 */
export class ImageManager {
  private static instance: ImageManager | null = null;
  private isInitialized: boolean = false;
  private context: common.UIAbilityContext | null = null;
  
  private imageCache: Map<string, ImageBitmap> = new Map();
  
  static getInstance(): ImageManager {
    if (!ImageManager.instance) {
      ImageManager.instance = new ImageManager();
    }
    return ImageManager.instance;
  }

  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  /**
   * 初始化图片资源 - 只加载核心图片
   */
  async init(): Promise<void> {
    if (this.isInitialized) return;
    
    if (!this.context) {
      console.error('[ImageManager] Context 未设置');
      return;
    }
    
    try {
      const resourceMgr = this.context.resourceManager;
      
      // 只加载必要的图片（玩家坦克、敌方坦克、子弹）
      await Promise.all([
        this.loadImage(resourceMgr, 'player_tank.png'),
        this.loadImage(resourceMgr, 'enemy_tank_1.png'),
        this.loadImage(resourceMgr, 'bullet.png'),
      ]);
      
      this.isInitialized = true;
      console.info('[ImageManager] 核心图片加载完成');
    } catch (error) {
      console.error('[ImageManager] 图片加载失败:', error);
    }
  }

  private async loadImage(resourceMgr: resourceManager.ResourceManager, fileName: string): Promise<void> {
    if (this.imageCache.has(fileName)) return;
    
    try {
      const fileData = await resourceMgr.getRawFileContent(fileName);
      const imageSource = image.createImageSource(fileData.buffer);
      
      const decodingOptions: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      };
      const pixelMap = await imageSource.createPixelMap(decodingOptions);
      const imageBitmap = new ImageBitmap(pixelMap);
      this.imageCache.set(fileName, imageBitmap);
      
      console.info(`[ImageManager] 加载: ${fileName}`);
    } catch (error) {
      console.error(`[ImageManager] 加载失败: ${fileName}`, error);
    }
  }

  getPlayerTankImage(): ImageBitmap | null {
    return this.imageCache.get('player_tank.png') || null;
  }

  getEnemyTankImage(type: number = 1): ImageBitmap | null {
    // 所有敌方坦克使用同一张图片
    return this.imageCache.get('enemy_tank_1.png') || null;
  }

  getBulletImage(): ImageBitmap | null {
    return this.imageCache.get('bullet.png') || null;
  }

  // 其他图片方法返回null，使用Canvas绘制
  getBrickImage(): ImageBitmap | null { return null; }
  getSteelImage(): ImageBitmap | null { return null; }
  getWaterImage(): ImageBitmap | null { return null; }
  getIceImage(): ImageBitmap | null { return null; }
  getTreesImage(): ImageBitmap | null { return null; }
  getEagleImage(): ImageBitmap | null { return null; }
  getPowerupStarImage(): ImageBitmap | null { return null; }
  getPowerupTankImage(): ImageBitmap | null { return null; }

  isReady(): boolean {
    return this.isInitialized;
  }

  cleanup(): void {
    this.imageCache.clear();
    this.isInitialized = false;
  }
}
