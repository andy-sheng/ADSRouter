//
//  ASPresentVC.m
//  ASRouter_Example
//
//  Created by Andy on 2017/9/28.
//  Copyright © 2017年 andysheng@live.com. All rights reserved.
//

#import "ADSPresentVC.h"
#import "ADSAnnotation.h"
@interface ADSPresentVC ()

@end

@implementation ADSPresentVC

ADS_REQUEST_MAPPING(ADSPresentVC, "wfshop://present")
ADS_SHOWSTYLE_PRESENT
ADS_STORYBOARD("Main", "ADSPresentVC")


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
