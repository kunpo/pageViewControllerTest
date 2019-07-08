//
//  ViewController.m
//  page
//
//  Created by kemp on 2019/6/27.
//  Copyright © 2019 kemp. All rights reserved.
//


#import "ViewController.h"
#import "SubViewController.h"

@interface ViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (nonatomic, strong) UIPageViewController *pageViewContol;
@property (nonatomic, strong) NSArray<UIButton *> *btns;
@property (nonatomic, strong) NSArray<UIViewController *> *subControllers;
@property (nonatomic, weak) UIViewController *currentVC; //记录当前显示的页面
@property (nonatomic, assign) BOOL isGoForward; //标记是下一页还是上一页
@property (nonatomic, assign) BOOL inAnimation; //标记切换时动画是否正在做，防止动画冲突

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configData];
}

- (void)configData {
    self.btns = @[_btn1, _btn2, _btn3, _btn4];
    NSMutableArray *temp = [NSMutableArray new];
    for (int i = 0; i < 4; i ++) {
        SubViewController *sub = [SubViewController creat];
        sub.title = [NSString stringWithFormat:@"这是第%d个", i + 1];
        [temp addObject:sub];
    }
    self.subControllers = [NSArray arrayWithArray:temp];
    self.currentVC = temp.firstObject;
    /*
     UIPageViewControllerTransitionStylePageCurl 翻页动画
     UIPageViewControllerTransitionStyleScroll 滑动
     
     UIPageViewControllerNavigationOrientationHorizontal 水平方向
     UIPageViewControllerNavigationOrientationVertical 竖直方向
     */
    
    self.pageViewContol = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
    [self addChildViewController:self.pageViewContol];
    self.pageViewContol.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.pageViewContol.view];
    self.pageViewContol.delegate = self;
    self.pageViewContol.dataSource = self;
    [self.pageViewContol setViewControllers:@[self.subControllers.firstObject] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    self.btn1.selected = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.pageViewContol.view.frame = self.contentView.bounds;
    [self.pageViewContol.view layoutSubviews];
}

- (void)selectViewController:(UIViewController *)vc {
    for (UIButton *item in self.btns) {
        item.selected = NO;
    }
    NSUInteger index = [self.subControllers indexOfObject:vc];
    if (index < self.btns.count) {
        self.btns[index].selected = YES;
    }
    self.currentVC = vc;
}

- (IBAction)btnClick:(UIButton *)sender {
    if (self.inAnimation) {
        return;
    }
    self.inAnimation = YES;
    for (UIButton *item in self.btns) {
        item.selected = NO;
    }
    sender.selected = YES;
    NSUInteger index = [self.btns indexOfObject:sender];
    if (index < self.subControllers.count) {
        UIViewController *vc = self.subControllers[index];
        UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
        NSUInteger currentIndex = [self.subControllers indexOfObject:self.currentVC];
        if (index < currentIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        }
        __weak ViewController *weakSelf = self;
        
        [self.pageViewContol setViewControllers:@[vc] direction:direction animated:YES completion:^(BOOL finished) {
            if (finished) {
                weakSelf.currentVC = vc;
                weakSelf.inAnimation = NO;
            }
        }];
    }
}

//MARK:-------UIPageViewControllerDelegate, UIPageViewControllerDataSource-------

//下一个页面
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    NSUInteger currentIndex = [self.subControllers indexOfObject:self.currentVC];
    if (currentIndex == 3) {
        return nil;
    }
    NSUInteger index = currentIndex + 1;
    UIViewController *vc = self.subControllers[index];
    NSLog(@"下一个");
    return vc;
}
//上一个页面
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    NSUInteger currentIndex = [self.subControllers indexOfObject:self.currentVC];
    if (currentIndex == 0) {
        return nil;
    }
    NSUInteger index = currentIndex - 1;
    UIViewController *vc = self.subControllers[index];
    NSLog(@"上一个");
    return vc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    NSUInteger index = [self.subControllers indexOfObject:pendingViewControllers.firstObject];
    NSUInteger currentIndex = [self.subControllers indexOfObject:self.currentVC];
    if (index > currentIndex) {
        self.isGoForward = YES;
    } else {
        self.isGoForward = NO;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    /*
     previousViewControllers 是上一次显示的vc。
     'finished'参数指示动画是否完成，而'completed'参数指示转换是否完成或退出(如果用户提前退出)。
     */
    NSLog(@"完成");
    if ((completed == NO) || (finished == NO)) {
        return;
    }
    NSUInteger index = 0;
    NSUInteger currentIndex = [self.subControllers indexOfObject:self.currentVC];
    if (self.isGoForward == YES) {
        index = currentIndex + 1;
    } else {
        index = currentIndex - 1;
    }
    if (index < self.subControllers.count) {
        UIViewController *currentVC = self.subControllers[index];
        [self selectViewController:currentVC];
    }
    self.inAnimation = NO;
}

@end
