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
@property (nonatomic, assign) int currentIndex; //记录当前显示的页面
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
        self.currentIndex = (int)index;
    }
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
        if (index < self.currentIndex) {
            direction = UIPageViewControllerNavigationDirectionReverse;
        }
        __weak ViewController *weakSelf = self;
        [self.pageViewContol setViewControllers:@[vc] direction:direction animated:YES completion:^(BOOL finished) {
            if (finished) {
                weakSelf.currentIndex = (int)index;
                weakSelf.inAnimation = NO;
            }
        }];
    }
}

//MARK:-------UIPageViewControllerDelegate, UIPageViewControllerDataSource-------

//下一个页面
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    if (self.currentIndex == 3) {
        return nil;
    }
    int index = self.currentIndex + 1;
    UIViewController *vc = self.subControllers[index];
    self.isGoForward = YES;
    return vc;
}
//上一个页面
- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    if (self.currentIndex == 0) {
        return nil;
    }
    int index = self.currentIndex - 1;
    UIViewController *vc = self.subControllers[index];
    self.isGoForward = NO;
    return vc;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    /*
     previousViewControllers 是上一次显示的vc。
     'finished'参数指示动画是否完成，而'completed'参数指示转换是否完成或退出(如果用户提前退出)。
     */
    if ((completed == NO) || (finished == NO)) {
        return;
    }
    NSUInteger index = 0;
    if (self.isGoForward == YES) {
        index = self.currentIndex + 1;
    } else {
        index = self.currentIndex - 1;
    }
    if (index < self.subControllers.count) {
        UIViewController *currentVC = self.subControllers[index];
        [self selectViewController:currentVC];
    }
}

@end
