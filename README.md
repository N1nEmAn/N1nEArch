
https://github.com/user-attachments/assets/9c534eb3-d19e-496f-833e-6dec96c88e5d

# N1nEArch - 我的 Arch Linux 配置

这是一个包含我个人 Arch Linux 配置文件的仓库。

**灵感来源：**
这个配置改进自 [@CuB3y0nd](https://github.com/CuB3y0nd) 的 [1llusion](https://github.com/CuB3y0nd/1llusion) 项目，在此特别感谢。

## 预览
由于此次预览来自我的新电脑**ThinkPad X1 Nano**，其屏幕尺寸较小，有一些没有录制成功（真的吗？）。不过问题不大，欢迎自己下载体验！



https://github.com/user-attachments/assets/ba75ed5b-c9bb-4cbb-97cf-b2f35e8166c5



## 安装



要安装和应用我的配置，只需克隆本仓库并运行安装脚本：

```bash
git clone https://github.com/N1nEmAn/N1nEArch.git
cd N1nEArch
chmod +x install.sh
./install.sh
```

**注意：**

  * `install.sh` 脚本会引导您完成软件包的安装和配置文件的复制。
  * 脚本在执行过程中会进行**交互式确认**，并提供**备份现有配置**的选项，以避免数据丢失。
  * 运行脚本前，请确保您已安装 `yay`（或 `paru`，脚本会自行检测并建议安装）。
  * 安装完成后，您可能需要**重启您的桌面会话或电脑**以使所有更改生效。

-----

## 包含的配置

本仓库主要包含以下组件的配置文件：

  * **窗口管理器：** bspwm
  * **状态栏：** Polybar
  * **终端模拟器：** Alacritty, Kitty
  * **Shell：** Zsh (含 Zinit 配置)
  * **文件管理器：** Ranger, Yazi, Nemo
  * **输入法：** Fcitx5
  * **通知：** Dunst
  * **应用启动器：** Rofi, jgmenu
  * **以及其他系统工具和美化设置。**

