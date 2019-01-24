//
//  UIViewController+HBGuid.m
//  HBGuidePage
//
//  Created by 胡勃 on 1/24/19.
//  Copyright © 2019 胡勃. All rights reserved.
//

#import "UIViewController+HBGuid.h"
#import <objc/runtime.h>

#define ImageArray @[@"guid01",@"guid02",@"guid03",@"guid04"]

/** pageIndicatorTintColor*/
#define pageTintColor [[UIColor whiteColor] colorWithAlphaComponent:0.8];
/** currentPageIndicatorTintColor*/
#define currentTintColor [UIColor whiteColor];

#define CollectionView_Tag 110
#define RemoveBtn_tag 111
#define Control_tag 112

#define FIRST_IN_KEY @"FIRST_IN_KEY"

@interface HBGuidViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString* imageName;
@property (nonatomic, strong) UIImageView* imageView;
@end
@implementation HBGuidViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_imageView];
    }
    return self;
}
- (void)setImageName:(NSString *)imageName {
    if (_imageName != imageName) {
        _imageName = [imageName copy];
    }
    _imageView.image = [UIImage imageNamed:imageName];
}
@end

/***以上是HBGuidViewCell,以下才是UIViewController+KSGuid**********/

@implementation UIViewController (HBGuid)

#pragma mark-
#pragma mark 这里是退出的按钮
- (UIButton*)removeBtn {
    //移除按钮样式
    UIButton* removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn addTarget:self action:@selector(removeGuidView) forControlEvents:UIControlEventTouchUpInside];
    removeBtn.hidden = (self.imageArray.count != 1);
    removeBtn.tag = RemoveBtn_tag;      //注意这里的tag
    
    //***********************这里面可以自定义*******************************//
    CGFloat btnW = 128;
    CGFloat btnH = 35;
    CGFloat btnX = CGRectGetMidX(self.view.frame) - btnW / 2;
    CGFloat btnY = CGRectGetMaxY(self.view.frame) * 0.83;
    removeBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    
    removeBtn.layer.cornerRadius = 4;
    removeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    removeBtn.layer.borderWidth = 1.;
    
    [removeBtn setTitle:@"进入APP" forState:UIControlStateNormal];
    [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    removeBtn.titleLabel.font = [UIFont systemFontOfSize:18.];
    return removeBtn;
}

#pragma mark-
#pragma mark 这里填充图片的名称
- (NSArray<NSString*>*)imageArray {
    return ImageArray;
}

+ (void)load {
    //启动判断
    NSString* versoin = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString* versionCache = [[NSUserDefaults standardUserDefaults] objectForKey:FIRST_IN_KEY];
    if (![versoin isEqualToString:versionCache]) {
        return;
    }
    //以下代码只在程序安装初次运行时候执行
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getInstanceMethod(self.class, @selector(viewDidLoad));
        Method method2 = class_getInstanceMethod(self.class, @selector(guidViewDidLoad));
        
        BOOL didAddMethod = class_addMethod(self.class,
                                            @selector(viewDidLoad),
                                            method_getImplementation(method2),
                                            method_getTypeEncoding(method2));
        if (didAddMethod) {
            class_replaceMethod(self.class,
                                @selector(guidViewDidLoad),
                                method_getImplementation(method1),
                                method_getTypeEncoding(method1));
        } else {
            method_exchangeImplementations(method1, method2);
        }
    });
}

- (void)guidViewDidLoad {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //这里的代码只在程序安装初次打开，并且在第一个控制器里面执行
        [self setupSubViews];   //初始化视图
    });
    //这是调用工程里面的viewDidLoad
    [self guidViewDidLoad];
}

#pragma mark-
#pragma mark 初始化视图

- (void)setupSubViews {
    
    //界面样式
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView* collectionView = [[UICollectionView alloc]
                                        initWithFrame:self.view.bounds
                                        collectionViewLayout:flowLayout];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.pagingEnabled = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    [collectionView registerClass:[HBGuidViewCell class] forCellWithReuseIdentifier:@"HBGuidViewCell"];
    
    collectionView.tag = CollectionView_Tag;
    [self.view addSubview:collectionView];
    
    [self.view addSubview:self.removeBtn];
    
    UIPageControl* control = [[UIPageControl alloc] init];
    
    CGFloat controlW = 170;
    CGFloat controlH = 20;
    CGFloat controlX = CGRectGetMidX(self.view.frame) - controlW / 2;
    CGFloat controlY = CGRectGetMaxY(self.view.frame) - 38;
    control.frame = CGRectMake(controlX, controlY, controlW, controlH);
    control.numberOfPages = ImageArray.count;
    control.pageIndicatorTintColor = pageTintColor;
    control.currentPageIndicatorTintColor = currentTintColor;
    
    control.tag = Control_tag;
    [self.view addSubview:control];
}

#pragma mark-
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HBGuidViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HBGuidViewCell" forIndexPath:indexPath];
    cell.imageName = self.imageArray[indexPath.row];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    [self.view viewWithTag:RemoveBtn_tag].hidden = (index != self.imageArray.count - 1);
    
    UIPageControl* control =[self.view viewWithTag:Control_tag];
    control.currentPage = index;
    
}

- (void)removeGuidView {
    
    NSString* versoin = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [[NSUserDefaults standardUserDefaults] setObject:versoin forKey:FIRST_IN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[self.view viewWithTag:Control_tag] removeFromSuperview];
    [[self.view viewWithTag:RemoveBtn_tag] removeFromSuperview];
    [[self.view viewWithTag:CollectionView_Tag] removeFromSuperview];
}


@end


