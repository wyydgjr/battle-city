/**
 * 关卡配置接口
 */
export interface LevelConfig {
  level: number;           // 关卡编号
  name: string;            // 关卡名称
  description: string;     // 关卡描述
  theme: string;           // 主题风格
  enemyCount: number;      // 敌方坦克数量
  difficulty: number;      // 难度等级 1-5
  bgColor: string;         // 背景颜色
  accentColor: string;     // 强调色
}

/**
 * 5个关卡的配置
 */
export const LEVEL_CONFIGS: LevelConfig[] = [
  {
    level: 1,
    name: '新手村',
    description: '简单地形，适合新手练习',
    theme: '平原',
    enemyCount: 3,
    difficulty: 1,
    bgColor: '#1a1a2e',
    accentColor: '#4ade80'
  },
  {
    level: 2,
    name: '森林迷宫',
    description: '树木丛生，需要小心穿行',
    theme: '森林',
    enemyCount: 5,
    difficulty: 2,
    bgColor: '#0d2818',
    accentColor: '#22c55e'
  },
  {
    level: 3,
    name: '冰雪世界',
    description: '冰面湿滑，控制难度增加',
    theme: '雪地',
    enemyCount: 7,
    difficulty: 3,
    bgColor: '#1e3a5f',
    accentColor: '#38bdf8'
  },
  {
    level: 4,
    name: '沙漠风暴',
    description: '沙坑遍布，视野受限',
    theme: '沙漠',
    enemyCount: 9,
    difficulty: 4,
    bgColor: '#4a3728',
    accentColor: '#f59e0b'
  },
  {
    level: 5,
    name: '终极挑战',
    description: '地狱难度，勇者无畏',
    theme: '炼狱',
    enemyCount: 12,
    difficulty: 5,
    bgColor: '#2d1f3d',
    accentColor: '#ef4444'
  }
];

/**
 * 获取关卡配置
 */
export function getLevelConfig(level: number): LevelConfig | null {
  return LEVEL_CONFIGS.find(config => config.level === level) || null;
}

/**
 * 获取总关卡数
 */
export function getTotalLevels(): number {
  return LEVEL_CONFIGS.length;
}
