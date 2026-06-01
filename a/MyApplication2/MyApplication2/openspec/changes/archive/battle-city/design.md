±------------------+ ±------------------+ ±------------------+
| User Interface | --> | Game Engine | --> | Rendering |
| (Title/Settings/ | | (GameState/Logic) | | (Canvas/Canvas2D) |
| Game/GameOver) | <-- | | <-- | |
±------------------+ ±------------------+ ±------------------+
^ ^ ^
| | |
| | |
v v v
±------------------+ ±------------------+ ±------------------+
| Input Manager | <-- | Audio Manager | <-- | Storage Manager |
| (Touch/Virtual | | (SoundPool/AVPlayer)| | (@ohos.data) |
| Joystick) | --> | | --> | |
±------------------+ ±------------------+ ±------------------+


## 类图设计
±------------------+ ±------------------+ ±------------------+
| GameEngine | | GameRenderer | | GameState |
| - gameState | | - canvas | | - currentState |
| - playerTank |<>---->| - renderLoop |<>---->| - score |
| - enemyTanks | | - renderMap | | - lives |
| - bullets | | - renderTank | | - currentStage |
| - explosions | | - renderBullet | | - difficulty |
±------------------+ ±------------------+ ±------------------+
^ ^ ^
| | |
| | |
v v v
±------------------+ ±------------------+ ±------------------+
| Tank | | PlayerTank | | EnemyTank |
| - position | | - level | | - aiBehavior |
| - direction | | - lives | | - moveSpeed |
| - speed | | - shieldTime | | - shootInterval |
| - hp | ±------------------+ ±------------------+
±------------------+
^
|
v
±------------------+
| Bullet |
| - position |
| - direction |
| - speed |
| - owner |
±------------------+


## 数据流设计
用户输入 → InputManager → GameEngine → GameState更新 → GameRenderer → Canvas渲染


## 碰撞检测算法伪代码
typescript
function checkCollision(rect1, rect2) {
return rect1.x < rect2.x + rect2.width &&
rect1.x + rect1.width > rect2.x &&
rect1.y < rect2.y + rect2.height &&
rect1.y + rect1.height > rect2.y;
}

function checkTankMapCollision(tank, map) {
// 检查坦克即将占据的格子是否可通行
const tiles = getOccupiedTiles(tank);
for (const tile of tiles) {
if (!map.isPassable(tile)) {
return true; // 碰撞
}
}
return false; // 无碰撞
}


## 状态机转换图
[TITLE] --start–> [MODE_SELECT]
[MODE_SELECT] --confirm–> [STAGE_INTRO]
[STAGE_INTRO] --timeout–> [PLAYING]
[PLAYING] --gameOver–> [GAME_OVER]
[PLAYING] --stageClear–> [STAGE_INTRO]
[GAME_OVER] --timeout–> [TITLE]


## 存储设计
typescript
interface GameStorage {
highScore: number;
soundEnabled: boolean;
musicEnabled: boolean;
difficulty: ‘EASY’ | ‘NORMAL’ | ‘HARD’;
lastPlayedStage: number;
}

// 使用 @ohos.data.preferences 存储
const preferences = preferences.getInstance();
preferences.put(‘highScore’, 0);
preferences.put(‘soundEnabled’, true);
preferences.put(‘musicEnabled’, true);
preferences.put(‘difficulty’, ‘NORMAL’);
preferences.put(‘lastPlayedStage’, 1);

