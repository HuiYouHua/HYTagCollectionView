//
//  HYCollectionViewCell.m
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import "HYCollectionViewCell.h"

@interface HYCollectionViewCell()

/* 是否处于删除状态 YES/处于删除  NO/正常状态 */
@property (nonatomic, assign) BOOL isDelete;

@end

@implementation HYCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}
- (IBAction)delete:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteItemWithIndexPath:)]) {
        [self.delegate deleteItemWithIndexPath:self.indexPath];
    }
}

- (void)startEdit {
    double (^angle)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };
    CABasicAnimation * ba = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    ba.fromValue = @(angle(-5.0));
    ba.toValue = @(angle(5.0));
    ba.repeatCount = MAXFLOAT;
    ba.duration = 0.1;
    ba.autoreverses = YES;
    [self.layer addAnimation:ba forKey:nil];
}

@end
