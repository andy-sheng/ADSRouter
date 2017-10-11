# ADSRouter

[![CI Status](http://img.shields.io/travis/andysheng@live.com/ADSRouter.svg?style=flat)](https://travis-ci.org/andysheng@live.com/ADSRouter)
[![Version](https://img.shields.io/cocoapods/v/ADSRouter.svg?style=flat)](http://cocoapods.org/pods/ADSRouter)
[![License](https://img.shields.io/cocoapods/l/ADSRouter.svg?style=flat)](http://cocoapods.org/pods/ADSRouter)
[![Platform](https://img.shields.io/cocoapods/p/ADSRouter.svg?style=flat)](http://cocoapods.org/pods/ADSRouter)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

ADSRouter is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ADSRouter'
```

## Usage

>   Everything you may need to know can be found in the example project.

### 1. ADSRouter的配置

```objc
[[ADSRouter sharedRouter] setVCCacheCapacity:10]; // 缓存的ViewController个数
[[ADSRouter sharedRouter] setRouterInfoCacheCapacity:10]; // 缓存的路由信息的个数
[[ADSRouter sharedRouter] setRouteMismatchCallback:^(ADSURL *url) { // URL无法匹配时的回调
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"url mismatch" message:url.compareString preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"cancle" style:UIAlertActionStyleCancel handler:nil]];
        [application.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }];

```

### 2. 利用ADSRouter提供的宏注册路由信息

#### 支持的宏

* `ADS_REQUEST_MAPPING(className, url)`
   URL到ViewController的映射
   
* `ADS_PARAMETER_MAPPING(className, propertyName, paramName)`
   URL中的参数名到ViewController中属性名的映射
   
* `ADS_PARAMETER_MAPPING_SIMPLIFY(className, propertyName)`
   ADS_PARAMETER_MAPPING的简化版，用属性名充当URL的参数名
   
* `ADS_STORYBOARD(storyBoardName, storyBoardId)`
   如果视图控制来自StoryBoard，用这个宏来注册StoryBoard名和控制器的StoryBoard Id
   
* `ADS_HIDE_NAV`
   
* `ADS_BEFORE_JUMP(beforeJumpBlock)`
   在跳转前执行的Block，可以利用这个Block拦截一些跳转请求。
   
* `ADS_SHOWSTYLE_PUSH_WITH_ANIMATION`
   视图展示的方式为Push，且需要动画
   
* `ADS_SHOWSTYLE_PUSH_WITHOUT_ANIMATION`
   视图展示的方式为Push，不需要动画
   
* `ADS_SHOWSTYLE_PRESENT`
   视图展示的方式为Present
   
* `ADS_SUPPORT_FLY`
   这个视图控制器在创建之后，路由将缓存这个视图控制器，当有新的请求需要跳转到这个视图控制器时，如果被缓存的视图控制器已经不在视图层级中，系统将复用这个视图控制器。

与URL相关的property需要写在.h文件当中

#### 示例

```objc
@interface ADSPushWithAnimationFromCode : UIViewController

@property (nonatomic, copy) NSString *NSStringParam;
@property (nonatomic, assign) int intParam;
@property (nonatomic, strong) NSNumber *NSNumberParam;
@property (nonatomic, strong) NSDecimalNumber *NSDecimalNumberParam;
@property (nonatomic, assign) CGFloat CGFloatParam;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDate *date;

@end
```

在.m文件的implementation区域中注册路由信息。

```objc
@implementation ADSPushWithAnimationFromCode

ADS_REQUEST_MAPPING(ADSPushWithAnimationFromCode, "wfshop://pushWithAnimationFromCode") // 注册URL到ViewController的映射
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, NSStringParam, "nsstring") // 注册URL参数到Property的映射
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, intParam, "int")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, NSNumberParam, "nsnumberparam")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, NSDecimalNumberParam, "nsdecimalnumber")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, CGFloatParam, "cgfloat")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, url, "url")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, date, "date")
ADS_BEFORE_JUMP(^(ADSURL * _Nonnull url, BOOL * _Nonnull abort) {
    *abort = YES;
    [[ADSRouter sharedRouter] openUrl:@"wfshop://present"];
})
ADS_SUPPORT_FLY

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSStringFromClass(self.class);
    [self setUpUI];
}
@end
```

### 3. 页面跳转

```objc
[[ADSRouter sharedRouter] openUrl:@"wfshop://pushWithAnimation?id=1&string=%e5%91%b5%e5%91%b5&nsNumber=1.23"];
```

### 4. 利用ADSRouteInterceptor拦截请求
你可以为ADSRouter设置一个拦截器，对一些符合你的要求的URL进行重定向。

```objc
[[ADSRouter sharedRouter] setRouterInterceptor:self];

- (ADSURL*)intercept:(ADSURL *)url {
    // you can fetch some information from your server here
    if ([self urlMatchesSomeCondition:url]) {
        url = [ADSURL URLWithString:@"wfshop://present"];
    }
    return url;
}

- (BOOL)urlMatchesSomeCondition:(ADSURL*)url {
    if ([url.compareString isEqualToString:@"wfshop://interceptorTest"]) {
        return YES;
    }
    return NO;
}
```

### 4. 目前支持的参数类型

* Bool
* int8_t / uint8_t
* int16_t / uint16_t
* int32_t / uint32_t
* int64_t / uint64_t
* int / unsigned int
* float
* double
* long double
* NSString / NSMutableString
* NSValue
* NSNUmber
* NSDecimalNumber
* NSData / NSMutableData
* NSDate
* NSURL


## Author

Andy Sheng, andysheng@live.com

## License

ADSRouter is available under the MIT license. See the LICENSE file for more info.


