//
//  HYCollectionReusableView.h
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HYCollectionReusableView : UICollectionReusableView

@property (strong, nonatomic)  UILabel *titleLabel;
@property (strong, nonatomic)  UIButton *titleBtn;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, copy) void(^btnClickBlock)(BOOL isEdit);

@end
