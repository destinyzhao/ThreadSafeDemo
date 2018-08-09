//
//  ViewController.m
//  ThreadSafeDemo
//
//  Created by Destiny on 2018/8/9.
//  Copyright © 2018年 Destiny. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    dispatch_semaphore_t semaphore;
}

@property (assign, nonatomic) NSInteger ticketNumber;
@property (strong, nonatomic) NSLock *lock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.ticketNumber = 100;
    self.lock = [[NSLock alloc]init];
    semaphore = dispatch_semaphore_create(1);
    
    for (NSInteger i = 0; i < 10; i++) {
        NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(sellTicketsWithNSLock) object:nil];
        [thread setName:[NSString stringWithFormat:@"售票员-%zd",i]];
        [thread start];
    }
}

- (void)sellTicketsWithSynchronized
{
    while (true) {
        @synchronized(self){
            if (self.ticketNumber > 0) {
                self.ticketNumber --;
                NSThread *thread = [NSThread currentThread];
                NSLog(@"%@卖了一张票,还剩%ld张票",[thread name],self.ticketNumber);
            }else{
                // 退出当前线程
                [NSThread exit];
            }
        }
    }
}

- (void)sellTicketsWithNSLock
{
    while (true) {
        [self.lock lock];
        if (self.ticketNumber > 0) {
            self.ticketNumber --;
            NSThread *thread = [NSThread currentThread];
            NSLog(@"%@卖了一张票,还剩%ld张票",[thread name],self.ticketNumber);
        }else{
            // 退出当前线程
            [NSThread exit];
        }
         [self.lock unlock]; // 解锁
    }
}

- (void)sellTicketsWithSemaphore
{
    while (true) {
        //信号==0等待，>=1减1不等待进入下一步代码
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (self.ticketNumber > 0) {
            self.ticketNumber --;
            NSThread *thread = [NSThread currentThread];
            NSLog(@"%@卖了一张票,还剩%ld张票",[thread name],self.ticketNumber);
        }else{
            // 退出当前线程
            [NSThread exit];
        }
        // 信号 +1
        dispatch_semaphore_signal(semaphore);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
