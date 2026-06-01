/**
 * Battle City 游戏全局常量定义
 */

// 屏幕规格（基于nova 15模拟器）
export const SCREEN_WIDTH = 360; // vp
export const SCREEN_HEIGHT = 780; // vp

// 四区布局比例
export const INFO_BAR_RATIO = 0.10;    // 顶端信息条 10%
export const GAME_AREA_RATIO = 0.60;   // 游戏画面区 60%
export const CONTROL_AREA_RATIO = 0.20; // 操控区 20%
export const MENU_BAR_RATIO = 0.10;    // 底部菜单栏 10%

// 四区高度计算
export const INFO_BAR_HEIGHT = SCREEN_HEIGHT * INFO_BAR_RATIO;     // 78vp
export const GAME_AREA_HEIGHT = SCREEN_HEIGHT * GAME_AREA_RATIO;   // 468vp
export const CONTROL_AREA_HEIGHT = SCREEN_HEIGHT * CONTROL_AREA_RATIO; // 156vp
export const MENU_BAR_HEIGHT = SCREEN_HEIGHT * MENU_BAR_RATIO;     // 78vp

// 游戏地图配置（微缩化）
export const MAP_GRID_COUNT = 39; // 39×39格子
export const TILE_SIZE = SCREEN_WIDTH / MAP_GRID_COUNT; // ≈ 9.23vp

// 坦克尺寸（2×2格大小，更接近经典视觉效果）
export const TANK_SIZE = TILE_SIZE * 2; // 约18.46vp

// 颜色定义（NES原版风格）
export interface ColorPalette {
  BLACK: string;
  WHITE: string;
  RED: string;
  YELLOW: string;
  GREEN: string;
  GRAY: string;
  DARK_GRAY: string;
  BRICK_BROWN: string;
  STEEL_GRAY: string;
}

export const COLORS: ColorPalette = {
  BLACK: '#000000',
  WHITE: '#FFFFFF',
  RED: '#FF0000',
  YELLOW: '#FFD700',
  GREEN: '#00CC00',
  GRAY: '#A0A0A0',
  DARK_GRAY: '#1A1A2E',
  BRICK_BROWN: '#B85C00',
  STEEL_GRAY: '#808080'
};

// 游戏状态枚举
export enum GameState {
  TITLE = 'TITLE',
  MODE_SELECT = 'MODE_SELECT',
  STAGE_INTRO = 'STAGE_INTRO',
  PLAYING = 'PLAYING',
  STAGE_CLEAR = 'STAGE_CLEAR',
  GAME_OVER = 'GAME_OVER',
  PAUSED = 'PAUSED'
}

// 方向枚举
export enum Direction {
  UP = 'UP',
  DOWN = 'DOWN',
  LEFT = 'LEFT',
  RIGHT = 'RIGHT'
}
