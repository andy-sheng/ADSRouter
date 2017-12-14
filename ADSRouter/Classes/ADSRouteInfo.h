//
//  ASRouterInfo.h
//  annotation-demo
//
//  Created by Andy on 2017/9/25.
//  Copyright © 2017年 andy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADSURL;

typedef NS_ENUM(NSUInteger, ADSVCShowStyle) {
    ADSVCShowStylePush,
    ADSVCShowStylePresent,
};
@interface ADSRouteInfo : NSObject


@property (nonatomic, copy) NSString *clsName;

@property (nonatomic, strong) NSDictionary *paramMapping;

@property (nonatomic, copy) void (^beforeJumpBlock)(ADSURL *url, BOOL * abort);
@property (nonatomic, copy) void(^completion)(void);

@property (nonatomic, assign) BOOL isAwakeFromStoryBoard;

@property (nonatomic, copy) NSString *bundleName;
@property (nonatomic, copy) NSString *storyBoardName;
@property (nonatomic, copy) NSString *storyBoardId;

@property (nonatomic, assign) BOOL hideBottomBar;
@property (nonatomic, assign) BOOL hideNav;
@property (nonatomic, assign) BOOL supportFly;

@property (nonatomic, assign) ADSVCShowStyle showStyle;
@property (nonatomic, assign) BOOL animation;

@end
