//
//  ViewController.m
//  XLLGCDTest
//
//  Created by 肖乐 on 2018/3/20.
//  Copyright © 2018年 IMMoveMobile. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /**
     一、“同步派发 sync”与“异步派发 async”
     同步派发：不具备开启新线程的能力，交给他的block(任务)，只会在当前线程执行，并且同步函数一定是的等到任务被执行后return
     异步派发：具备开启新线程的能力，但是不一定开启新线程。交给它的block，GCD底层分发给任何可能的线程去执行，开发者无法控制。它会立即返回，不会等待任务被执行
     
     以上两点有特例。就是如果是主队列，两个函数一定会安排任务在主线程执行，异步派发也因为这个所以不一定开启新线程。同时说明主队列是最特殊的一个队列。
     
     */
}



- (IBAction)clickAction:(id)sender {
    
    [self test6];
}

// 异步派发+串行队列
- (void)test1
{
    // 自己创建的串行队列
    dispatch_queue_t squeue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_async(squeue, ^{
        
        NSLog(@"任务1--%@", [NSThread currentThread]);
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"任务2--%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
    
    /**
     输出
     2018-03-20 21:02:46.302640+0800 XLLGCDTest[1598:34803] 开始--<NSThread: 0x600000073600>{number = 1, name = main}
     2018-03-20 21:02:46.303010+0800 XLLGCDTest[1598:34803] 结束--<NSThread: 0x600000073600>{number = 1, name = main}
     2018-03-20 21:02:46.303022+0800 XLLGCDTest[1598:34866] 任务1--<NSThread: 0x600000269500>{number = 3, name = (null)}
     2018-03-20 21:02:46.303521+0800 XLLGCDTest[1598:34803] 任务2--<NSThread: 0x600000073600>{number = 1, name = main}
     */
    /**
     结论:
     1.异步派发不会阻塞队列，所以test1执行完开始后，立刻执行了结束
     2.”异步派发+串行队列“可以开启一个新线程，所以任务1不是主线程
     3.“异步派发+主串行队列”不开启新线程，所以任务2仍是主线程
     */
}

// 异步派发+并行队列
- (void)test2
{
    // 自己创建的并行队列
    dispatch_queue_t cqueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_async(cqueue, ^{
        
        NSLog(@"任务1--%@", [NSThread currentThread]);
    });
    dispatch_async(cqueue, ^{
        
        NSLog(@"任务2--%@", [NSThread currentThread]);
    });
    dispatch_async(cqueue, ^{
        
        NSLog(@"任务3--%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
    
    /**
     输出：
     2018-03-20 21:24:47.319299+0800 XLLGCDTest[1974:48326] 开始--<NSThread: 0x60400006fc00>{number = 1, name = main}
     2018-03-20 21:24:47.319593+0800 XLLGCDTest[1974:48326] 结束--<NSThread: 0x60400006fc00>{number = 1, name = main}
     2018-03-20 21:24:47.319607+0800 XLLGCDTest[1974:48518] 任务1--<NSThread: 0x60000026d580>{number = 3, name = (null)}
     2018-03-20 21:24:47.319637+0800 XLLGCDTest[1974:48984] 任务3--<NSThread: 0x604000465440>{number = 5, name = (null)}
     2018-03-20 21:24:47.319653+0800 XLLGCDTest[1974:48977] 任务2--<NSThread: 0x600000268b80>{number = 4, name = (null)}
     */
    /**
     结论:
     1.两者组合后，3个任务开启了3个线程
     2.先执行了主线程操作，然后又回头执行3个任务
     3.这3个任务在不同线程同时执行，没有先后顺序
     */
}

// 同步派发+串行队列
- (void)test3
{
    // 自己创建的串行队列
    dispatch_queue_t squeue = dispatch_queue_create("serial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_sync(squeue, ^{
        NSLog(@"任务1--%@", [NSThread currentThread]);
    });
    dispatch_sync(squeue, ^{
        NSLog(@"任务2--%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
    /**
     输出：
     2018-03-20 21:33:22.028001+0800 XLLGCDTest[2112:53526] 开始--<NSThread: 0x60400007b980>{number = 1, name = main}
     2018-03-20 21:33:22.028492+0800 XLLGCDTest[2112:53526] 任务1--<NSThread: 0x60400007b980>{number = 1, name = main}
     2018-03-20 21:33:22.028858+0800 XLLGCDTest[2112:53526] 任务2--<NSThread: 0x60400007b980>{number = 1, name = main}
     2018-03-20 21:33:22.028952+0800 XLLGCDTest[2112:53526] 结束--<NSThread: 0x60400007b980>{number = 1, name = main}
     */
    
    /**
     结论：
     1.同步串行任务执行时会导致线程阻塞（一般都不会这么搞，除非你另有它图，比如微会议里的启动图加载数据）
     */
}

// 同步派发+并行队列
- (void)test4
{
    // 自己创建的并行队列
    dispatch_queue_t cqueue = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_sync(cqueue, ^{
        
        NSLog(@"任务1--%@", [NSThread currentThread]);
    });
    dispatch_sync(cqueue, ^{
        
        NSLog(@"任务2--%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
    /**
     输出：
     2018-03-20 21:39:28.998304+0800 XLLGCDTest[2238:58139] 开始--<NSThread: 0x6000000644c0>{number = 1, name = main}
     2018-03-20 21:39:28.998569+0800 XLLGCDTest[2238:58139] 任务1--<NSThread: 0x6000000644c0>{number = 1, name = main}
     2018-03-20 21:39:28.998859+0800 XLLGCDTest[2238:58139] 任务2--<NSThread: 0x6000000644c0>{number = 1, name = main}
     2018-03-20 21:39:28.999075+0800 XLLGCDTest[2238:58139] 结束--<NSThread: 0x6000000644c0>{number = 1, name = main}
     */

    /**
     结论:
     同步派发意味着：
     1.不能开启子线程，任务创建之后必须执行完才能走
     并行队列意味着：
     1.任务之间不需要排队，具有同时被执行的潜质
     
     但是即便是并行队列，同步限制了线程的唯一性，即始终在主线程。并发的潜质仍旧发挥不出来
     */
}

// 同步派发+主队列
- (void)test5
{
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_sync(dispatch_get_main_queue(), ^{
       
        NSLog(@"任务1--%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
}

// 内外为同一个串行队列
- (void)test6
{
    // 创建一个串行队列
    dispatch_queue_t  squeue = dispatch_queue_create("标识符", DISPATCH_QUEUE_SERIAL);
    NSLog(@"开始--%@", [NSThread currentThread]);
    dispatch_async(squeue, ^{
        
        NSLog(@"内部开始--%@", [NSThread currentThread]);
        dispatch_sync(squeue, ^{
            NSLog(@"任务1---%@", [NSThread currentThread]);
        });
        dispatch_sync(squeue, ^{
            NSLog(@"任务2---%@", [NSThread currentThread]);
        });
        NSLog(@"内部结束-----%@", [NSThread currentThread]);
    });
    NSLog(@"结束--%@", [NSThread currentThread]);
    
    /**
     分析：这个也是很经典的死锁代码，为什么呢？
     1. 执行异步操作的时候，test5这个函数相当于外部任务，async下的block相当于内部任务。
     因为异步函数会直接return,所以test5这个任务直接执行。之后再回头执行async下的任务
     
     当执行async里的block任务的时候，我们发现里面还有同步派发
     
     此时async下的任务其实相当于一个外部任务，而sync下的block相当于一个内部任务。
     我们知道sync必须执行完任务后才return。但是他没法执行完任务。为什么呢？因为它的队列与
     外部任务async下的队列是同一个，且都是串行队列。根据前进先出原则，这个任务必须得排队等候。
     
     而内部任务不返回，外部任务没法执行下一步。所以内部任务在等待其他任务被执行完，而那个所谓的其他任务又在等待内部任务执行才能操作下一步。就是这么一个环环相扣的原因，导致了死锁
     */
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
