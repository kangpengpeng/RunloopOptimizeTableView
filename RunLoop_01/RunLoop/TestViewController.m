//
//  TestViewController.m
//  RunLoop
//
//  Created by 康鹏鹏 on 2017/5/4.
//  Copyright © 2017年 dhcc. All rights reserved.
//

#import "TestViewController.h"

// 存放代码库的Block
typedef void(^RunloopBlock)(void);

@interface TestViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, assign) NSUInteger maxQueueLength;
@end

@implementation TestViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:self.tableView];
    }
    return _tableView;
}
- (NSMutableArray *)tasks {
    if (!_tasks) {
        _tasks = [[NSMutableArray alloc] initWithCapacity:18];
    }
    return _tasks;
}

- (void)timerMethod {
    // 不做任何事情
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _maxQueueLength = 18;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
    // 添加观察者方法
    [self addRunloopObserver];

    [self.tableView reloadData];
}



// 加载第一张
+(void)addImage1With:(UITableViewCell *)cell{
    //第一张
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 85, 85)];
    imageView.tag = 1;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path1];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;

    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        [cell.contentView addSubview:imageView];
    } completion:nil];
}
// 加载第二张
+(void)addImage2With:(UITableViewCell *)cell{
    //第二张
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(105, 20, 85, 85)];
    imageView1.tag = 2;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"png"];
    UIImage *image1 = [UIImage imageWithContentsOfFile:path1];
    imageView1.contentMode = UIViewContentModeScaleAspectFit;
    imageView1.image = image1;

    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        [cell.contentView addSubview:imageView1];
    } completion:nil];
}
// 加载第三张
+(void)addImage3With:(UITableViewCell *)cell{
    //第三张
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(200, 20, 85, 85)];
    imageView2.tag = 3;
    NSString *path1 = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"png"];
    UIImage *image2 = [UIImage imageWithContentsOfFile:path1];
    imageView2.contentMode = UIViewContentModeScaleAspectFit;
    imageView2.image = image2;

    [UIView transitionWithView:cell.contentView duration:0.3 options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve) animations:^{
        [cell.contentView addSubview:imageView2];
    } completion:nil];
}

#pragma mark - UITableView Delegate, DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for (NSInteger i = 1; i < 4; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
//    [TestViewController addImage1With:cell];
//    [TestViewController addImage2With:cell];
//    [TestViewController addImage3With:cell];

    [self addTask:^{
        [TestViewController addImage1With:cell];
    }];
    [self addTask:^{
        [TestViewController addImage2With:cell];
    }];
    [self addTask:^{
        [TestViewController addImage3With:cell];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

#pragma mark - 关于CFRunloop的代码
// 添加runloop观察者模式
- (void)addRunloopObserver {
    // 获取当前runloop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    // 定义观察者
    static CFRunLoopObserverRef defaultModeObserver;
    // 定义一个上下文
    CFRunLoopObserverContext context = {
        0,
        (__bridge void *)(self),
        &CFRetain,
        &CFRelease,
        NULL,
    };
    // 创建观察者
    defaultModeObserver = CFRunLoopObserverCreate(NULL, kCFRunLoopBeforeWaiting, YES, 0, &callBack, &context);
    
    // 添加观察者 kCFRunLoopDefaultMode，
    CFRunLoopAddObserver(runloop, defaultModeObserver, kCFRunLoopCommonModes);
}

void callBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    NSLog(@"**********");
    // 从数组取出任务
    // info 就是控制器本身，转换为OC类
    TestViewController *vc = (__bridge TestViewController *)info;
    if (vc.tasks.count == 0) {
        return;
    }
    // 取任务
    RunloopBlock task = vc.tasks.firstObject;
    // 执行任务
    task();
    // 任务执行后删除任务
    [vc.tasks removeObjectAtIndex:0];
}

- (void)addTask:(RunloopBlock)task {
    // self.maxQueueLength 界面最大显示图片数量
    [self.tasks addObject:task];
    if (self.tasks.count > self.maxQueueLength) {
        [self.tasks removeObjectAtIndex:0];
    }
}
@end
