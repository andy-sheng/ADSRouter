//
//  ASViewController.m
//  ASRouter
//
//  Created by andysheng@live.com on 09/28/2017.
//  Copyright (c) 2017 andysheng@live.com. All rights reserved.
//

#import "ADSViewController.h"
#import "ADSRouter.h"
#import "ADSURL.h"
@interface ADSViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *urls;
@end

@implementation ADSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _urls = @[@"wfshop://pushWithAnimation?id=1&string=hello&nsNumber=1.23", @"wfshop://pushWithAnimation?id=1&string=%e5%91%b5%e5%91%b5&nsNumber=1.23",@"wfshop://pushWithoutAnimation", @"wfshop://present", @"wfshop://pushWithAnimationFromCode?nsstring=%E5%93%88%E5%93%88&int=123&nsnumberparam=1.1&nsdecimalnumber=1.23&cgfloat=1.234&url=http://asdf?a=as&date=2014-01-20",@"wfshop://asd",@"wfshop://interceptorTest"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _urls.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = _urls[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[ADSRouter sharedRouter] openUrlString:_urls[indexPath.row]];
    NSLog(@"open url: %@", _urls[indexPath.row]);
}
@end
