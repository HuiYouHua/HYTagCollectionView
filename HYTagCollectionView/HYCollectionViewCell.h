//
//  HYCollectionViewCell.h
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYCollectionViewCellDelegate <NSObject>

- (void)deleteItemWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface HYCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *textLable;

@property (nonatomic, weak) id<HYCollectionViewCellDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)startEdit;

@end
