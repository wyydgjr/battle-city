/**
 * 地形类型枚举
 */
export enum TileType {
  EMPTY = 0,   // 空地 - 可通行
  BRICK = 1,   // 砖墙 - 可被子弹摧毁
  STEEL = 2,   // 钢墙 - 不可摧毁
  EAGLE = 3,   // 基地（存活）
  RIVER = 4,   // 河流 - 坦克无法通过，子弹可通过
  BRIDGE = 5,  // 桥梁 - 可被摧毁，坦克可通过
  ICE = 6      // 冰面 - 坦克滑行
}

/**
 * 砖墙细分状态（4个小块）
 */
export interface BrickState {
  tl: boolean; // 左上 (Top-Left)
  tr: boolean; // 右上 (Top-Right)
  bl: boolean; // 左下 (Bottom-Left)
  br: boolean; // 右下 (Bottom-Right)
}

/**
 * 地图格子
 */
export interface MapTile {
  type: TileType;
  brickState?: BrickState; // 仅当type=BRICK时有效
}

/**
 * 方向枚举（8方向）
 */
export enum Direction {
  UP = 'UP',
  DOWN = 'DOWN',
  LEFT = 'LEFT',
  RIGHT = 'RIGHT',
  UP_LEFT = 'UP_LEFT',
  UP_RIGHT = 'UP_RIGHT',
  DOWN_LEFT = 'DOWN_LEFT',
  DOWN_RIGHT = 'DOWN_RIGHT'
}
