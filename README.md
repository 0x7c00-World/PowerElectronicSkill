# 电力电子工程师技能体系

一套自成体系的电力电子学习文档库。从**电路与系统分析**起步，经**功率变换 → 建模与环路 → 工程与硬件 → 合规与应用**，共 13 篇深度文档，每篇由浅入深、带算例与插图。

> 入门靠拓扑，吃饭靠磁性元件和环路，上限靠器件物理和系统理解。

## 在线浏览

GitHub Pages 已启用，直接打开：

**https://<你的用户名>.github.io/PowerElectronicSkill/**

## 文档地图

| # | 文档 | 内容 |
|---|------|------|
| 0 | [index.html](index.html) | 技能体系总览 · 五层能力地图 · 自检清单 |
| 1 | [circuit-analysis.html](circuit-analysis.html) | 电路与系统分析：网络定理 · 拉普拉斯变换 · 模电数电 |
| 2 | [control-theory.html](control-theory.html) | 控制理论基础：经典控制 · 状态空间 |
| 3 | [electromagnetics.html](electromagnetics.html) | 电磁学与器件物理：磁场与磁路 · 半导体物理 |
| 4 | [power-devices-drivers.html](power-devices-drivers.html) | 功率器件与驱动：SiC · GaN · IGBT · 隔离驱动 |
| 5 | [magnetics.html](magnetics.html) | 磁性元件设计：电感 · 变压器 · 平面磁件 |
| 6 | [small-signal-modeling.html](small-signal-modeling.html) | 小信号建模：状态空间平均法 · PWM switch |
| 7 | [loop-compensation.html](loop-compensation.html) | 环路补偿设计：Type II · III · Bode · 裕度 |
| 8 | [digital-control.html](digital-control.html) | 数字控制实现：DSP · Z 域 · 离散化 |
| 9 | [pcb-power-layout.html](pcb-power-layout.html) | PCB 与功率布局：寄生参数 · 环路面积 · Kelvin |
| 10 | [an136-pcb-layout-cn.html](an136-pcb-layout-cn.html) | AN-136《非隔离开关电源 PCB 布局考量》中文全译 |
| 11 | [thermal.html](thermal.html) | 热管理与散热：热阻网络 · 风冷液冷 · TIM |
| 12 | [measurement.html](measurement.html) | 测试与测量：双脉冲 · 环路分析仪 |
| 13 | [emc-safety.html](emc-safety.html) | EMC 与安规：CISPR · 爬电距离 · 电气间隙 |

## 仓库结构

```
PowerElectronicSkill/
├── index.html                    # 站点入口（总览 + 自检清单）
├── *.html                        # 13 篇主题文档，全站相对链接，可离线双击打开
├── images/                       # 位图插图（原厂手册/应用笔记裁图）
├── figs/                         # 计算生成的 Bode 图等（含 gen_figs.m 生成脚本）
├── bode64.m / bode74.m           # MATLAB 辅助脚本
├── 电力电子技能体系.md             # index.html 的 Markdown 源稿
├── .nojekyll                     # 关闭 Jekyll 处理（Pages 必需）
└── .gitignore
```

## 设计约定

- **单文件自包含**：每篇文档的 CSS / JavaScript 全部内联，不依赖任何外部 CDN，断网也能完整阅读。
- **明暗双主题**：通过 `prefers-color-scheme` 自动跟随系统。
- **插图双轨**：计算类曲线由 MATLAB 脚本生成 PNG 存入 `figs/`，其余位图统一放 `images/`。
- **相对链接**：全站用同级相对路径跳转，因此可部署在任意子路径（如 GitHub Pages 的 `/<仓库名>/`）下而不需改动。

## 本地查看

直接用浏览器打开 `index.html` 即可，无需构建、无需服务器。

## 说明

文档内容整理自公开教材与厂商应用笔记（TI / Infineon / onsemi / Wolfspeed / ADI 等），插图版权归原作者所有，仅供学习交流使用。
