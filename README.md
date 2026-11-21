# MineCraft FPS — 方塊世界生存射擊

以 **Godot 4.7** 打造的 Minecraft 風格第一人稱射擊網頁遊戲。所有方塊世界、武器與敵人都由程式即時生成，無任何外部美術資產。

## 立即遊玩

> 透過 GitHub Pages 自動建置與部署，推上程式碼後即可直接開網頁玩。

`https://davidlee-jojo.github.io/minecraft-fps/`

## 遊戲特色

- **5 個主題關卡（線性解鎖）**：草原 → 沙漠 → 雪地 → 地獄 → 終界
- **魔王競技場**：多階段巨型方塊魔王，會召喚小怪與放射彈幕
- **多種敵人**：殭屍（近戰）、骷髏（遠程）、苦力怕（自爆）
- **體素世界**：以 MultiMesh 高效生成方塊地形、圍牆與場景物件
- **程式合成音效**：槍聲、爆炸、受傷等即時產生
- **HUD**：血量、彈藥、分數、波次、準心、命中提示
- **進度存檔**：通關進度自動保存（瀏覽器 localStorage）

## 操作方式

| 按鍵 | 動作 |
| --- | --- |
| WASD | 移動 |
| 滑鼠 | 瞄準 |
| 左鍵 | 射擊 |
| R | 換彈 |
| Shift | 衝刺 |
| 空白鍵 | 跳躍 |
| Esc | 釋放滑鼠 |

## 技術架構

- **引擎**：Godot 4.7（GL Compatibility 渲染，最佳網頁相容性）
- **匯出**：Web（nothreads 版，可在 GitHub Pages 直接執行）
- **部署**：GitHub Actions 自動建置並發佈到 GitHub Pages

### 專案結構

```
scenes/            場景（主選單、關卡、玩家、HUD、勝利）
scripts/
  game/            遊戲管理器、關卡流程、關卡資料
  world/           體素世界生成
  player/          第一人稱控制器與武器
  enemies/         敵人 AI（殭屍/骷髏/苦力怕/魔王）、投射物
  ui/              主選單、HUD、勝利畫面
  audio/           程式合成音效
  test/            headless 測試腳本
.github/workflows/ 自動部署流程
```

## 本機開發

1. 安裝 [Godot 4.7.2](https://godotengine.org/download)
2. 安裝對應的 **Web 匯出範本**（編輯器 → 管理匯出範本）
3. 以 Godot 開啟本資料夾並執行，或命令列：

```bash
godot --path . 
```

### 匯出網頁版

```bash
mkdir -p build/web
godot --headless --path . --export-release "Web" "build/web/index.html"
```

### 測試

```bash
godot --headless --path . --script res://scripts/test/smoke_test.gd   # 場景載入
godot --headless --path . --script res://scripts/test/logic_test.gd   # 5 關通關與解鎖
godot --headless --path . --script res://scripts/test/boss_test.gd    # 魔王關
```

## 授權

本專案為原創作品，方塊美術與音效皆由程式生成。
