//
//  HYTagViewController.m
//  HYTagCollectionView
//
//  Created by 华惠友 on 2018/5/22.
//  Copyright © 2018年 华惠友. All rights reserved.
//

#import "HYTagViewController.h"
#import "HYCollectionViewLayout.h"
#import "HYCollectionViewCell.h"
#import "HYCollectionReusableView.h"

static NSString *const cellId = @"HYCollectionViewCell";
static NSString *const headerId1 = @"HYCollectionReusableView1";
static NSString *const headerId2 = @"HYCollectionReusableView2";
@interface HYTagViewController ()<UICollectionViewDataSource, HYCollectionViewLayoutDelegate, HYCollectionViewCellDelegate, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *myCol;
/* 数据 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/* 是否处于编辑 YES/NO */
@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) UILabel *animationLabel;

@property (nonatomic, strong)NSMutableArray *cellAttributesArray;


@end

@implementation HYTagViewController

- (void)loadView {
    [super loadView];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.cellAttributesArray = [[NSMutableArray alloc] init];

    
    NSMutableArray *selectedArray = [NSMutableArray arrayWithArray:@[@"头条",@"热点新闻",@"体育杂志",@"绝地求生之全军出击",@"财经",@"暴雪游戏帖",@"图片",@"轻松一刻",@"LOL",@"段子手",@"军事",@"房产",@"English",@"家居",@"原创大型喜剧",@"游戏英雄联盟"]];;
    NSMutableArray *optionalArray = [NSMutableArray arrayWithArray:@[@"暴走大事件",@"Uzi",@"iOS",@"Apple",@"绝地求生之刺激战场",@"葫芦岛吴奇隆",@"独角兽",@"最有影响力的职业选手",@"版本老司机"]];;
    
    _dataArray = [NSMutableArray arrayWithArray:@[selectedArray, optionalArray]];
    
    HYCollectionViewLayout *layout = [[HYCollectionViewLayout alloc] init];
    layout.delegate = self;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 10;
    
    _myCol = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) collectionViewLayout:layout];
    _myCol.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];

    _myCol.delegate = self;
    _myCol.dataSource = self;
    [_myCol registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellWithReuseIdentifier:cellId];
    [_myCol registerClass:[HYCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId1];
    [_myCol registerClass:[HYCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId2];

    [self.view addSubview:_myCol];
    [_myCol reloadData];
    
    self.animationLabel = [[UILabel alloc] init];
    self.animationLabel.textAlignment = NSTextAlignmentCenter;
    self.animationLabel.font = [UIFont systemFontOfSize:14];
    self.animationLabel.layer.cornerRadius = 15;
    self.animationLabel.layer.masksToBounds = YES;
    self.animationLabel.backgroundColor = [UIColor whiteColor];
}

- (void)sortItems:(UIPanGestureRecognizer *)pan {
    HYCollectionViewCell *cell = (HYCollectionViewCell *)pan.view;
    NSIndexPath *cellIndexPath = [self.myCol indexPathForCell:cell];
    

    //开始  获取所有cell的attributes
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self.cellAttributesArray removeAllObjects];
        for (NSInteger i = 0 ; i < [self.dataArray[0] count]; i++) {
            [self.cellAttributesArray addObject:[self.myCol layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
        }
    }

    CGPoint point = [pan translationInView:self.myCol];
    cell.center = CGPointMake(cell.center.x + point.x, cell.center.y + point.y);
    [pan setTranslation:CGPointMake(0, 0) inView:self.myCol];

    //进行是否排序操作
    BOOL ischange = NO;
    for (UICollectionViewLayoutAttributes *attributes in self.cellAttributesArray) {
        CGRect rect = CGRectMake(attributes.center.x - 15, attributes.center.y - 6, 30, 12);
        if (CGRectContainsPoint(rect, CGPointMake(pan.view.center.x, pan.view.center.y)) & (cellIndexPath != attributes.indexPath)) {

            //后面跟前面交换
            if (cellIndexPath.row > attributes.indexPath.row) {
                //交替操作0 1 2 3 变成（3<->2 3<->1 3<->0）
                for (NSInteger index = cellIndexPath.row; index > attributes.indexPath.row; index -- ) {
                    [self.dataArray[0] exchangeObjectAtIndex:index withObjectAtIndex:index - 1];
                }
            }
            //前面跟后面交换
            else{
                //交替操作0 1 2 3 变成（0<->1 0<->2 0<->3）
                for (NSInteger index = cellIndexPath.row; index < attributes.indexPath.row; index ++ ) {
                    [self.dataArray[0] exchangeObjectAtIndex:index withObjectAtIndex:index + 1];
                }
            }
            ischange = YES;
            [self.myCol moveItemAtIndexPath:cellIndexPath toIndexPath:attributes.indexPath];
        }
        else{
            ischange = NO;
        }
    }

    //结束
    if (pan.state == UIGestureRecognizerStateEnded){
        if (ischange) {

        }
        else{
            cell.center = [self.myCol layoutAttributesForItemAtIndexPath:cellIndexPath].center;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    HYCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.textLable.text = self.dataArray[indexPath.section][indexPath.item];
    cell.deleteBtn.hidden = YES;
    cell.indexPath = indexPath;
    cell.delegate = self;
    if (indexPath.section == 0) {
        
        if (!_isEdit) {
            cell.deleteBtn.hidden = YES;
        } else {
            cell.deleteBtn.hidden = NO;
            [cell startEdit];

        }
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(sortItems:)];
        [cell addGestureRecognizer:pan];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    HYCollectionReusableView *headView = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        if (indexPath.section == 0) {
            headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId1 forIndexPath:indexPath];
            headView.indexPath = indexPath;
            headView.titleLabel.text = @"已选栏目";
            headView.titleBtn.hidden = NO;
            
            __weak typeof(self) weakSelf = self;
            headView.btnClickBlock = ^(BOOL isEdit) {
                
                // 点击了编辑按钮
                _isEdit = isEdit;
                
                [weakSelf.myCol reloadData];
            };
            
            
        } else if (indexPath.section == 1) {
            headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId2 forIndexPath:indexPath];
            headView.indexPath = indexPath;
            headView.titleLabel.text = @"点击添加更多栏目";
            headView.titleBtn.hidden = YES;
        }
    }
    return (UICollectionReusableView *)headView;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
//        HYCollectionViewCell *cell1 = (HYCollectionViewCell *)[self.myCol cellForItemAtIndexPath:indexPath];
//        cell1.hidden = YES;
        
        NSString *str = self.dataArray[indexPath.section][indexPath.item];
        int lastItem = (int)[self.dataArray[0] count];
        
        for (int i=0; i<self.dataArray.count; i++) {
            NSMutableArray *itemsArray = self.dataArray[i];
            for (int j=0; j<itemsArray.count; j++) {
                if (i==indexPath.section && j==indexPath.item) {
                    [itemsArray removeObjectAtIndex:j];
                }
            }
            
            if (i == 0) {
                [itemsArray addObject:str];
            }
        }
        
        [self.myCol performBatchUpdates:^{
            [self.myCol deleteItemsAtIndexPaths:@[indexPath]];
            [self.myCol insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:lastItem inSection:0]]];
//            HYCollectionViewCell *cell2 = (HYCollectionViewCell *)[self.myCol cellForItemAtIndexPath:[NSIndexPath indexPathForRow:lastItem inSection:0]];
//            cell2.hidden = YES;
            
        } completion:nil];
        
//        UICollectionViewLayoutAttributes *startAtt = [self.myCol layoutAttributesForItemAtIndexPath:indexPath];
//        self.animationLabel.frame = CGRectMake(startAtt.frame.origin.x, startAtt.frame.origin.y, startAtt.frame.size.width, startAtt.frame.size.height);
//        self.animationLabel.layer.cornerRadius = CGRectGetHeight(self.animationLabel.bounds) * 0.5;
//        self.animationLabel.text = str;
//        [self.myCol addSubview:self.animationLabel];
//
//
//        UICollectionViewLayoutAttributes *endAtt = [self.myCol layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:lastItem inSection:0]];
//
//        __weak typeof(self) weakSelf = self;
//        [UIView animateWithDuration:0.5 animations:^{
//            weakSelf.animationLabel.center = endAtt.center;
//        } completion:^(BOOL finished) {
//            HYCollectionViewCell *cell2 = (HYCollectionViewCell *)[self.myCol cellForItemAtIndexPath:[NSIndexPath indexPathForRow:lastItem inSection:0]];
//            cell2.hidden = NO;
//            [weakSelf.animationLabel removeFromSuperview];
//
//        }];
        
    }
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0)
{
    cell.contentView.alpha = 0;
    cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(0, 0), 0);
    
    
    [UIView animateKeyframesWithDuration:.5 delay:0.0 options:0 animations:^{
        
        /**
         *  分步动画   第一个参数是该动画开始的百分比时间  第二个参数是该动画持续的百分比时间
         */
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.8 animations:^{
            cell.contentView.alpha = .5;
            cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1.2, 1.2), 0);
            
        }];
        [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
            cell.contentView.alpha = 1;
            cell.transform = CGAffineTransformRotate(CGAffineTransformMakeScale(1, 1), 0);
            
        }];
        
    } completion:^(BOOL finished) {
        
    }];
    

}

#pragma mark - HYCollectionViewLayoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(HYCollectionViewLayout *)layout indexPath:(NSIndexPath *)indexPath {

    if (indexPath.item < [self.dataArray[indexPath.section] count]) {
        NSString *str = self.dataArray[indexPath.section][indexPath.item];
        CGSize size = [self sizeWithString:str fontSize:14.0f];
        return CGSizeMake(size.width+30, 30);
    }

    return CGSizeMake(90, 30);
    
}

- (CGSize)sizeWithString:(NSString *)str fontSize:(float)fontSize
{
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 40, fontSize + 1);
    
    CGSize tempSize;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize retSize = [str boundingRectWithSize:constraint
                                       options:
                      NSStringDrawingUsesLineFragmentOrigin
                                    attributes:attribute
                                       context:nil].size;
    tempSize = retSize;
    
    return tempSize ;
}

- (void)moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
    if(sourceIndexPath.row != destinationIndexPath.row){
        NSString *value = self.dataArray[0][sourceIndexPath.row];
        [self.dataArray[0] removeObjectAtIndex:sourceIndexPath.row];
        [self.dataArray[0] insertObject:value atIndex:destinationIndexPath.row];
        NSLog(@"from:%ld      to:%ld", sourceIndexPath.row, destinationIndexPath.row);
    }
}

#pragma mark - HYCollectionViewCellDelegate
- (void)deleteItemWithIndexPath:(NSIndexPath *)indexPath {
    NSString *str = self.dataArray[indexPath.section][indexPath.item];
    int lastSection = (int)self.dataArray.count - 1;
    
    for (int i=0; i<self.dataArray.count; i++) {
        NSMutableArray *itemsArray = self.dataArray[i];
        for (int j=0; j<itemsArray.count; j++) {
            if (i==indexPath.section && j==indexPath.item) {
                [itemsArray removeObjectAtIndex:j];
            }
        }
        
        if (i == lastSection) {
            [itemsArray insertObject:str atIndex:0];
        }
    }
    [self.myCol performBatchUpdates:^{
        [self.myCol deleteItemsAtIndexPaths:@[indexPath]];
        [self.myCol insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:lastSection]]];
    } completion:nil];
   
    
    for (NSInteger i = 0; i < [self.dataArray[indexPath.section] count]; i++) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        HYCollectionViewCell *cell = (HYCollectionViewCell *)[self.myCol cellForItemAtIndexPath:newIndexPath];
        cell.indexPath = newIndexPath;
    }
}

@end

























