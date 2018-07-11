//
//  ViewController.m
//  Demo
//
//  Created by wsong on 2018/6/22.
//  Copyright © 2018年 wsong. All rights reserved.
//

#import "ViewController.h"

@interface WSZombie: NSObject

@end

@implementation WSZombie

- (void)dealloc {
    NSLog(@"释放了");
}

@end



@interface ViewController ()

@property (nonatomic, assign) WSZombie *zombie;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.zombie = [[WSZombie alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@", self.zombie.description);
}

@end
