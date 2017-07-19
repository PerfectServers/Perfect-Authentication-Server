# Perfect Local Authentication App Template (PostgreSQL)

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat" alt="Swift 3.1">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>

## Perfect 服务器应用开发模板项目

本项目可以作为服务器应用开发模板，采用Swift Package Manager软件包管理器编译，编译成功后会得到一个内容为HTTP服务器的可执行文件。

本项目包含了一组可以直接使用的用户身份验证函数接口路由，可以设置登录会话过程，并使用PostgreSQL数据库作为管理后台。

您只需配置好 `/config/ApplicationConfiguration.json` 文件即可运行。

该系统架构的设计支持大型服务器项目，包含HTTP服务器配置、分开管理的过滤器和路由系统、JSON配置读取方法，以及配套服务器文件路径用于管理您的自定义句柄、对象和工具类函数。。

## Swift 兼容性

目前本项目支持 **Xcode 8.3** 或 Ubuntu **Swift 3.1** 工具链。

## 编译和运行

执行下列bash命令可以建立模板项目并在8181端口上运行服务器。

```
git clone https://github.com/PerfectlySoft/Perfect-Local-Auth-PostgreSQL-Template.git
cd Perfect-Local-Auth-PostgreSQL-Template
swift build
.build/debug/PerfectLocalAuthPostgreSQLTemplate
```

如果没问题的话应该看到下列输出：

```
[INFO] Starting HTTP server localhost on 0.0.0.0:8181
```

这意味着服务器准备好，您可以浏览 [http://localhost:8181/](http://localhost:8181/) 查看欢迎信息。在控制台上执行 control-c 组合键停止服务器运行。

## 服务器基本内容

该模板应用中包含以下目录：

#### config

该文件夹用于服务器配置，包含两个文件：`ApplicationConfiguration_copy.json` 和 `ApplicationConfigurationLinux.json`。修改了这些文件的配置信息后，请在您的`config/Config.swift`文件中追加已修改配置的文件名，即可使配置生效。

您可以为这两个文件制作副本，把 `ApplicationConfiguration_copy.json` 副本重命名为 `ApplicationConfiguration.json` 即可生效。

#### webroot

该文件夹用于存储静态页面和 Mustache 模板脚本

### 源代码管理

#### / configuration

本文件夹下内容用于管理应用程序配置，包括配置选项、路由和过滤器。

#### / handlers

该文件夹用于为JSON和Web路由存放句柄函数。

#### / objects

该目录用于存放各种自定义的数据结构和数据对象。其中还包括一个 `initializeObjects.swift`文件用于初始化各数据结构。

#### / utility

您可以把工具类和辅助类函数放置在这个文件夹下。


### 问题报告、内容贡献和客户支持

我们目前正在过渡到使用JIRA来处理所有源代码资源合并申请、修复漏洞以及其它有关问题。因此，GitHub 的“issues”问题报告功能已经被禁用了。

如果您发现了问题，或者希望为改进本文提供意见和建议，[请在这里指出](http://jira.perfect.org:8080/servicedesk/customer/portal/1).

在您开始之前，请参阅[目前待解决的问题清单](http://jira.perfect.org:8080/projects/ISS/issues).

## 更多信息
关于本项目更多内容，请参考[perfect.org](http://perfect.org).

## 扫一扫 Perfect 官网微信号
<p align=center><img src="https://raw.githubusercontent.com/PerfectExamples/Perfect-Cloudinary-ImageUploader-Demo/master/qr.png"></p>
