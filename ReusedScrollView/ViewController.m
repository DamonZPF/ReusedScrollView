//
//  ViewController.m
//  ReusedScrollView
//
//  Created by zhoupengfei on 16/3/31.
//  Copyright © 2016年 zpf. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
@property(nonatomic,weak)UIScrollView * scrollView;
@property(nonatomic,strong)NSMutableSet * reusedSet;//缓存池
@property(nonatomic,strong)NSMutableSet * visableSet;//可见控件容器
@property(nonatomic,strong)NSMutableArray * imageNames;
@end

@implementation ViewController
-(NSMutableSet*)reusedSet{
    if (_reusedSet == nil) {
        _reusedSet = [NSMutableSet set];
    }
    return _reusedSet;
}

-(NSMutableSet*)visableSet{
    if (_visableSet == nil) {
        _visableSet = [NSMutableSet set];
    }
    return  _visableSet;
}

- (NSArray *)imageNames {
    if (_imageNames == nil) {
        NSMutableArray *imageNames = [NSMutableArray arrayWithCapacity:50];
        
        for (int i = 0; i < 50; i++) {
            NSString *imageName = [NSString stringWithFormat:@"img%d", i % 5];
            [imageNames addObject:imageName];
        }
        
        _imageNames = imageNames;
    }
    return _imageNames;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
}

-(void)setupScrollView{
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
   // scrollView.backgroundColor = [UIColor redColor];
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(self.imageNames.count * scrollView.bounds.size.width, 0);
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    [self showImageWithIndex:0];
 
}

-(void)showImageWithIndex:(NSInteger)index{
    //先从缓存池获取可用的ImageView
    UIImageView * imageView = [self.reusedSet anyObject];
    if (imageView) {//如果有可用的
        [self.reusedSet removeObject:imageView];//移除缓存池 将其显示出来
    }else{//没有有可用的 创建新的
        imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    imageView.frame = CGRectMake(index* CGRectGetWidth(self.scrollView.frame), 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    imageView.image = [UIImage imageNamed:self.imageNames[index]];
    imageView.tag = index;
    [self.scrollView addSubview:imageView];
    [self.visableSet addObject:imageView];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [self showImage];
}

-(void)showImage{
    CGRect visibleBounds = self.scrollView.bounds;
    CGFloat minX = CGRectGetMinX(visibleBounds);
    CGFloat maxX = CGRectGetMaxX(visibleBounds);
    CGFloat width = CGRectGetWidth(visibleBounds);
    
    NSInteger firstIndex = minX/width;
    NSInteger lastIndex = maxX/ width;
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (lastIndex >= self.imageNames.count) {
        lastIndex = self.imageNames.count - 1;
    }
    
    //遍历所有可见视图 回收不在显示的imageView
    NSInteger imageCurrentIndex = 0;
    for (UIImageView * imageView in self.visableSet) {
        imageCurrentIndex = imageView.tag;
        //不在显示范围
        if (imageCurrentIndex < firstIndex || imageCurrentIndex > lastIndex) {
            [self.reusedSet addObject:imageView];
            [imageView removeFromSuperview];
        }
    }
    [self.visableSet minusSet:self.reusedSet]; //更新可见容器数据
    
    
    for (NSInteger index = firstIndex; index <=lastIndex; index++) {
        BOOL isAlreadShow = NO;
        for (UIImageView  * imageView in self.visableSet) {
            if (imageView.tag == index) {
                isAlreadShow = YES;
            }
        }
        if (!isAlreadShow) {
            [self showImageWithIndex:index];
        }
    }
  
//    NSLog(@"bounds.x = %f ___ contentOffset.x = %f ",visibleBounds.origin.x ,self.scrollView.contentOffset.x);
}


@end
