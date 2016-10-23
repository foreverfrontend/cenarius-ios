# Cenarius-iOS

[![IDE](https://img.shields.io/badge/XCode-8-blue.svg)]()
[![iOS](https://img.shields.io/badge/iOS-8.0-blue.svg)]()
[![Language](https://img.shields.io/badge/language-ObjC-blue.svg)](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html)

**Cenarius** 是一个针对移动端的混合开发框架。现在支持 Android 和 iOS 平台。`Cenarius-iOS` 是 Cenarius 在 iOS 系统上的客户端实现。

通过 Cenarius，你可以使用包括 javascript，css，html 在内的传统前端技术开发移动应用。Cenarius 的客户端实现 Cenarius Container 对于 Web 端使用何种技术并无要求。

Cenarius-iOS 现在支持 iOS 8 及以上版本。


## Cenarius 简介

Cenarius 包含三个库：

- Cenarius Web ：[https://github.com/macula-projects/cenarius-web](https://github.com/macula-projects/cenarius-web)。

- Cenarius Android：[https://github.com/macula-projects/cenarius-android](https://github.com/macula-projects/cenarius-android)。

- Cenarius iOS：[https://github.com/macula-projects/cenarius-ios](https://github.com/macula-projects/cenarius-ios)。

## 安装

### 安装 Cocoapods

[CocoaPods](http://cocoapods.org) 是一个 Objective-c 和 Swift 的依赖管理工具。你可以通过以下命令安装 CocoaPods：

```bash
$ gem install cocoapods
```

### Podfile

```ruby
target 'TargetName' do
pod 'Cenarius'
end
```

然后，运行以下命令：

```bash
$ pod install
```


## 使用

你可以查看 Demo 中的例子。了解如何使用 Cenarius。Demo 给出了完善的示例。

### 配置 CNRSConfig

#### 设置远程文件目录 api：

```objective-c
[CNRSConfig setRemoteFolderUrl:[NSURL URLWithString:@"http://172.20.70.80/hybrid"]];
```

Cenarius 使用 uri 来标识页面。提供一个正确的 uri 就可以创建对应的 CNRSViewController。路由表提供了每个 uri 对应的 html 资源的哈希值。Demo 中的路由表如下：

```json
[
  {
    "uri": "build/index.html",
    "hash": "8c16c85d8e2ca8b7088c68be17ea8b61"
  },
  {
    "uri": "build/index.js",
    "hash": "70c84eebd1833611da8dd65d5dedc3ff"
  }
]
```

#### 设置预置资源文件路径

```objective-c
[CNRSConfig setRoutesResourcePath:@"hybrid"];
```

使用 Cenarius 一般会预置一份路由表，以及资源文件在应用包中。这样就可以减少用户的下载，加快第一次打开页面的速度。在没有网络的情况下，如果没有数据请求的话，页面也可访问。这都有利于用户体验。

注意，如果设置了预置资源文件路径，即意味着在应用包内预置一份资源文件。这个文件夹需要是 folder references 类型，即在 Xcode 中呈现为蓝色文件夹图标。创建方法是将文件夹拖入 Xcode 项目，选择 Create folder references 选项。

#### 设置缓存路径

```objective-c
[CNRSConfig setRoutesCachePath:@"com.macula-projects.CenariusDemo.cenarius"];
```

以上配置设置了缓存路径。缓存文件夹存在的目的也是减少资源文件的下载次数，加快打开页面的速度。使得用户可以得到近似原生页面的页面加载体验。

缓存资源文件一般会出现在 Cenarius 部署了一次路由表的更新之后。这也是 Cenarius 支持`热部署`的方法：由路由表控制资源文件的更新。一般可以让应用定期访问路由表。比如，在开启应用时，或者关闭应用时更新路由表。更新路由表的方法如下：

```objective-c
[CNRSViewController updateRouteFilesWithCompletion:nil];
```

如果，新的路由表中出现了 html 文件的更新，或者出现了新的 uri。也就是说这些文件并不存在于预置资源文件夹中，Cenarius Container 就会在下载完路由表之后，主动下载新资源，并将新资源储存在缓存文件夹中。

#### 预置资源文件和缓存文件关系

正常程序逻辑下，预置资源文件夹存在的资源，就不会再去服务器下载，也就不会有缓存的资源文件。

在进入一个 CNRSViewController 时，会读取资源文件。在读取时，Cenarius Container 先读取缓存文件，如果存在就使用缓存文件。如果缓存文件不存在，就读取预置资源文件。如果，预置资源文件也不存在。CNRSViewController 会尝试更新一次路由表，下载路由表中新出现的资源，并再次尝试读取缓存资源文件。如果仍然不存在，就会出现页面错误。

读取顺序如下：

1. 缓存文件夹中读取 html 文件；
2. 预置资源文件夹中读取 html 文件；
3. 重新下载路由表 Routes.json，遍历路由表将新的 html 文件下载到缓存文件夹。再次尝试从缓存文件夹读取 html 文件；

以上三步中，任何一步读取成功就停止，并返回读取的结果。如果，三步都完成了仍没有找到文件，就会出现页面错误。

有了预置资源文件和缓存文件的双重保证，一般用户打开 Cenarius 页面时都不会临时向服务器请求资源文件。这大大提升了用户打开页面的体验。

### 使用 CNRSViewController

你可以直接使用 `CNRSViewController` 作为你的混合开发客户端容器。或者你也可以继承 `CNRSViewController`，在 `CNRSViewController` 基础上实现你自己的客户端容器。

## 使用 CNRSWebViewController 和 CDVViewController

CNRSWebViewController 和 CDVViewController 继承于 CNRSViewController。

CNRSWebViewController 提供基础的 html 容器功能。CDVViewController支持Cordova功能。实际开发中应按照需求选择。

为了初始化 CNRSWebViewController 和 CDVViewController，你只需要一个 uri。在路由表中可以找到这个 uri。这个 uri 标识了该页面所需使用的资源文件的位置。Cenarius Container 会通过 uri 在路由表中寻找对应的资源文件。

```objective-c
[super openWebPage:@"build/index.html" parameters:nil];
[super openCordovaPage:@"build/index.html" parameters:nil];
```

CNRSWebViewController 支持加载轻应用，你只需要一个 url。

```objective-c
[super openLightApp:@"https://www.baidu.com/" parameters:nil];
```

CDVViewController 支持打开原生 class，你只需要一个 className。
```objective-c
[super openNativePage:@"NativeView" parameters:nil];
```
这里有一个约定，在 iOS 中 NativeView 表示 NativeViewController，在 Android 中 表示 NativeViewActivity。

## 定制你自己的 Cenarius Container

首先，可以继承 `CNRSWebViewController` 或 `CDVViewController`，在此基础上以实现你自己客户端容器。

我们暴露了三类接口。供开发者更方便地扩展属于自己的特定功能实现。

### 定制 CNRSWidget

Cenarius Container 提供了一些原生 UI 组件，供 Cenarius Web 使用。CNRSWidget 是一个 Objective-C 协议（Protocol）。该协议是对这类原生 UI 组件的抽象。如果，你需要实现某些原生 UI 组件，例如，弹出一个 Toast，或者添加原生效果的下拉刷新，你就可以实现一个符合 CNRSWidget 协议的类，并实现以下三个方法：`canPerformWithURL:`，`prepareWithURL:`，`performWithController:`。

在 Demo 中可以找到一个例子：`CNRSNavTitleWidget` ，通过它可以设置导航栏的标题文字。

```Objective-C
@interface CNRSNavTitleWidget ()

@property (nonatomic, copy) NSString *title;

@end


@implementation CNRSNavTitleWidget

- (BOOL)canPerformWithURL:(NSURL *)URL
{
    NSString *path = URL.path;
    if (path && [path isEqualToString:@"/widget/nav_title"]) 
    {
        return true;
    }
    return false;
}

- (void)prepareWithURL:(NSURL *)URL
{
    self.title = [[URL cnrs_queryDictionary] cnrs_itemForKey:@"title"];
}

- (void)performWithController:(CNRSViewController *)controller
{
    if (controller) 
    {
        controller.title = self.title;
    }
}

@end
```

## License

Cenarius is released under the MIT license. See LICENSE for details.
