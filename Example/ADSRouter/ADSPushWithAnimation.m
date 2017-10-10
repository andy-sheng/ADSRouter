//
//  ASPushWithAnimation.m
//  ASRouter_Example
//
//  Created by Andy on 2017/9/28.
//  Copyright © 2017年 andysheng@live.com. All rights reserved.
//

#import "ADSPushWithAnimation.h"
#import "ADSRouter.h"

@interface ADSPushWithAnimation ()
@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (weak, nonatomic) IBOutlet UILabel *stringLabel;
@property (weak, nonatomic) IBOutlet UILabel *nsNumberLabel;



@end

@implementation ADSPushWithAnimation

ADS_REQUEST_MAPPING(ADSPushWithAnimation, "wfshop://pushWithAnimation")
ADS_PARAMETER_MAPPING(ADSPushWithAnimation, productId, "id")
ADS_PARAMETER_MAPPING(ADSPushWithAnimation, string, "string")
ADS_PARAMETER_MAPPING(ADSPushWithAnimation, nsNumber, "nsNumber")
ADS_SHOWSTYLE_PUSH_WITH_ANIMATION
ADS_STORYBOARD("Main", "ADSPushWithAnimation")
ADS_SUPPORT_FLY

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"%p", self];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.idLabel setText:@(_productId).stringValue];
    [self.stringLabel setText:_string];
    [self.nsNumberLabel setText:_nsNumber.stringValue];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)jump:(id)sender {
    [[ADSRouter sharedRouter] openUrl:@"wfshop://pushWithAnimation?id=1&string=%e5%91%b5%e5%91%b5&nsNumber=1.23"];
}


- (void)setProductId:(NSUInteger)productId {
    _productId = productId;
}

- (void)dealloc {
    NSLog(@"dealloc");
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
