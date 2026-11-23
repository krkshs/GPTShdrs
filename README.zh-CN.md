# GPTShdrs

[English](README.md) | [Русский](README.ru.md) | **简体中文**

这是一个使用 AI 为 Minecraft 制作写实光影的实验。项目将根据实际游戏测试的反馈持续改进。

**0.1.0-alpha.1 · Minecraft Java 1.16.5 · OptiFine。** 源代码为本项目编写，采用 MIT 许可证。

首次游戏测试使用的电脑配置：

- 显卡：**NVIDIA GeForce RTX 3050 Laptop GPU，4 GB 显存**。
- 内存：**16 GB**。
- 处理器：**Intel Core i5-12450H**。

## Alpha 1 功能

- 太阳和月亮阴影，支持阴影边缘滤波和距离调节。
- 在线性颜色空间计算光照：暖色阳光和火把光、冷色天空光。
- 屏幕空间环境光遮蔽（SSAO）与 Minecraft 平滑光照。
- 程序化天空、日落、太阳和月亮圆盘、星星。
- 大气雾、水下雾，以及下雨时的阴天光照。
- 水面细小波浪、动态法线、高光和菲涅耳天空反射。
- 草、花、作物和树叶的风动画；湿润表面的轻微高光。
- HDR、Bloom 泛光、ACES 色调映射、FXAA，以及曝光和饱和度调节。
- LOW、BALANCED、HIGH 三种预设；光影设置菜单提供俄语和英语。

本次 Alpha 主要面向主世界。**下界和末地通过维度文件夹禁用光影，使用 OptiFine 的原版渲染回退。** 水面目前只反射天空，尚未实现方块反射、折射、体积云、光线追踪和 PBR。Iris 以及增加其他维度的模组尚未测试。

## 安装

1. 安装 Minecraft Java **1.16.5** 和 OptiFine；建议使用 **HD U G8** 或适用于 1.16.5 的更新版本。
2. 构建后，从 `dist` 文件夹获取 **GPTShdrs-0.1.0-alpha.1.zip**。
3. 在游戏中打开 **选项 → 视频设置 → 光影 → 光影文件夹**。英文菜单为 **Options → Video Settings → Shaders → Shaders Folder**。
4. 将 ZIP 放入打开的 `shaderpacks` 文件夹。**无需解压。**
5. 返回游戏并选择 GPTShdrs。ZIP 内的 `shaders` 文件夹已经位于正确的根目录层级。

也可以将源代码项目文件夹复制到 `shaderpacks/GPTShdrs`，确保 `shaders` 直接位于该文件夹内。GitHub 下载的源代码 ZIP 还有一层外部文件夹，需要先解压。

## 首次测试设置

对于 RTX 3050 Laptop 4 GB、Core i5-12450H 和 16 GB 内存，建议先使用 **BALANCED**、**1920×1080**、**10–12 区块**视距和默认材质。关闭 Render Regions。OptiFine 的渲染质量和阴影质量设为 **1×**，OptiFine 抗锯齿设为 **OFF**，旧版光照设为 **OFF** 或 Default。本光影已包含 FXAA。

BALANCED 使用 **2048×2048 阴影 / 96 格阴影距离 / 8 次采样**，开启 SSAO、Bloom 和水面效果。若帧率不足，请选择 **LOW**：**1024×1024 / 64 格 / 4 次采样**，关闭 SSAO 和 Bloom。

**目前尚未测量实际帧率。** 以上设置只是起点；性能也会受到处理器负载、分辨率、模组和笔记本功耗限制的影响。

## 首次测试报告

测试路线和报告模板：[docs/TESTING.md](docs/TESTING.md)（俄语）。

请提供 OptiFine 的准确版本、分辨率、预设、视距、FPS，以及白天、日落、夜晚、水边和洞穴内的截图。若出现红色光影错误，请提供完整错误文字和游戏目录下 `logs/latest.log` 中的相关片段。

GLSL 编译成功只说明语法和顶点／片元阶段接口检查通过。OptiFine 中的加载、画面和性能仍需实际游戏测试确认。

## 开发与构建

需要 **Python 3.10+**。构建仅使用 Python 标准库：

```powershell
py -3 tools/build_pack.py
```

检查光影包结构、包含文件、菜单选项和预设：

```powershell
py -3 tools/validate_shaders.py
```

编译所有预设和效果开关组合需要 [glslang](https://github.com/KhronosGroup/glslang/releases)。将 `glslang` / `glslangValidator` 加入 PATH，将 Windows 版本解压到 `.tools/glslang`，或者明确指定路径：

```powershell
py -3 tools/validate_shaders.py --validator "C:/tools/glslang/bin/glslang.exe" --all-options --require-compiler
```

没有编译器时，普通检查会明确提示已跳过编译；使用 `--require-compiler` 则会报错退出。构建脚本只检查包结构，发布前需要单独执行编译检查。

ZIP 和 SHA-256 文件生成于 `dist`。ZIP 包含光影、许可证和三种语言的 README 文档，不包含 Git、工具或缓存。相同源文件会生成完全相同的 ZIP。

架构说明：[docs/DEVELOPMENT.md](docs/DEVELOPMENT.md)（俄语）。更新记录：[CHANGELOG.md](CHANGELOG.md)（俄语）。
