//
//  ASPushWithoutAnimationVC.m
//  ASRouter_Example
//
//  Created by Andy on 2017/9/28.
//  Copyright © 2017年 andysheng@live.com. All rights reserved.
//

#import "ADSPushWithoutAnimationVC.h"
#import "ADSAnnotation.h"

@interface ADSPushWithoutAnimationVC ()


@end

@implementation ADSPushWithoutAnimationVC


ADS_REQUEST_MAPPING(ADSPushWithoutAnimationVC, "wfshop://pushWithoutAnimation")
ADS_SHOWSTYLE_PUSH_WITHOUT_ANIMATION
ADS_STORYBOARD("Main", "ADSPushWithoutAnimationVC")

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
