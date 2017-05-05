//
//  ViewController.m
//  RunLoop
//
//  Created by 康鹏鹏 on 2017/5/4.
//  Copyright © 2017年 dhcc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) dispatch_source_t timer;

/** test5 用到的属性 */
@property (nonatomic, strong) NSThread *subThread;
@end

@implementation ViewController

//**************************************例1
- (void)test1 {
    // 1.
    // 添加一个timer到当前Runloop的默认模式下
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerMethod1) userInfo:nil repeats:YES];
}
- (void)timerMethod1 {
    static int num = 0;
    num++;
    NSLog(@"%d", num);
}


//**************************************例2
- (void)test2 {
    // 2.
    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerMethod2) userInfo:nil repeats:YES];
    // 添加到Runloop中
    /**
     * Runloop模式： 默认事件 NSDefaultRunLoopMode 时钟、网络事件
     *              UI处理模式 UITrackingRunLoopMode（只能被UI事件触发）
     *              占位模式 NSRunLoopCommonModes (UI和默认模式都添加)
     *
     */
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
- (void)timerMethod2 {
    // 添加耗时操作，主线程被阻塞
    [NSThread sleepForTimeInterval:1.0];
    static int num = 0;
    num++;
    NSLog(@"%d", num);
}


//**************************************例3
- (void)test3 {
    // 3.在子线程处理耗时操作
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerMethod3) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        // 线程走到此处挂掉，线程被释放，不能执行 timerMethod 方法
        // 线程被释放，Runloop随机销毁
    }];
    [thread start];
}
- (void)timerMethod3 {
    // 添加耗时操作，主线程被阻塞
    [NSThread sleepForTimeInterval:1.0];
    static int num = 0;
    num++;
    NSLog(@"%d", num);
}

//**************************************例4
- (void)test4 {
    // 4.开启子线程的 Runloop 循环
    NSThread *thread = [[NSThread alloc] initWithBlock:^{
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerMethod4) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        // 开启Runloop循环，run代表永远不会停下来，变为常驻线程
        [[NSRunLoop currentRunLoop] run];
        // 替换 上方 run 方法
        /*
        while (<#runloop跑起来的条件#>) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
        }
         */
        // 该打印信息不能被执行，上方 Runloop方法死循环，走不到此处
        NSLog(@"此处不能被执行！！！");
    }];
    [thread start];
}
- (void)timerMethod4 {
    // 杀掉线程终止Runloop循环 （添加终止条件）
    [NSThread exit];
    // 添加耗时操作，主线程被阻塞
    [NSThread sleepForTimeInterval:1.0];
    
    static int num = 0;
    num++;
    NSLog(@"%d", num);
}


//**************************************例5
/** 创建子线程 */
- (void)test5 {
    NSThread *subThread = [[NSThread alloc] initWithTarget:self selector:@selector(subThreadEnter) object:nil];
    [subThread setName:@"SubThread"];
    [subThread start];
    self.subThread = subThread;
}
// 保证子线程不被销毁
- (void)subThreadEnter {
    @autoreleasepool {
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        //如果注释了下面这一行，子线程中的任务并不能正常执行
        [runloop addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
        [runloop run];

    }
}
// 触发子线程任务
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(subThreadOpetion) onThread:self.subThread withObject:nil waitUntilDone:NO];
}
/** 子线程任务 */
- (void)subThreadOpetion {
    NSLog(@"启动RunLoop后--%@",[NSRunLoop currentRunLoop].currentMode);
    NSLog(@"%@----子线程任务开始",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:1.0];
    NSLog(@"%@----子线程任务结束",[NSThread currentThread]);
}


//**************************************例6
- (void)testGCD {
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 创建一个定时器
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 设置定时器 1 * NSEC_PER_SEC = 1 s
    dispatch_time_t interval = 1 * NSEC_PER_SEC;
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, interval, 0);
    // 设置回调
    dispatch_source_set_event_handler(_timer, ^{
        sleep(1.0);
        NSLog(@"-------- %@", [NSThread currentThread]);
    });
    // 启动定时器
    dispatch_resume(_timer);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self test1];

//    [self test2];

//    [self test3];

//    [self test4];
    
//    [self test5];
    
    // GCD 队列处理，内部已经封装Runloop
    [self testGCD];
}





@end
