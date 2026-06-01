import { TileType, MapTile, BrickState, Direction } from './TileType';
import { MAP_GRID_COUNT, TILE_SIZE, COLORS } from '../common/Constants';
import { LevelData, getLevelData } from './LevelData';
import { ImageManager } from '../utils/ImageManager';

/**
 * 游戏地图管理类
 */
export class GameMap {
  private map: MapTile[][] = [];
  private currentLevel: number = 1;
  isEagleDestroyed: boolean = false; // 基地是否被摧毁
  
  /**
   * 摧毁基地
   */
  destroyEagle(): void {
    this.isEagleDestroyed = true;
    console.info('[GameMap] 基地已被摧毁！Game Over!');
  }
  
  /**
   * 重置基地状态
   */
  resetEagle(): void {
    this.isEagleDestroyed = false;
  }
  
  /**
   * 加载关卡
   */
  loadLevel(level: number): boolean {
    const levelData = getLevelData(level);
    if (!levelData) {
      console.error(`关卡 ${level} 不存在`);
      return false;
    }
    
    this.currentLevel = level;
    // 深拷贝地图数据
    this.map = [];
    for (let row = 0; row < levelData.map.length; row++) {
      this.map[row] = [];
      for (let col = 0; col < levelData.map[row].length; col++) {
        const tile = levelData.map[row][col];
        const newTile: MapTile = {
          type: tile.type,
          brickState: tile.brickState ? {
            tl: tile.brickState.tl,
            tr: tile.brickState.tr,
            bl: tile.brickState.bl,
            br: tile.brickState.br
          } : undefined
        };
        this.map[row][col] = newTile;
      }
    }
    
    console.info(`关卡 ${level} 加载成功`);
    return true;
  }
  
  /**
   * 获取指定位置的格子
   */
  getTile(col: number, row: number): MapTile | null {
    if (col < 0 || col >= MAP_GRID_COUNT || row < 0 || row >= MAP_GRID_COUNT) {
      return null;
    }
    return this.map[row][col];
  }
  
  /**
   * 设置指定位置的格子
   */
  setTile(col: number, row: number, tile: MapTile): void {
    if (col < 0 || col >= MAP_GRID_COUNT || row < 0 || row >= MAP_GRID_COUNT) {
      return;
    }
    this.map[row][col] = tile;
  }
  
  /**
   * 判断格子是否可通行
   */
  isPassable(col: number, row: number): boolean {
    const tile = this.getTile(col, row);
    if (!tile) return false;
    
    // 河流不可通行，其他地形可通行
    return tile.type !== TileType.RIVER;
  }
  
  /**
   * 子弹击中砖墙，摧毁对应的一小块（1/4格）
   * @param col 格子列号
   * @param row 格子行号
   * @param hitFrom 子弹击中方向
   * @param hitX 子弹击中的X坐标（像素）
   * @param hitY 子弹击中的Y坐标（像素）
   * @returns 是否成功摧毁
   */
  damageBrick(col: number, row: number, hitFrom: Direction, localX?: number, localY?: number): boolean {
    const tile = this.getTile(col, row);
    if (!tile || tile.type !== TileType.BRICK || !tile.brickState) {
      return false;
    }
    
    const halfTile = TILE_SIZE / 2;
    let destroyed = false;
    
    // 根据子弹射来的方向，从外向内破坏
    switch (hitFrom) {
      case Direction.UP:
        // 从上方射来，先破坏上方的小块（tl, tr）
        if (tile.brickState.tl) {
          tile.brickState.tl = false;
          destroyed = true;
        } else if (tile.brickState.tr) {
          tile.brickState.tr = false;
          destroyed = true;
        } else {
          // 上方都破坏了，破坏下方
          if (tile.brickState.bl) {
            tile.brickState.bl = false;
            destroyed = true;
          } else if (tile.brickState.br) {
            tile.brickState.br = false;
            destroyed = true;
          }
        }
        break;
        
      case Direction.DOWN:
        // 从下方射来，先破坏下方的小块（bl, br）
        if (tile.brickState.bl) {
          tile.brickState.bl = false;
          destroyed = true;
        } else if (tile.brickState.br) {
          tile.brickState.br = false;
          destroyed = true;
        } else {
          // 下方都破坏了，破坏上方
          if (tile.brickState.tl) {
            tile.brickState.tl = false;
            destroyed = true;
          } else if (tile.brickState.tr) {
            tile.brickState.tr = false;
            destroyed = true;
          }
        }
        break;
        
      case Direction.LEFT:
        // 从左侧射来，先破坏左侧的小块（tl, bl）
        if (tile.brickState.tl) {
          tile.brickState.tl = false;
          destroyed = true;
        } else if (tile.brickState.bl) {
          tile.brickState.bl = false;
          destroyed = true;
        } else {
          // 左侧都破坏了，破坏右侧
          if (tile.brickState.tr) {
            tile.brickState.tr = false;
            destroyed = true;
          } else if (tile.brickState.br) {
            tile.brickState.br = false;
            destroyed = true;
          }
        }
        break;
        
      case Direction.RIGHT:
        // 从右侧射来，先破坏右侧的小块（tr, br）
        if (tile.brickState.tr) {
          tile.brickState.tr = false;
          destroyed = true;
        } else if (tile.brickState.br) {
          tile.brickState.br = false;
          destroyed = true;
        } else {
          // 右侧都破坏了，破坏左侧
          if (tile.brickState.tl) {
            tile.brickState.tl = false;
            destroyed = true;
          } else if (tile.brickState.bl) {
            tile.brickState.bl = false;
            destroyed = true;
          }
        }
        break;
    }
    
    // 如果4个小块都被摧毁，变为空地
    if (!tile.brickState.tl && !tile.brickState.tr &&
        !tile.brickState.bl && !tile.brickState.br) {
      tile.type = TileType.EMPTY;
      tile.brickState = undefined;
      console.info(`[GameMap] 砖墙完全摧毁 at (${col}, ${row})`);
    }
    
    return destroyed;
  }
  
  /**
   * 检查坦克能否进入指定像素位置（支持钻墙）
   * @param x 坦克目标X坐标（vp）
   * @param y 坦克目标Y坐标（vp）
   * @param size 坦克尺寸（vp）
   * @returns 是否可通行
   */
  canTankEnter(x: number, y: number, size: number): boolean {
    // 计算坦克占据的格子范围
    const startCol = Math.floor(x / TILE_SIZE);
    const endCol = Math.floor((x + size - 0.01) / TILE_SIZE);
    const startRow = Math.floor(y / TILE_SIZE);
    const endRow = Math.floor((y + size - 0.01) / TILE_SIZE);
    
    // 检查每个占据的格子
    for (let row = startRow; row <= endRow; row++) {
      for (let col = startCol; col <= endCol; col++) {
        const tile = this.getTile(col, row);
        if (!tile) return false; // 超出边界
        
        // 检查该格子是否对坦克可通行
        if (!this.isTilePassableForTank(tile, x, y, size, col, row)) {
          return false;
        }
      }
    }
    
    return true;
  }
  
  /**
   * 判断单个格子是否对坦克可通行（考虑细分砖墙）
   */
  private isTilePassableForTank(
    tile: MapTile,
    tankX: number,
    tankY: number,
    tankSize: number,
    tileCol: number,
    tileRow: number
  ): boolean {
    // 空地：可通行
    if (tile.type === TileType.EMPTY) {
      return true;
    }
    
    // 钢墙/基地：不可通行
    if (tile.type === TileType.STEEL || tile.type === TileType.EAGLE) {
      return false;
    }
    
    // 砖墙：需要细分检测
    if (tile.type === TileType.BRICK && tile.brickState) {
      return this.canPassThroughBrick(tile.brickState, tankX, tankY, tankSize, tileCol, tileRow);
    }
    
    return false;
  }
  
  /**
   * 判断坦克能否穿过部分摧毁的砖墙（钻墙机制核心）
   */
  private canPassThroughBrick(
    brick: BrickState,
    tankX: number,
    tankY: number,
    tankSize: number,
    tileCol: number,
    tileRow: number
  ): boolean {
    const tileX = tileCol * TILE_SIZE;
    const tileY = tileRow * TILE_SIZE;
    const halfTile = TILE_SIZE / 2; // ≈ 4.615vp
    
    // 定义4个小块的矩形区域
    interface SubTile {
      x: number;
      y: number;
      exists: boolean;
    }
    
    const subTiles: SubTile[] = [
      { x: tileX, y: tileY, exists: brick.tl },                    // 左上
      { x: tileX + halfTile, y: tileY, exists: brick.tr },         // 右上
      { x: tileX, y: tileY + halfTile, exists: brick.bl },         // 左下
      { x: tileX + halfTile, y: tileY + halfTile, exists: brick.br } // 右下
    ];
    
    // 检查坦克是否与任何存在的砖块重叠
    for (const sub of subTiles) {
      if (!sub.exists) continue; // 该小块已被摧毁，忽略
      
      // AABB碰撞检测
      if (this.rectOverlap(
        tankX, tankY, tankSize, tankSize,
        sub.x, sub.y, halfTile, halfTile
      )) {
        return false; // 与砖块重叠，不可通行
      }
    }
    
    return true; // 没有与任何砖块重叠，可以通行（钻墙成功！）
  }
  
  /**
   * AABB矩形重叠检测
   */
  private rectOverlap(
    x1: number, y1: number, w1: number, h1: number,
    x2: number, y2: number, w2: number, h2: number
  ): boolean {
    return x1 < x2 + w2 && x1 + w1 > x2 &&
           y1 < y2 + h2 && y1 + h1 > y2;
  }
  
  /**
   * 渲染地图
   */
  render(ctx: CanvasRenderingContext2D, offsetY: number): void {
    const imageManager = ImageManager.getInstance();
    const useImages = imageManager.isReady();
    
    for (let row = 0; row < MAP_GRID_COUNT; row++) {
      for (let col = 0; col < MAP_GRID_COUNT; col++) {
        const tile = this.map[row][col];
        const x = col * TILE_SIZE;
        const y = row * TILE_SIZE + offsetY;
        
        switch (tile.type) {
          case TileType.BRICK:
            if (useImages) {
              this.renderBrickWithImage(ctx, x, y, tile.brickState, imageManager);
            } else {
              this.renderBrick(ctx, x, y, tile.brickState);
            }
            break;
          case TileType.STEEL:
            if (useImages) {
              this.renderSteelWithImage(ctx, x, y, imageManager);
            } else {
              this.renderSteel(ctx, x, y);
            }
            break;
          case TileType.EAGLE:
            if (useImages) {
              this.renderEagleWithImage(ctx, x, y, imageManager);
            } else {
              this.renderEagle(ctx, x, y);
            }
            break;
          case TileType.RIVER:
            this.renderRiver(ctx, x, y);
            break;
          case TileType.BRIDGE:
            this.renderBridge(ctx, x, y);
            break;
          case TileType.ICE:
            this.renderIce(ctx, x, y);
            break;
        }
      }
    }
  }
  
  /**
   * 使用图片渲染砖墙
   */
  private renderBrickWithImage(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    brickState: BrickState | undefined,
    imageManager: ImageManager
  ): void {
    const image = imageManager.getBrickImage();
    if (!image) {
      this.renderBrick(ctx, x, y, brickState);
      return;
    }
    
    const halfTile = TILE_SIZE / 2;
    
    // 绘制存在的小块
    const drawSubTile = (sx: number, sy: number, exists: boolean) => {
      if (!exists) return;
      ctx.drawImage(image, sx, sy, halfTile, halfTile);
    };
    
    if (!brickState) {
      // 完整砖墙
      drawSubTile(x, y, true);
      drawSubTile(x + halfTile, y, true);
      drawSubTile(x, y + halfTile, true);
      drawSubTile(x + halfTile, y + halfTile, true);
    } else {
      // 部分摧毁的砖墙
      drawSubTile(x, y, brickState.tl);
      drawSubTile(x + halfTile, y, brickState.tr);
      drawSubTile(x, y + halfTile, brickState.bl);
      drawSubTile(x + halfTile, y + halfTile, brickState.br);
    }
  }
  
  /**
   * 使用图片渲染钢墙
   */
  private renderSteelWithImage(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    imageManager: ImageManager
  ): void {
    const image = imageManager.getSteelImage();
    if (image) {
      ctx.drawImage(image, x, y, TILE_SIZE, TILE_SIZE);
    } else {
      this.renderSteel(ctx, x, y);
    }
  }
  
  /**
   * 使用图片渲染基地
   */
  private renderEagleWithImage(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    imageManager: ImageManager
  ): void {
    const image = imageManager.getEagleImage();
    if (image) {
      ctx.drawImage(image, x, y, TILE_SIZE, TILE_SIZE);
    } else {
      this.renderEagle(ctx, x, y);
    }
  }
  
  /**
   * 渲染砖墙（支持部分摧毁）- 像素风格
   */
  private renderBrick(
    ctx: CanvasRenderingContext2D,
    x: number,
    y: number,
    brickState?: BrickState
  ): void {
    const halfTile = TILE_SIZE / 2;
    
    // 绘制存在的小块
    const drawSubTile = (sx: number, sy: number, exists: boolean) => {
      if (!exists) return;
      
      // 砖墙主体（深棕色）
      ctx.fillStyle = '#8B4513';
      ctx.fillRect(sx, sy, halfTile, halfTile);
      
      // 砖缝效果（深色线条）
      ctx.strokeStyle = '#5D3A1A';
      ctx.lineWidth = 1;
      
      // 水平砖缝
      ctx.beginPath();
      ctx.moveTo(sx, sy + halfTile / 2);
      ctx.lineTo(sx + halfTile, sy + halfTile / 2);
      ctx.stroke();
      
      // 垂直砖缝
      ctx.beginPath();
      ctx.moveTo(sx + halfTile / 2, sy);
      ctx.lineTo(sx + halfTile / 2, sy + halfTile);
      ctx.stroke();
      
      // 高光效果（左上角）
      ctx.fillStyle = '#A0522D';
      ctx.fillRect(sx, sy, halfTile * 0.3, halfTile * 0.3);
    };
    
    if (!brickState) {
      // 完整砖墙 - 绘制4个小块
      drawSubTile(x, y, true);
      drawSubTile(x + halfTile, y, true);
      drawSubTile(x, y + halfTile, true);
      drawSubTile(x + halfTile, y + halfTile, true);
      return;
    }
    
    // 部分摧毁的砖墙
    drawSubTile(x, y, brickState.tl);
    drawSubTile(x + halfTile, y, brickState.tr);
    drawSubTile(x, y + halfTile, brickState.bl);
    drawSubTile(x + halfTile, y + halfTile, brickState.br);
  }
  
  /**
   * 渲染钢墙 - 金属质感
   */
  private renderSteel(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    // 钢墙主体（深灰色）
    ctx.fillStyle = '#6B6B6B';
    ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
    
    // 金属纹理（斜线）
    ctx.strokeStyle = '#8A8A8A';
    ctx.lineWidth = 1;
    for (let i = 0; i < TILE_SIZE; i += 3) {
      ctx.beginPath();
      ctx.moveTo(x + i, y);
      ctx.lineTo(x, y + i);
      ctx.stroke();
    }
    
    // 高光效果（左上角）
    ctx.fillStyle = '#9A9A9A';
    ctx.fillRect(x, y, TILE_SIZE * 0.4, TILE_SIZE * 0.4);
    
    // 边框
    ctx.strokeStyle = '#4A4A4A';
    ctx.lineWidth = 2;
    ctx.strokeRect(x, y, TILE_SIZE, TILE_SIZE);
  }
  
  /**
   * 渲染基地（泉水/老鹰）- 精美设计
   */
  private renderEagle(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    const centerX = x + TILE_SIZE / 2;
    const centerY = y + TILE_SIZE / 2;
    const size = TILE_SIZE * 0.8;
    
    // 外圈装饰（深蓝色）
    ctx.fillStyle = '#1E3A5F';
    ctx.beginPath();
    ctx.arc(centerX, centerY, size / 2, 0, Math.PI * 2);
    ctx.fill();
    
    // 中圈（蓝色）
    ctx.fillStyle = '#2E5A8F';
    ctx.beginPath();
    ctx.arc(centerX, centerY, size / 2.5, 0, Math.PI * 2);
    ctx.fill();
    
    // 内圈（浅蓝色 - 泉水效果）
    ctx.fillStyle = '#4A90D9';
    ctx.beginPath();
    ctx.arc(centerX, centerY, size / 3.5, 0, Math.PI * 2);
    ctx.fill();
    
    // 中心高光（白色）
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(centerX - size * 0.1, centerY - size * 0.1, size / 8, 0, Math.PI * 2);
    ctx.fill();
    
    // 星星装饰
    ctx.fillStyle = '#FFD700';
    ctx.font = `bold ${TILE_SIZE * 0.5}px monospace`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText('★', centerX, centerY + size * 0.05);
    
    // 边框
    ctx.strokeStyle = '#0D2847';
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.arc(centerX, centerY, size / 2, 0, Math.PI * 2);
    ctx.stroke();
  }
  
  /**
   * 渲染河流
   */
  private renderRiver(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    // 河流底色（深蓝色）
    ctx.fillStyle = '#1E4D7B';
    ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
    
    // 水波纹效果
    ctx.strokeStyle = '#3A7DBF';
    ctx.lineWidth = 1;
    const waveCount = 3;
    for (let i = 0; i < waveCount; i++) {
      const yOffset = y + (TILE_SIZE / (waveCount + 1)) * (i + 1);
      ctx.beginPath();
      ctx.moveTo(x, yOffset);
      for (let j = 0; j <= TILE_SIZE; j += 4) {
        const wave = Math.sin((j / TILE_SIZE) * Math.PI * 2) * 2;
        ctx.lineTo(x + j, yOffset + wave);
      }
      ctx.stroke();
    }
    
    // 高光效果
    ctx.fillStyle = 'rgba(255, 255, 255, 0.2)';
    ctx.fillRect(x + 2, y + 2, TILE_SIZE - 4, 3);
  }
  
  /**
   * 渲染桥梁
   */
  private renderBridge(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    // 桥梁底色（棕色）
    ctx.fillStyle = '#8B4513';
    ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
    
    // 木板纹理
    ctx.strokeStyle = '#A0522D';
    ctx.lineWidth = 2;
    const plankCount = 4;
    for (let i = 0; i <= plankCount; i++) {
      const xPos = x + (TILE_SIZE / plankCount) * i;
      ctx.beginPath();
      ctx.moveTo(xPos, y);
      ctx.lineTo(xPos, y + TILE_SIZE);
      ctx.stroke();
    }
    
    // 边框
    ctx.strokeStyle = '#5D3A1A';
    ctx.lineWidth = 1;
    ctx.strokeRect(x, y, TILE_SIZE, TILE_SIZE);
  }
  
  /**
   * 渲染冰面
   */
  private renderIce(ctx: CanvasRenderingContext2D, x: number, y: number): void {
    // 冰面底色（浅蓝色半透明）
    ctx.fillStyle = 'rgba(200, 230, 255, 0.8)';
    ctx.fillRect(x, y, TILE_SIZE, TILE_SIZE);
    
    // 冰面纹理（裂纹效果）
    ctx.strokeStyle = 'rgba(255, 255, 255, 0.6)';
    ctx.lineWidth = 1;
    
    // 随机裂纹
    ctx.beginPath();
    ctx.moveTo(x + TILE_SIZE * 0.3, y + TILE_SIZE * 0.3);
    ctx.lineTo(x + TILE_SIZE * 0.7, y + TILE_SIZE * 0.6);
    ctx.stroke();
    
    ctx.beginPath();
    ctx.moveTo(x + TILE_SIZE * 0.6, y + TILE_SIZE * 0.2);
    ctx.lineTo(x + TILE_SIZE * 0.4, y + TILE_SIZE * 0.8);
    ctx.stroke();
    
    // 高光效果
    ctx.fillStyle = 'rgba(255, 255, 255, 0.4)';
    ctx.fillRect(x + 2, y + 2, TILE_SIZE * 0.4, TILE_SIZE * 0.2);
    
    // 边框
    ctx.strokeStyle = 'rgba(150, 200, 230, 0.8)';
    ctx.lineWidth = 1;
    ctx.strokeRect(x, y, TILE_SIZE, TILE_SIZE);
  }
  
  /**
   * 获取当前关卡号
   */
  getCurrentLevel(): number {
    return this.currentLevel;
  }
}
