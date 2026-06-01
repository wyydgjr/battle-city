import { TileType, MapTile } from './TileType';
import { MAP_GRID_COUNT } from '../common/Constants';

/**
 * 关卡数据接口
 */
export interface LevelData {
  level: number;
  map: MapTile[][]; // 39×39格子
}

/**
 * 创建空地格子
 */
function empty(): MapTile {
  return { type: TileType.EMPTY };
}

/**
 * 创建砖墙格子
 */
function brick(): MapTile {
  return {
    type: TileType.BRICK,
    brickState: { tl: true, tr: true, bl: true, br: true }
  };
}

/**
 * 创建钢墙格子
 */
function steel(): MapTile {
  return { type: TileType.STEEL };
}

/**
 * 创建基地格子
 */
function eagle(): MapTile {
  return { type: TileType.EAGLE };
}

/**
 * 创建河流格子
 */
function river(): MapTile {
  return { type: TileType.RIVER };
}

/**
 * 创建桥梁格子
 */
function bridge(): MapTile {
  return { type: TileType.BRIDGE };
}

/**
 * 创建冰面格子
 */
function ice(): MapTile {
  return { type: TileType.ICE };
}

/**
 * 第1关地图数据
 * 简化版：四周砖墙包围，中央有一些障碍物，底部中央是基地
 */
export const LEVEL_1: LevelData = {
  level: 1,
  map: createLevel1Map()
};

/**
 * 第2关地图数据
 * 更多钢墙和复杂通道
 */
export const LEVEL_2: LevelData = {
  level: 2,
  map: createLevel2Map()
};

/**
 * 第3关地图数据
 * 更复杂的迷宫式布局
 */
export const LEVEL_3: LevelData = {
  level: 3,
  map: createLevel3Map()
};

/**
 * 第4关地图数据
 * 沙漠主题 - 更多钢墙
 */
export const LEVEL_4: LevelData = {
  level: 4,
  map: createLevel4Map()
};

/**
 * 第5关地图数据
 * 终极挑战 - 复杂迷宫
 */
export const LEVEL_5: LevelData = {
  level: 5,
  map: createLevel5Map()
};

/**
 * 障碍物坐标接口
 */
interface ObstacleCoord {
  r: number;
  c: number;
}

/**
 * 创建第1关地图
 */
function createLevel1Map(): MapTile[][] {
  const map: MapTile[][] = [];
  
  // 初始化为空地
  for (let row = 0; row < MAP_GRID_COUNT; row++) {
    map[row] = [];
    for (let col = 0; col < MAP_GRID_COUNT; col++) {
      map[row][col] = empty();
    }
  }
  
  // 绘制四周砖墙边界
  for (let i = 0; i < MAP_GRID_COUNT; i++) {
    map[0][i] = brick();                      // 上边界
    map[MAP_GRID_COUNT - 1][i] = brick();     // 下边界
    map[i][0] = brick();                      // 左边界
    map[i][MAP_GRID_COUNT - 1] = brick();     // 右边界
  }
  
  // 绘制更多内部障碍物（丰富的建筑布局）
  const obstacles: ObstacleCoord[] = [
    // 左上区域 - L形建筑
    { r: 5, c: 5 }, { r: 5, c: 6 }, { r: 5, c: 7 },
    { r: 6, c: 5 }, { r: 7, c: 5 },
    
    // 右上区域 - L形建筑（对称）
    { r: 5, c: 31 }, { r: 5, c: 32 }, { r: 5, c: 33 },
    { r: 6, c: 33 }, { r: 7, c: 33 },
    
    // 左下区域 - L形建筑
    { r: 31, c: 5 }, { r: 32, c: 5 }, { r: 33, c: 5 },
    { r: 33, c: 6 }, { r: 33, c: 7 },
    
    // 右下区域 - L形建筑（对称）
    { r: 31, c: 33 }, { r: 32, c: 33 }, { r: 33, c: 33 },
    { r: 33, c: 31 }, { r: 33, c: 32 },
    
    // 中央区域 - 十字形建筑
    { r: 17, c: 19 }, { r: 18, c: 19 }, { r: 19, c: 19 },
    { r: 19, c: 17 }, { r: 19, c: 18 }, { r: 19, c: 20 }, { r: 19, c: 21 },
    { r: 20, c: 19 }, { r: 21, c: 19 },
    
    // 左侧中间区域 - 横墙
    { r: 12, c: 8 }, { r: 12, c: 9 }, { r: 12, c: 10 }, { r: 12, c: 11 },
    { r: 26, c: 8 }, { r: 26, c: 9 }, { r: 26, c: 10 }, { r: 26, c: 11 },
    
    // 右侧中间区域 - 横墙（对称）
    { r: 12, c: 27 }, { r: 12, c: 28 }, { r: 12, c: 29 }, { r: 12, c: 30 },
    { r: 26, c: 27 }, { r: 26, c: 28 }, { r: 26, c: 29 }, { r: 26, c: 30 },
    
    // 上方中间区域 - 竖墙
    { r: 8, c: 15 }, { r: 9, c: 15 }, { r: 10, c: 15 },
    { r: 8, c: 23 }, { r: 9, c: 23 }, { r: 10, c: 23 },
    
    // 下方中间区域 - 竖墙
    { r: 28, c: 15 }, { r: 29, c: 15 }, { r: 30, c: 15 },
    { r: 28, c: 23 }, { r: 29, c: 23 }, { r: 30, c: 23 },
    
    // 四角小建筑
    { r: 10, c: 10 }, { r: 10, c: 28 },
    { r: 28, c: 10 }, { r: 28, c: 28 }
  ];
  
  for (const obs of obstacles) {
    if (obs.r >= 0 && obs.r < MAP_GRID_COUNT && obs.c >= 0 && obs.c < MAP_GRID_COUNT) {
      map[obs.r][obs.c] = brick();
    }
  }
  
  // 基地保护墙（底部中央）
  const eagleRow = MAP_GRID_COUNT - 3; // 倒数第3行
  const eagleCol = Math.floor(MAP_GRID_COUNT / 2); // 中央列
  
  // 基地本身
  map[eagleRow][eagleCol] = eagle();
  
  // 基地周围保护墙（加强保护）
  map[eagleRow - 1][eagleCol - 1] = brick();
  map[eagleRow - 1][eagleCol] = brick();
  map[eagleRow - 1][eagleCol + 1] = brick();
  map[eagleRow][eagleCol - 1] = brick();
  map[eagleRow][eagleCol + 1] = brick();
  map[eagleRow + 1][eagleCol - 1] = brick();
  map[eagleRow + 1][eagleCol] = brick();
  map[eagleRow + 1][eagleCol + 1] = brick();
  
  // 额外保护墙
  map[eagleRow - 2][eagleCol - 1] = brick();
  map[eagleRow - 2][eagleCol] = brick();
  map[eagleRow - 2][eagleCol + 1] = brick();
  
  return map;
}

/**
 * 创建第2关地图
 */
function createLevel2Map(): MapTile[][] {
  const map: MapTile[][] = [];
  
  // 初始化为空地
  for (let row = 0; row < MAP_GRID_COUNT; row++) {
    map[row] = [];
    for (let col = 0; col < MAP_GRID_COUNT; col++) {
      map[row][col] = empty();
    }
  }
  
  // 四周钢墙边界
  for (let i = 0; i < MAP_GRID_COUNT; i++) {
    map[0][i] = steel();
    map[MAP_GRID_COUNT - 1][i] = steel();
    map[i][0] = steel();
    map[i][MAP_GRID_COUNT - 1] = steel();
  }
  
  // 更多内部障碍（包含钢墙）
  for (let i = 8; i < 15; i++) {
    map[10][i] = brick();
    map[28][i] = brick();
  }
  
  for (let i = 10; i < 28; i++) {
    map[i][12] = steel();
    map[i][26] = steel();
  }
  
  // 添加河流（中间横向河流）
  for (let i = 15; i < 24; i++) {
    map[19][i] = river();
  }
  
  // 添加桥梁（连接河流两岸）
  map[19][19] = bridge();
  
  // 基地保护
  const eagleRow = MAP_GRID_COUNT - 3;
  const eagleCol = Math.floor(MAP_GRID_COUNT / 2);
  map[eagleRow][eagleCol] = eagle();
  
  // 钢墙保护基地
  map[eagleRow - 1][eagleCol - 1] = steel();
  map[eagleRow - 1][eagleCol] = steel();
  map[eagleRow - 1][eagleCol + 1] = steel();
  map[eagleRow][eagleCol - 1] = steel();
  map[eagleRow][eagleCol + 1] = steel();
  map[eagleRow + 1][eagleCol - 1] = steel();
  map[eagleRow + 1][eagleCol] = steel();
  map[eagleRow + 1][eagleCol + 1] = steel();
  
  return map;
}

/**
 * 创建第3关地图
 */
function createLevel3Map(): MapTile[][] {
  const map: MapTile[][] = [];
  
  // 初始化为空地
  for (let row = 0; row < MAP_GRID_COUNT; row++) {
    map[row] = [];
    for (let col = 0; col < MAP_GRID_COUNT; col++) {
      map[row][col] = empty();
    }
  }
  
  // 混合边界（砖墙+钢墙）
  for (let i = 0; i < MAP_GRID_COUNT; i++) {
    map[0][i] = i % 2 === 0 ? brick() : steel();
    map[MAP_GRID_COUNT - 1][i] = i % 2 === 0 ? brick() : steel();
    map[i][0] = i % 2 === 0 ? brick() : steel();
    map[i][MAP_GRID_COUNT - 1] = i % 2 === 0 ? brick() : steel();
  }
  
  // 迷宫式布局
  for (let r = 5; r < 34; r += 7) {
    for (let c = 5; c < 34; c += 7) {
      map[r][c] = steel();
      if (r + 1 < MAP_GRID_COUNT) map[r + 1][c] = brick();
      if (c + 1 < MAP_GRID_COUNT) map[r][c + 1] = brick();
    }
  }
  
  // 添加冰面区域（左上和右下）
  for (let r = 8; r < 12; r++) {
    for (let c = 8; c < 12; c++) {
      map[r][c] = ice();
    }
  }
  
  for (let r = 27; r < 31; r++) {
    for (let c = 27; c < 31; c++) {
      map[r][c] = ice();
    }
  }
  
  // 基地保护
  const eagleRow = MAP_GRID_COUNT - 3;
  const eagleCol = Math.floor(MAP_GRID_COUNT / 2);
  map[eagleRow][eagleCol] = eagle();
  
  // 混合保护墙
  map[eagleRow - 1][eagleCol - 1] = brick();
  map[eagleRow - 1][eagleCol] = steel();
  map[eagleRow - 1][eagleCol + 1] = brick();
  map[eagleRow][eagleCol - 1] = steel();
  map[eagleRow][eagleCol + 1] = steel();
  map[eagleRow + 1][eagleCol - 1] = brick();
  map[eagleRow + 1][eagleCol] = brick();
  map[eagleRow + 1][eagleCol + 1] = brick();
  
  return map;
}

/**
 * 获取关卡数据
 */
export function getLevelData(level: number): LevelData | null {
  switch (level) {
    case 1:
      return LEVEL_1;
    case 2:
      return LEVEL_2;
    case 3:
      return LEVEL_3;
    case 4:
      return LEVEL_4;
    case 5:
      return LEVEL_5;
    default:
      return null;
  }
}

/**
 * 创建第4关地图 - 沙漠主题
 */
function createLevel4Map(): MapTile[][] {
  const map: MapTile[][] = [];
  
  // 初始化为空地
  for (let row = 0; row < MAP_GRID_COUNT; row++) {
    map[row] = [];
    for (let col = 0; col < MAP_GRID_COUNT; col++) {
      map[row][col] = empty();
    }
  }
  
  // 四周钢墙边界
  for (let i = 0; i < MAP_GRID_COUNT; i++) {
    map[0][i] = steel();
    map[MAP_GRID_COUNT - 1][i] = steel();
    map[i][0] = steel();
    map[i][MAP_GRID_COUNT - 1] = steel();
  }
  
  // 沙漠风格 - 大量钢墙形成狭窄通道
  // 水平通道墙
  for (let c = 5; c < 34; c++) {
    map[8][c] = brick();
    map[30][c] = brick();
  }
  
  // 垂直通道墙
  for (let r = 5; r < 34; r++) {
    map[r][8] = brick();
    map[r][30] = brick();
  }
  
  // 中央十字钢墙
  for (let i = 15; i < 24; i++) {
    map[19][i] = steel();
    map[i][19] = steel();
  }
  
  // 四角钢墙堡垒
  for (let r = 12; r < 16; r++) {
    for (let c = 12; c < 16; c++) {
      map[r][c] = steel();
    }
  }
  for (let r = 12; r < 16; r++) {
    for (let c = 23; c < 27; c++) {
      map[r][c] = steel();
    }
  }
  for (let r = 23; r < 27; r++) {
    for (let c = 12; c < 16; c++) {
      map[r][c] = steel();
    }
  }
  for (let r = 23; r < 27; r++) {
    for (let c = 23; c < 27; c++) {
      map[r][c] = steel();
    }
  }
  
  // 基地保护
  const eagleRow = MAP_GRID_COUNT - 3;
  const eagleCol = Math.floor(MAP_GRID_COUNT / 2);
  map[eagleRow][eagleCol] = eagle();
  
  // 钢墙保护基地
  map[eagleRow - 1][eagleCol - 1] = steel();
  map[eagleRow - 1][eagleCol] = steel();
  map[eagleRow - 1][eagleCol + 1] = steel();
  map[eagleRow][eagleCol - 1] = steel();
  map[eagleRow][eagleCol + 1] = steel();
  map[eagleRow + 1][eagleCol - 1] = steel();
  map[eagleRow + 1][eagleCol] = steel();
  map[eagleRow + 1][eagleCol + 1] = steel();
  
  return map;
}

/**
 * 创建第5关地图 - 终极挑战
 */
function createLevel5Map(): MapTile[][] {
  const map: MapTile[][] = [];
  
  // 初始化为空地
  for (let row = 0; row < MAP_GRID_COUNT; row++) {
    map[row] = [];
    for (let col = 0; col < MAP_GRID_COUNT; col++) {
      map[row][col] = empty();
    }
  }
  
  // 混合边界
  for (let i = 0; i < MAP_GRID_COUNT; i++) {
    map[0][i] = steel();
    map[MAP_GRID_COUNT - 1][i] = steel();
    map[i][0] = steel();
    map[i][MAP_GRID_COUNT - 1] = steel();
  }
  
  // 复杂迷宫布局
  // 外圈通道
  for (let i = 6; i < 33; i++) {
    map[5][i] = brick();
    map[33][i] = brick();
    map[i][5] = brick();
    map[i][33] = brick();
  }
  
  // 内圈钢墙
  for (let i = 10; i < 29; i++) {
    map[10][i] = steel();
    map[28][i] = steel();
    map[i][10] = steel();
    map[i][28] = steel();
  }
  
  // 中央区域迷宫
  for (let r = 14; r < 25; r++) {
    for (let c = 14; c < 25; c++) {
      // 创建迷宫通道
      if ((r + c) % 3 === 0) {
        map[r][c] = brick();
      }
    }
  }
  
  // 中央钢墙核心
  for (let r = 17; r < 22; r++) {
    for (let c = 17; c < 22; c++) {
      map[r][c] = steel();
    }
  }
  
  // 四条连接通道
  for (let i = 11; i < 14; i++) {
    map[i][19] = empty();
    map[19][i] = empty();
    map[25 + (i - 11)][19] = empty();
    map[19][25 + (i - 11)] = empty();
  }
  
  // 额外障碍物 - 使用二维数组避免对象字面量
  const obstaclePositions: number[][] = [
    [7, 7], [7, 31], [31, 7], [31, 31],
    [12, 12], [12, 26], [26, 12], [26, 26],
    [15, 15], [15, 23], [23, 15], [23, 23]
  ];
  
  for (let i = 0; i < obstaclePositions.length; i++) {
    const r = obstaclePositions[i][0];
    const c = obstaclePositions[i][1];
    map[r][c] = steel();
  }
  
  // 基地保护
  const eagleRow = MAP_GRID_COUNT - 3;
  const eagleCol = Math.floor(MAP_GRID_COUNT / 2);
  map[eagleRow][eagleCol] = eagle();
  
  // 多层保护墙
  for (let dr = -2; dr <= 2; dr++) {
    for (let dc = -2; dc <= 2; dc++) {
      if (dr === 0 && dc === 0) continue;
      const r = eagleRow + dr;
      const c = eagleCol + dc;
      if (r > 0 && r < MAP_GRID_COUNT && c > 0 && c < MAP_GRID_COUNT) {
        map[r][c] = Math.abs(dr) + Math.abs(dc) <= 2 ? steel() : brick();
      }
    }
  }
  
  return map;
}
