
# N1nEArch - 我的 Arch Linux 配置 ✨
![Platform](https://img.shields.io/badge/platform-ArchLinux-blueviolet)
![Forks](https://img.shields.io/github/forks/N1nEmAn/N1nEArch)
![Stars](https://img.shields.io/github/stars/N1nEmAn/N1nEArch)
![logol](https://github.com/user-attachments/assets/0453049c-ab69-42c0-bf82-d8b4871e52e0)


这是一个包含我个人 Arch Linux 配置文件的仓库。希望它能帮助你快速打造一个高效、美观的桌面环境！🚀

**灵感来源：**
这个配置改进自 [@CuB3y0nd](https://github.com/CuB3y0nd) 的 [1llusion](https://github.com/CuB3y0nd/1llusion) 项目，在此特别感谢！🙏

## ✨ 特别提示 ✨

- 如果你正在安装新的机器，可以参考 [CuB3y0nd 的安装笔记](https://www.assembly.rip/posts/linux/archlinux-configure-note/) 📝 。到 `Bspwm` 章节的时候或者之后，再来安装本脚本即可！
- 如果你对视频中最后不输密码就可以解锁的方式（**指纹解锁**！👆）感兴趣，可以参考 [这个方案](https://www.cnblogs.com/9man/p/18951122) ，而对应的配置也大多已经配好，你只需要做一点录入指纹之类的操作即可！
- 如果你对**远程控制** 🎮 感兴趣，性价比最高方案是直接在不同设备安装 [Tailscale](https://github.com/tailscale/tailscale) 从而达到 `p2p` 连接的效果，然后使用 [RustDesk](https://github.com/rustdesk/rustdesk) 进行连接即可！如果特别感兴趣，可以参考性能最强方案 [阳光月光连接](https://www.cnblogs.com/9man/p/18635994)。
- 以上提到的软件包均可直接用 `yay` 或者 `paru` 安装，简单，方便！📦
- 如果你正在尝试安装和使用，欢迎[与我进行交流](https://github.com/N1nEmAn/)！☎️

## 预览
由于此次预览来自我的新电脑 **ThinkPad X1 Nano** 💻，其屏幕尺寸较小，有一些没有录制成功（真的吗？ 🤔）。不过问题不大，欢迎自己下载体验！

<video src="https://github.com/user-attachments/assets/08f341ae-4ee3-4628-b3ed-2f90927f659e" autoplay loop muted></video>


## 安装



要安装和应用我的配置，只需克隆本仓库并运行安装脚本：

```bash
git clone https://github.com/N1nEmAn/N1nEArch.git
cd N1nEArch
chmod +x install.sh
./install.sh
```

如果是第一次使用，安装完后输入 `x` 回车即可享受！🎉

其中，按键 `alt` + `F1` 查看快捷键说明，在`~/.config/bspwm/sxhkdrc`中自定义快捷键——按键 `super` + `Esc` 应用。当然如果你把应用快捷键的快捷键改了，那刚才这个快捷键就不管用了。

关于鼠标主题的配置需要你在`~/.Xresources`中写下：
```sh
Xft.dpi: 135
Xcursor.theme: Qogirr 
Xcursor.size: 32
```

其中的135调成你认为合适的缩放。

不写可能也行，光标主题满意即可。

⚠️ 注意：

- `install.sh` 脚本会引导您完成软件包的安装和配置文件的复制。
- 脚本在执行过程中会进行**交互式确认** 💬，并提供**备份现有配置**的选项 💾，以避免数据丢失。
- 运行脚本前，请确保您已安装 `yay`（或 `paru`，脚本会自行检测并建议安装）。
- 安装完成后，您可能需要**重启您的桌面会话或电脑** 🔄 以使所有更改生效。

-----

## 📦 包含的配置

本仓库主要包含以下组件的配置文件：

- **窗口管理器：** bspwm 🧱
- **状态栏：** Polybar 📊
- **终端模拟器：** Alacritty, Kitty 🖥️
- **Shell：** Zsh (含 Zinit 配置) 🐚
- **文件管理器：** Ranger, Yazi, Nemo 📁
- **输入法：** Fcitx5 ✍️
- **通知：** Dunst 🔔
- **应用启动器：** Rofi, jgmenu 🔍
- **以及其他系统工具和美化设置。** ✨

## ⚙️ 功能与快捷键简介

最基础的，当然是`alt` + `shift` + `enter` 打开终端了！

这套配置的核心是通过一系列自定义脚本和精心配置的快捷键，打造流畅且高效的个性化操作体验。下面是部分特色功能的简介：


### 📸 截图与捕捉 (Screenshot & Capture)



集成了强大的 `flameshot` 工具并封装了快捷操作，满足你各种场景下的截图需求。

- **区域截图 & 编辑 (`Print` 或 `ctrl` + `alt` + `s`)**
  - 启动 `flameshot` 的图形界面，可以自由选择截图区域，并直接使用其丰富的工具集（如箭头、文字、模糊、高亮）进行标注和编辑。
- **截图 OCR 文字识别 (`ctrl` + `alt` + `w`)**
  - **[王牌功能]** 这不仅仅是截图，更是生产力工具！框选屏幕任意区域后，脚本会自动调用 Tesseract OCR 引擎识别图片中的文字，并将结果直接复制到你的剪贴板。阅读扫描版 PDF、观看视频教程、摘抄代码片段时极为方便！
- **延时截图 (`alt` + `Print`)**
  - 按下快捷键后，会在 10 秒后截取整个屏幕。这为你准备需要特定状态（如鼠标悬停菜单）的截图提供了充足时间。



### 🎨 外观与定制 (Appearance & Customization)



提供多种选项让你随时改变桌面观感，保持新鲜感。

- **主题选择器 (`alt` + `space`)**
  - 一键调用 `Rofi` 菜单，快速切换整套 Rice（包括 Polybar、壁纸、终端、GTK 等）的色彩主题。
- **窗口透明度调节 (`ctrl` + `shift` + `plus` / `minus`)**
  - 动态增加或减少当前聚焦窗口的透明度。使用 `ctrl` + `shift` + `r` 可以一键重置为默认值。
- **随机壁纸切换 (`super` + `shift` + `w`)**
  - 从当前主题的壁纸文件夹中随机选择一张并应用。
- **状态栏显隐 (`super` + `h`/`u`)**
  - 临时隐藏/显示 `Polybar` 状态栏，让你获得更沉浸、无干扰的视图。



### 🚀 效率工具 (Productivity Tools)



为高频操作提供了捷径。

- **浮动暂存终端 (Scratchpad) (`alt` + `shift` + `s`)**
  - 从屏幕上方一键呼出或隐藏一个悬浮终端 (`tdrop`)。非常适合执行临时命令或作为日志监视窗口，不干扰当前工作流。
- **快捷键速查 (`super` + `F1`)**
  - 随时按下此组合键，会弹出一个清晰的快捷键帮助菜单 (`jgmenu`)，方便快速查阅所有已定义的快捷键。
- **模糊锁屏 (`super` + `l`)**
  - 一个带有毛玻璃模糊效果的安全锁屏脚本，颜值与安全并存。



### 🪟 窗口管理 (Window Management)



充分利用 `bspwm` 的平铺窗口管理能力。

- **切换窗口状态 (`super` + `f` / `s` / `t`)**
  - 将当前窗口在 **全屏 (fullscreen)**、**浮动 (floating)** 和 **平铺 (tiled)** 模式之间快速切换。
- **均衡窗口 (`super` + `equal` / `minus`)**
  - `super + equal`: 将当前工作区所有窗口调整为均等大小。
  - `super + minus`: 重新平衡窗口分割比例。
- **旋转与循环 (`super` + `ctrl` + `r`)**
  - 循环旋转当前容器内的窗口布局（垂直/水平切换）。
- **关闭窗口/进程 (`ctrl` + `q` / `ctrl` + `shift` + `q`)**
  - `ctrl + q`: 优雅地关闭当前窗口 (`bspc node -c`)。
  - `ctrl + shift + q`: 强制杀死当前窗口进程 (`bspc node -k`)。


## 📝 后记

此时已经是深夜，我带着大学最后一学期的匆忙，满怀热情的雕琢的我的新电脑 **ThinkPad X1 Nano** 💻。

我知道这台电脑将会给我带来很多新的变化，907g的重量便携，意味着更多的使用场景；`tailscale`加上`rustdesk`的远控方案，则意味着更强的性能加持。

给它配置的路上，也给我原来的 **ThinkBook 16+** 💻有了进一步的升级，可谓一箭双雕；此时开源之，如果能帮助到更多人，更是一箭多雕。

再次感谢 [@CuB3y0nd](https://github.com/CuB3y0nd) 师傅的慷慨与激情，才有了这个项目。

即将凌晨五点了，青岛已是日出，望你我未来亦是。

——2025.6.27 凌晨四点五十一
