//
//  HYCollectionReusableView.m
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import "HYCollectionReusableView.h"

@interface HYCollectionReusableView()


@end

@implementation HYCollectionReusableView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self confingSubViews];
    }
    return self;
}
-(void)confingSubViews{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200, self.bounds.size.height)];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.titleLabel];
    
    self.titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 80, 10, 60, 20)];
    self.titleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleBtn.backgroundColor = [UIColor whiteColor];
    self.titleBtn.layer.masksToBounds = YES;
    self.titleBtn.layer.cornerRadius = 10;
    self.titleBtn.layer.borderColor = [UIColor redColor].CGColor;
    self.titleBtn.layer.borderWidth = 0.7;
    [self.titleBtn setTitle:@"排序删除" forState:UIControlStateNormal];
    [self.titleBtn setTitle:@"完成" forState:UIControlStateSelected];
    [self.titleBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.titleBtn.hidden = YES;
    [self.titleBtn addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.titleBtn];
}

- (void)clickAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.btnClickBlock) {
        self.btnClickBlock(sender.selected);
    }
}


@end
