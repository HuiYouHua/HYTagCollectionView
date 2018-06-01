//
//  HYCollectionViewLayout.m
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import "HYCollectionViewLayout.h"

@interface HYCollectionViewLayout()

/* 记录每个单元格开始位置坐标 */
@property (nonatomic, assign) CGPoint startPoint;
/* 当前区 */
@property (nonatomic, assign) NSInteger currentSection;
/* 当前区最后一个item的位置 */
@property (nonatomic, assign) CGPoint lastItemPoint;

/* 记录之前和当前item的布局 */
@property (nonatomic, strong) NSMutableArray *currentItemPositionArray;
@property (nonatomic, strong) NSMutableArray *oldItemPositionArray;

/* 记录之前和当前head的布局 */
@property (nonatomic, strong) NSMutableArray *currentHeadPositionArray;
@property (nonatomic, strong) NSMutableArray *oldHeadPositionArray;

@end

@implementation HYCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        if (!_currentItemPositionArray) {
            _currentItemPositionArray = [NSMutableArray array];
        }
        if (!_oldItemPositionArray) {
            _oldItemPositionArray = [NSMutableArray array];
        }
        
        if (!_currentHeadPositionArray) {
            _currentHeadPositionArray = [NSMutableArray array];
        }
        if (!_oldHeadPositionArray) {
            _oldHeadPositionArray = [NSMutableArray array];
        }
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    _startPoint = CGPointZero;
    _lastItemPoint = CGPointZero;
    _currentSection = 0;
}

/* 返回对应于indexPath的位置的cell的布局属性
    如果该分区没有单元格的话，则直接进入下一分区的布局
 */
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *att = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGSize size = CGSizeZero;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:indexPath:)]) {
        size = [self.delegate collectionView:self.collectionView layout:self indexPath:indexPath];
    }
    
    // 初始化添加完item后的位置
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGFloat totalWidth = self.startPoint.x + self.minimumInteritemSpacing + size.width + self.sectionInset.right;
    
    if (_currentSection != indexPath.section) {
        // 此时为下一个分区
        x = self.sectionInset.left;
        if (indexPath.section>=1&&[self.collectionView numberOfItemsInSection:(indexPath.section-1)] == 0) { // 表示该分区没有单元格，手动设置该单元最后坐标位置
            self.startPoint = CGPointMake(0, self.startPoint.y+40*indexPath.section);
        }
        y = self.startPoint.y + self.minimumLineSpacing*2 + 40;
    } else {
    
        // 剩余的宽度
        if (totalWidth <= CGRectGetWidth(self.collectionView.frame)) {
            // 小于表示有足够的空间可以添加，在当前行添加
            if (indexPath.item == 0) {
                x = self.sectionInset.left;
                y = self.sectionInset.top + self.startPoint.y + 40;
            } else {
                x = self.startPoint.x + self.minimumInteritemSpacing;
                y = self.startPoint.y - size.height;
            }
        } else {
            // 大于表示没有足够的空间可以添加，应在下一行添加
            x = self.sectionInset.left;
            y = self.startPoint.y + self.minimumLineSpacing;
            
        }
    }
    // 记录添加完该item后的位置信息
    self.startPoint = CGPointMake(x + size.width, y + size.height);
    
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        for (int j=0; j<[self.collectionView numberOfItemsInSection:i]; j++) {
            if (([self.collectionView numberOfItemsInSection:i]-1) == indexPath.item) {
                // 当前表示该区最后一个元素
                self.lastItemPoint = CGPointMake(x + size.width, y + size.height + self.sectionInset.bottom);
            }
        }
    }
    
    att.frame = CGRectMake(x, y, size.width, size.height);

    // 记录当前section
    _currentSection = indexPath.section;
    return att;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *att= [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:indexPath];
    
    return att;
}

/* 返回每一个item的位置信息 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    [self.oldItemPositionArray removeAllObjects];
    [self.oldItemPositionArray addObjectsFromArray:self.currentItemPositionArray];
    [self.currentItemPositionArray removeAllObjects];
    
    [self.oldHeadPositionArray removeAllObjects];
    [self.oldHeadPositionArray addObjectsFromArray:self.currentHeadPositionArray];
    [self.currentHeadPositionArray removeAllObjects];
    
    NSMutableArray *attArray = [NSMutableArray array];
    
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        
        // 根据前面计算出的每个分区最后一个item的坐标位置设置下一分区的头
        UICollectionViewLayoutAttributes *att2 = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForRow:0 inSection:i]];
        if (i>=1&&[self.collectionView numberOfItemsInSection:i-1] == 0) { // 表示该分区没有单元格，手动设置该单元最后坐标位置
            self.lastItemPoint = CGPointMake(0, (40+self.sectionInset.bottom)*i);
        }
        att2.frame = CGRectMake(0, self.lastItemPoint.y, self.collectionView.frame.size.width, 40);
           
        [attArray addObject:att2];
        [self.currentHeadPositionArray addObject:att2];
        for (int j=0; j<[self.collectionView numberOfItemsInSection:i]; j++) {
            UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            [attArray addObject:att];
            [self.currentItemPositionArray addObject:att];
        }
    }
    
    return attArray;
}

/* 返回UICollectionView的大小 */
- (CGSize)collectionViewContentSize {
    return CGSizeMake(self.collectionView.frame.size.width, self.startPoint.y);
}

/* 当bounds发生变化时是否重新布局 */
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}

/* 当插入或者删除 item的时候，collection view将会通知布局对象它将调整布局，第一步就是调用该方法告知布局对象发生了什么改变。除此之外，该方法也可以用来获取插入、删除、移动item的布局信息。 */
- (void)prepareForCollectionViewUpdates:(NSArray<UICollectionViewUpdateItem *> *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];

//    for (UICollectionViewUpdateItem *update in updateItems) {
//        if (update.updateAction == UICollectionUpdateActionDelete) {
//            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
//        } else if (update.updateAction == UICollectionUpdateActionInsert) {
//            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
//        }
//    }
}

/* 在一个 item被插入到collection view 的时候，返回开始的布局信息。这个方法在 prepareForCollectionViewUpdates:之后和finalizeCollectionViewUpdates 之前调用。collection view将会使用该布局信息作为动画的起点(结束点是该item在collection view 的最新的位置)。如果返回为nil，布局对象将用item的最终的attributes 作为动画的起点和终点。 */
- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:itemIndexPath];


    NSInteger currentIndex = 0;
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        if (i== itemIndexPath.section) {
            currentIndex += itemIndexPath.item;
            break;
        } else {
            currentIndex += [self.collectionView numberOfItemsInSection:i]-1;
        }
    }

    UICollectionViewLayoutAttributes *layoutAttr = self.oldItemPositionArray[currentIndex>0 ? currentIndex:0];
    att = layoutAttr;
    att.alpha = 0;
    att.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    att.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    att.zIndex = 1;

    return att;
}

/* 返回值是item即将从collection view移除时候的布局信息，对即将删除的item来讲，该方法在 prepareForCollectionViewUpdates: 之后和finalizeCollectionViewUpdates 之前调用。在该方法中返回的布局信息描包含 item的状态信息和位置信息。 collection view将会把该信息作为动画的终点(起点是item当前的位置)。如果返回为nil的话，布局对象将会把当前的attribute，作为动画的起点和终点 */
- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:itemIndexPath];

    NSInteger currentIndex = 0;
    for (int i=0; i<self.collectionView.numberOfSections; i++) {
        if (i== itemIndexPath.section) {
            currentIndex += itemIndexPath.item;
            break;
        } else {
            currentIndex += [self.collectionView numberOfItemsInSection:i]-1;
        }
    }

    UICollectionViewLayoutAttributes *layoutAttr = self.currentItemPositionArray[currentIndex>0 ? currentIndex:0];
    att = layoutAttr;
    att.alpha = 0;
    att.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    att.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0.2, 0.2), M_PI);
    att.zIndex = 1;
    
    return att;
}

- (nullable UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:elementIndexPath];

    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *layoutAttr = self.oldHeadPositionArray[elementIndexPath.section];
        att = layoutAttr;

    }
    return att;
}

- (nullable UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:elementIndexPath];

    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionViewLayoutAttributes *layoutAttr = self.currentHeadPositionArray[elementIndexPath.section];
        att = layoutAttr;

    }
    return att;
}

///* 当item在手势交互下移动时，通过该方法返回这个item布局的attributes 。默认实现是，复制已存在的attributes，改变attributes两个值，一个是中心点center；另一个是z轴的坐标值，设置成最大值。所以该item在collection view的最上层。子类重载该方法，可以按照自己的需求更改attributes，首先需要调用super类获取attributes,然后自定义返回的数据结构。 */
//- (UICollectionViewLayoutAttributes *)layoutAttributesForInteractivelyMovingItemAtIndexPath:(NSIndexPath *)indexPath withTargetPosition:(CGPoint)position {
//    [super layoutAttributesForInteractivelyMovingItemAtIndexPath:indexPath withTargetPosition:position];
//    UICollectionViewLayoutAttributes *att = [self layoutAttributesForItemAtIndexPath:indexPath];
//
//    return att;
//
//}

//移动相关
- (UICollectionViewLayoutInvalidationContext *)invalidationContextForInteractivelyMovingItems:(NSArray<NSIndexPath *> *)targetIndexPaths withTargetPosition:(CGPoint)targetPosition previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths previousPosition:(CGPoint)previousPosition NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForInteractivelyMovingItems:targetIndexPaths withTargetPosition:targetPosition previousIndexPaths:previousIndexPaths previousPosition:previousPosition];
    
    if([self.delegate respondsToSelector:@selector(moveItemAtIndexPath: toIndexPath:)]){
        [self.delegate moveItemAtIndexPath:previousIndexPaths[0] toIndexPath:targetIndexPaths[0]];
    }
    return context;
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:(NSArray<NSIndexPath *> *)indexPaths previousIndexPaths:(NSArray<NSIndexPath *> *)previousIndexPaths movementCancelled:(BOOL)movementCancelled NS_AVAILABLE_IOS(9_0)
{
    UICollectionViewLayoutInvalidationContext *context = [super invalidationContextForEndingInteractiveMovementOfItemsToFinalIndexPaths:indexPaths previousIndexPaths:previousIndexPaths movementCancelled:movementCancelled];
    
    if(!movementCancelled){
        
    }
    return context;
}

/* 通过该方法添加一些动画到block，或者做一些和最终布局相关的工作。 */
- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];

}

//
//- (void)prepareForAnimatedBoundsChange:(CGRect)oldBounds {
//    
//}
//
//- (void)finalizeAnimatedBoundsChange {
//    
//}

/* 在进行动画式布局的时候，该方法返回内容区的偏移量。在布局更新或者布局转场的时候，collection view 调用该方法改变内容区的偏移量，该偏移量作为动画的结束点。如果动画或者转场造成item位置的改变并不是以最优的方式进行，可以重载该方法进行优化。 collection view在调用prepareLayout 和 collectionViewContentSize 之后调用该方法 */
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset {
//    return CGPointZero;
//}

///* 该方法返回值为滑动停止的点。如果你希望内容区快速滑动到指定的区域，可以重载该方法。比如，你可以通过该方法让滑动停止在两个item中间的区域，而不是某个item的中间。 */
//- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
//
//}

@end














