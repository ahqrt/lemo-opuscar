---
name: lemo-opuscar
description: 用代码做短片：在 66 种影片风格里选一种，把用户的选题做成 30–60 秒成片——画面用 canvas/WebGL 逐帧渲染，配乐和人声全部由代码生成，不用视频模型、不用素材库。当用户要做视频、短片、动画、宣传片、科普解说、数据影像、产品拆解（视频、短片、动画、宣传片、数据解说、科普、产品拆解），或点名某个影片风格（水彩、水墨、浮世绘、油画厚涂、瑞士动态排版、卫星简报、点云测绘、孟菲斯微缩景观等），或想把库里的风格改成自己的、从空白做一个新风格、用自己存过的风格时使用。Use when the user asks for a video, film, short, promo, explainer or animation, in a named style or not, including explainers built from real material (satellite imagery, laser scans, CAD, archive scans); or wants to change a style into their own. 不用于单纯剪辑、裁剪、转码用户已有的视频文件。
whenToUse: 用户提出「做一支……视频/短片/动画/宣传片」，或点名某个影片风格，或要改造、新建风格时。
---

# Lemo-Opuscar（DeepSeek Harness 版）

风格库、导演方法和渲染工具都在 Lemo-Opuscar 库里。这个技能负责拿到库，然后把活交给它。

1. **拿到库。** 运行 `sh "<技能目录>/scripts/setup.sh"`。它负责 clone 或更新风格库（默认 `~/lemo-opuscar`；如果你正站在一份库里，直接用那份），最后一行打印 `LIB=<路径>`。
2. **尽早装核心依赖。** 马上把 `sh "<技能目录>/scripts/setup.sh" deps` 放到**后台**跑（第一次要几分钟）。需要配音时之后再补 `deps voice`，需要拨弦乐器时补 `deps music`，别提前装（见 `$LIB/TECHNIQUE.md` §1）。系统工具缺失（Node / ffmpeg / Python）只在你那一轮提问里告诉用户，**不要自己装系统软件**。某个风格独有的包（它的 `STYLE.md` 会写明）由你装进项目目录。
3. **按库里的规矩办。** 读 `$LIB/AGENTS.md`，照它执行，从 **Start** 开始（先看用户自己存的风格 `~/lemo-my-styles/`；用户什么都没说时，先问语言，再给几个入口）：找风格或做自己的风格 → 一轮提问 → treatment → 制作 → 交付。

**技能目录**就是这份 `SKILL.md` 所在的目录，它通常是 `~/.agents/skills/lemo-opuscar` 指向本仓库的软链接。先取真实路径再拼脚本：

```sh
SKILL_DIR=$(cd -P "<本文件所在目录>" && pwd -P)
sh "$SKILL_DIR/scripts/setup.sh"
```

## 在 Harness 里跑，和上游文档有哪些出入

| | 说明 |
|---|---|
| **项目文件夹** | 用户在哪个目录发起，片子就建在那儿：`<name>/`（小写字母、数字、连字符；路径别带 `#` 和 `?`）。上游文档里写 `films/<name>/` 的地方，一律读作这个文件夹 |
| **跑工具** | 一律从 `$LIB` 跑，项目给绝对路径：`cd "$LIB" && node core/render/still.mjs "<项目绝对路径>" 1.5 3` |
| **页面里的库文件** | 用绝对 URL：`/core/lib.js`、`/node_modules/three/…`（项目被服务在 `/@film/`） |
| **脚本和 `build.sh` 里的库文件** | 用 `$LIB/…`，并在 `build.sh` 顶部写 `LIB=<路径>`；**不要**用 `../..` |
| **demo 源码** | 默认不下。等 `TREATMENT.md` 写完，才 `sh "<技能目录>/scripts/setup.sh" demo <slug>` 取来学技术；它不是拿来渲染的 |
| **交付** | 把 `$LIB/DIRECTOR.md` §11 列的东西都放进项目文件夹，然后告诉用户在哪 |

## Harness 工具对照（上游是按 Claude Code 写的）

| 上游写法 | 在这里用 |
|---|---|
| `AskUserQuestion` 工具 | `ask_user_question`（选项 2–3 个，推荐项排第一并标「推荐」） |
| 斜杠命令 `/lemo-opuscar:lemo-opuscar` | 本技能按 description 自动触发；用户直接说要什么也可以 |
| 后台跑命令 | `bash` 带 `run_in_background: true`，再用 `job_output` 收结果 |
| 任务清单 | `todo_write` |
| 派子任务 | `subagent` / `subagent_fork` |

## 上游警告过的那件事

66 种风格是按 Claude Opus 5.5 调校的，上游明说「别的模型可能复现不好」。这里的运行模型不同，**第一次出片前先把 [`dsh/DEEPSEEK.md`](../../DEEPSEEK.md) 读一遍**：它写了加固做法（先小后大、三道检查闸、降级路径）。别一上来就冲整片。
