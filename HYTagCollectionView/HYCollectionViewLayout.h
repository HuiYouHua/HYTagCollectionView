//
//  HYCollectionViewLayout.h
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HYCollectionViewLayout;
@protocol HYCollectionViewLayoutDelegate <NSObject>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HYCollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath;

//处理移动相关的数据源
- (void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath;

@end

@interface HYCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) id<HYCollectionViewLayoutDelegate> delegate;

/* UICollectionView内边距 */
@property(nonatomic, assign) UIEdgeInsets sectionInset;

/* 上下行边距 */
@property (nonatomic, assign) CGFloat minimumLineSpacing;

/* 左右单元边距 */
@property (nonatomic, assign) CGFloat minimumInteritemSpacing;

/* 单元格大小 */
@property (nonatomic, assign) CGSize itemSize;
@end
