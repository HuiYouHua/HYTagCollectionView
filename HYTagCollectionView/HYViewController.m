//
//  HYViewController.m
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import "HYViewController.h"
#import "HYTagViewController.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)tagClick:(id)sender {
    [self.navigationController pushViewController:[HYTagViewController new] animated:YES];
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
