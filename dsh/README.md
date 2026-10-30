# Lemo-Opuscar · DeepSeek Harness 版

把 [lemomo-ai/lemo-opuscar](https://github.com/lemomo-ai/lemo-opuscar) 改造成 DeepSeek Harness 能直接用的技能。
风格库、导演方法、渲染工具链全部保留；换掉的只是**入口、安装方式和提问工具**。

## 安装

```sh
cd <这个仓库>
sh dsh/install.sh
```

它会在 `~/.agents/skills/lemo-opuscar` 建一个软链接，指向 `dsh/skills/lemo-opuscar`。
之后 `git pull` 不用重装。

重开一个 Harness 会话，技能就会出现在技能目录里。

## 用

直接说要什么就行：

> 做一支 45 秒的水彩风格短片，讲我家那片咖啡园。温暖的女声旁白。

> 用「点云测绘」风格做一支 40 秒的片子，讲我们镇子后山那个老采石场，用公开的激光扫描数据。

第一次运行会自动把风格库装到 `~/lemo-opuscar`（约几十 MB 的稀疏克隆），再装核心依赖（约 350 MB）。

风格可以中英文点名：`水彩笔刷` / `Watercolor Brush` / `watercolor` 都认。

## 目录里都有什么

| 路径 | 作用 |
|---|---|
| `dsh/skills/lemo-opuscar/SKILL.md` | 技能入口（Harness 读的就是它） |
| `dsh/skills/lemo-opuscar/scripts/setup.sh` | 拉取/更新风格库、装依赖 |
| `dsh/install.sh` · `dsh/uninstall.sh` | 装/卸软链接 |
| `dsh/DEEPSEEK.md` | **模型适配指南，出片前先读** |
| `AGENTS.md` | agent 的工作流程（核心规则） |
| `DIRECTOR.md` | 导演方法：故事、声音、节奏、镜头、自检 |
| `TECHNIQUE.md` | 技术实现：逐帧渲染、配音、配乐、混音 |
| `styles/<slug>/STYLE.md` | 66 种风格各自的规范 |
| `core/` | 渲染、TTS、语音回校、采样器、拟音、混流工具 |
| `MY-STYLES.md` | 把库里的风格改成自己的 |

## 和上游的差异

- **入口**：`plugin/skills/lemo-opuscar/` → `dsh/skills/lemo-opuscar/`，`SKILL.md` 按 DSH 的 frontmatter 规则重写（`name` + `description` + `whenToUse`）。
- **安装**：不再用 `claude plugin marketplace`，改为软链接进 `~/.agents/skills`。删掉了 `.claude-plugin/`（marketplace 和 plugin 清单）和 `CLAUDE.md`。
- **提问工具**：`AskUserQuestion` → `ask_user_question`（`AGENTS.md`、`MY-STYLES.md`）。
- **默认仓库**：`setup.sh` 默认从本 fork 拉库，不再是上游地址。想临时切回上游：`LEMO_OPUSCAR_REPO=https://github.com/lemomo-ai/lemo-opuscar.git sh dsh/skills/lemo-opuscar/scripts/setup.sh`。
- **新增**：`dsh/README.md`、`dsh/DEEPSEEK.md`、`install.sh`/`uninstall.sh`。

风格文件、`core/`、`DIRECTOR.md`、`TECHNIQUE.md` 的内容**没有改**。

## 同步上游

```sh
git remote add upstream https://github.com/lemomo-ai/lemo-opuscar.git   # 只需一次
git fetch upstream
git merge upstream/main
```

容易冲突的是被我们改过的几处：`AGENTS.md`、`MY-STYLES.md`、`README*.md`、`TECHNIQUE.md`、`core/README.md` 里的安装路径，以及 `dsh/skills/lemo-opuscar/`（上游对应 `plugin/skills/lemo-opuscar/`）。
`styles/`、`core/` 的实质代码基本不会冲突——上游一周能加好几种风格，那些都能干净合并。

## 环境要求

Node 20+、ffmpeg 7+（6.1 的 `loudnorm` 会误报音频长度，导致混流被拒）、Python 3.11+ 或 uv。
本机实测：Node 22.22、ffmpeg 7.1、uv 0.12 都够；系统 Python 3.10 偏低，但 `setup.sh` 会用 uv 拉 3.12 建 venv，不影响。

## 排错

- **`npm ECONNRESET`**：装依赖时大包下载被掐断，重跑一次 `sh <技能目录>/scripts/setup.sh deps` 即可；网络差就加环境变量 `npm_config_fetch_retries=6`。
- **渲染时报素材 404**（比如 `paper.jpg`、`fonts/f10.woff2`）：demo 源码不自带素材，`DEMO.md` 末尾的「One-time asset scripts」写了生成命令（`python paper.py`、`node fetch_fonts.mjs`）。这些只在你直接预览 demo 时才需要；跟着 agent 做自己的片子不影响。
- **`! missing: ffmpeg7+`**：Ubuntu 24.04 自带 6.1 太旧，换[静态构建](https://johnvansickle.com/ffmpeg/)。
- **技能没出现在 Harness 里**：确认软链接在 `~/.agents/skills/lemo-opuscar`，且它指向的 `SKILL.md` 里 `name: lemo-opuscar`。

## 卸载

```sh
sh dsh/uninstall.sh
```

只删软链接。风格库 `~/lemo-opuscar`、你自己存的风格 `~/lemo-my-styles`、以及这个仓库都保留。
