//
//  ASPushWithAnimationFromCode.m
//  ASRouter_Example
//
//  Created by Andy on 2017/10/7.
//  Copyright © 2017年 andysheng@live.com. All rights reserved.
//

#import "ADSPushWithAnimationFromCode.h"
#import "ADSAnnotation.h"
#import "ADSRouter.h"
@interface ADSPushWithAnimationFromCode ()

@end

@implementation ADSPushWithAnimationFromCode

ADS_REQUEST_MAPPING(ADSPushWithAnimationFromCode, "wfshop://pushWithAnimationFromCode")
ADS_PARAMETER_MAPPING(ADSPushWithAnimationFromCode, NSStringParam, "nsstring")
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

- (void)setUpUI {
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    
    UILabel *nsStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 100, 50)];
    nsStringLabel.text = @"NSString";
    UILabel *nsString = [[UILabel alloc] initWithFrame:CGRectMake(110, 50, 300, 50)];
    nsString.text = _NSStringParam;
    [self.view addSubview:nsStringLabel];
    [self.view addSubview:nsString];
    
    UILabel *intLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 100, 50)];
    intLabel.text = @"int";
    UILabel *intValue = [[UILabel alloc] initWithFrame:CGRectMake(110, 100, 300, 50)];
    intValue.text = @(_intParam).stringValue;
    [self.view addSubview:intLabel];
    [self.view addSubview:intValue];
    
    UILabel *nsNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 100, 50)];
    nsNumberLabel.text = @"NSNumber";
    UILabel *nsNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 150, 300, 50)];
    nsNumber.text = _NSNumberParam.stringValue;
    [self.view addSubview:nsNumberLabel];
    [self.view addSubview:nsNumber];
    
    UILabel *nsDecimalNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 200, 100, 50)];
    nsDecimalNumberLabel.text = @"NSDecimalNumber";
    UILabel *nsDecimalNumber = [[UILabel alloc] initWithFrame:CGRectMake(110, 200, 300, 50)];
    nsDecimalNumber.text = _NSDecimalNumberParam.stringValue;
    [self.view addSubview:nsDecimalNumberLabel];
    [self.view addSubview:nsDecimalNumber];
    
    UILabel *cgfloatLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 250, 100, 50)];
    cgfloatLabel.text = @"CGFloat";
    UILabel *cgfloatValue = [[UILabel alloc] initWithFrame:CGRectMake(110, 250, 300, 50)];
    cgfloatValue.text = @(_CGFloatParam).stringValue;
    [self.view addSubview:cgfloatLabel];
    [self.view addSubview:cgfloatValue];
    
    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 100, 50)];
    urlLabel.text = @"NSURL";
    UILabel *nsUrl = [[UILabel alloc] initWithFrame:CGRectMake(110, 300, 300, 50)];
    nsUrl.text = _url.absoluteString;
    [self.view addSubview:urlLabel];
    [self.view addSubview:nsUrl];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, 100, 50)];
    dateLabel.text = @"NSDate";
    UILabel *dateValue = [[UILabel alloc] initWithFrame:CGRectMake(110, 350, 300, 50)];
    dateValue.text = [_date description];
    [self.view addSubview:dateLabel];
    [self.view addSubview:dateValue];
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
