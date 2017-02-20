//
//  main.m
//  GCDQueue
//
//  Created by haha on 17/2/13.
//  Copyright © 2017年 myself. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //1.*创建一个全局队列
        /*
         #define DISPATCH_QUEUE_PRIORITY_HIGH 2
         #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
         #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
         被设置成后台级别的队列，它会等待所有比它级别高的队列中的任务执行完或CPU空闲的时候才会执行自己的任务。例如磁盘的读写操作非常耗时，如果我们不需要立即获取到磁盘的数据，我们可以把读写任务放到后台队列中，这样读写任务只会在恰当的时候去执行而不会影响需要更改优先级的其他任务，整个程序也会更加有效率。
         #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
        */
        dispatch_queue_t aQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        //2.*串行队列 serialQueue 设置成NULL的时候默认代表串行。
        dispatch_queue_t sQueue = dispatch_queue_create("com.example.serialQueue", NULL);
        
        //3.*并发队列 concurrent
        dispatch_queue_t cQueue = dispatch_queue_create("com.example.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
        
        //4.*获取主线程 Main Queue
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        //5.*创建队列的自定义上下文
       
        
        /*********添加任务到队列************/
        //1.*异步 dispatch_async/dispatch_async_f  任务会在之后由 GCD 决定执行，以及任务什么时候执行完我们是无法知道确定的。这样的好处是，如果我们需要在后台执行一个基于网络或 CPU 紧张的任务时就使用异步方法 ，这样就不会阻塞当前线程。
       /* dispatch_async在不同队列类型执行的情况
        
        1> 自定义串行队列：当你想串行执行后台任务并追踪它时就是一个好选择。这消除了资源争用，因为你知道一次只有一个任务在执行。
        2> 主队列：这是在一个并发队列上完成任务后更新 UI 的一般选择。
        3> 并发队列：这是在后台执行非 UI 工作的一般选择*/
        dispatch_queue_t myQueue;
        myQueue = dispatch_queue_create("com.example.myqueue", NULL);
        //串行队列＋异步执行 会开启新线程，但是因为任务是串行的，执行完一个，再执行下一个任务
        dispatch_async(myQueue, ^{
            NSLog(@"this is the async serial queue%@",[NSThread currentThread]);

        });
        //并发队列＋异步执行  会开启新线程，任务交替执行（有用，但是很容易出错）
        dispatch_async(cQueue, ^{
            NSLog(@"1this is cQueue");
            NSLog(@"1this is async");
        });
        
        //主队列＋异步执行  不会新建线程  在主线程执行任务，一个一个执行
        dispatch_async(mainQueue, ^{
            NSLog(@"4.this is mainQueue");
            NSLog(@"4.this is async");
        });
        
        //2.*同步 dispatch_sync／dispatch_sync_f
        //串行队列＋同步执行  不会开启新线程，任务一个一个执行（毫无用处）
        dispatch_sync(myQueue, ^{
            NSLog(@"this is the sync serial queue");
        });
        //并发队列＋同步执行   不会开启新线程，任务一个一个执行（几乎没用）
        dispatch_sync(cQueue, ^{
            NSLog(@"2.this is cQueue");
            NSLog(@"2this is sync");
        });
        //主队列＋同步执行  互等  卡住
        dispatch_sync(mainQueue, ^{
            NSLog(@"3.this is main queue");
            NSLog(@"3.this is sync");
        });
        
        dispatch_queue_t newQueue = dispatch_queue_create("serial", NULL);
        //3.*任务执行完后添加一个完成块(Completion Block)
        int a[5] = {1,2,3,4,5};
        int *data = a;
        NSLog(@"avg1----%d",average(data, 5));
        average_async(data, 5, newQueue, ^(int avg) {
            NSLog(@"avg2------%d",avg);
        });
        
        
        //4.*GCD之间的通信   在iOS开发过程中，我们一般在主线程里边进行UI刷新，例如：点击、滚动、拖拽等事件。我们通常把一些耗时的操作放在其他线程，比如说图片下载、文件上传等耗时操作。而当我们有时候在其他线程完成了耗时操作时，需要回到主线程，那么就用到了线程之间的通讯。
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (NSInteger i = 0; i < 2; i++) {
                NSLog(@"this is 1----%@",[NSThread currentThread]);
            }
            //回到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"this is 2---%@",[NSThread currentThread]);
            });

        });
        
        //5.*GCD的栅栏方法  我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅栏一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。这就需要用到dispatch_barrier_async方法在两个操作组间形成栅栏。
        dispatch_async(cQueue, ^{
            NSLog(@"11-----%@",[NSThread currentThread]);
        });
        dispatch_barrier_async(cQueue, ^{
            NSLog(@"12-----%@",[NSThread currentThread]);
        });
        dispatch_async(cQueue, ^{
            NSLog(@"13-----%@",[NSThread currentThread]);
        });
        
        //6.*GCD的延时
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"14------%@",[NSThread currentThread]);
        });
        
        //7.*GCD的一次执行（可做单例）
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"haha");
        });
        
        //8.*GCD的快速迭代
        dispatch_apply(6, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
            NSLog(@"%zu----%@",index,[NSThread currentThread]);
        });
        
        //9.*GCD的队列组
        dispatch_group_t group = dispatch_group_create();
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //执行一个耗时操作异步
        });
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //执行另一个耗时操作异步
        });
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //等前面的耗时操作完成，回到主线程
        });
    }
    return 0;
}

//任务执行完后添加一个完成块(Completion Block),一个Completion Block是在原任务完成后，我们给队列添加的一个代码块。回调代码的经典做法一般是在任务开始时，把completion block当成一个参数。需要我们做的只是把一个指定的block或函数，在指定的队列完成时，提交给这个队列即可。
int average_async(int *data, size_t len, dispatch_queue_t queue, void(^block)(int)) {
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    int avg = average(data,len);
    dispatch_async(queue, ^{
        block(avg);
    });
});
    return 0;
}

int average(int *data, size_t len) {
    int sum = 0;
    for (int i = 0; i < len; i++) {
        sum = sum + *(data + i);
    }
    return sum/len;
}
