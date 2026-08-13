# Ghostty Config — Gruvbox 琥珀光子主题

个人 Ghostty 终端配置：Gruvbox 暖色系 + 毛玻璃窗口 + 自定义 shader 特效。

## ✨ 效果

- **主题**：Gruvbox Dark 复古暖色（琥珀橙黄系，护眼）
- **毛玻璃窗口**：82% 透明度 + 40 模糊半径 + Catppuccin Mocha 同色系渐变背景图
- **自定义 shader**（`shaders/photon.glsl`）：
  - 边缘光子流光：两团光斑沿边框连续绕行，金 → 橙 → 火红渐变，转角无缝
  - 背景游荡光斑：6 颗光斑在窗口内自由游荡，撞边弹性反弹，各自独立明灭
  - 光标暖光晕 + 微光拖尾
  - 轻扫描线 + 柔和暗角
- **标题栏一体化**：透明标题栏 + 自定义 macOS 图标（Gruvbox 金黄幽灵）

## 📦 安装

```bash
git clone https://github.com/geeyu/ghostty-config.git
cd ghostty-config
# 备份现有配置
cp -r ~/.config/ghostty ~/.config/ghostty.bak
# 覆盖安装（或手动合并 config 中的所需项）
cp -r . ~/.config/ghostty/
```

> 也可只把 `config` 中需要的配置项合并进你的 `~/.config/ghostty/config`，
> 再把 `background.png` 和 `shaders/` 目录复制过去即可。

## 🎨 Shader 调参速查

编辑 `~/.config/ghostty/shaders/photon.glsl` 后按 `Cmd+Shift+,` 重载配置即可生效：

| 参数 | 位置 | 说明 |
|---|---|---|
| `t * 2.0` | 流光速度 | 越大越快（`1.0` ≈ 6 秒绕一圈） |
| `t * 1.2` | 呼吸速度 | 约 5 秒一次呼吸 |
| `t * 0.05` | 渐变流转 | 20 秒转一圈 |
| `i < 6` | 光斑数量 | 调整背景游荡光斑个数 |
| `vec3 amber/ember/flame` | 配色 | 金黄 / 橙 / 火红渐变 |

## ⌨️ 快捷键

| 按键 | 功能 |
|---|---|
| `Cmd+←` / `Cmd+→` | 切换标签页 |
| `F2` | 全局呼出/隐藏窗口 |
| `Cmd+Shift+,` | 重载配置（shader 热更新） |

## 📁 结构

```
ghostty-config/
├── config           # 主配置
├── background.png   # 渐变背景图
└── shaders/
    ├── photon.glsl  # 主特效 shader（流光 + 光斑 + 光标光晕）
    └── scanlines.glsl
```

## 📄 License

MIT
