//
//  NSObject+Zombie.m
//  Demo
//
//  Created by wsong on 2018/6/22.
//  Copyright © 2018年 wsong. All rights reserved.
//  该分类可以用于测试人员测试代码时使用，不建议使用在上架版本。。毕竟僵尸对象不释放耗性能

#import "NSObject+Zombie.h"
#import <objc/runtime.h>

@interface ZombieProxy: NSProxy

@property (nonatomic, unsafe_unretained) Class zombie_originClass;

+ (id)alloc NS_UNAVAILABLE;

@end

@implementation ZombieProxy

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self reportException:_cmd];
}

- (nullable NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    [self reportException:sel];
    return nil;
}

- (void)dealloc {
    [self reportException:_cmd];
}

- (void)finalize {
    [self reportException:_cmd];
}

- (NSString *)description {
    [self reportException:_cmd];
    return nil;
}

- (NSString *)debugDescription {
    [self reportException:_cmd];
    return nil;
}

- (void)reportException:(SEL)sel {
    [[NSException exceptionWithName:@"僵尸对象异常"
                             reason:[NSString stringWithFormat:@"僵尸对象：%@调用了：%@导致崩溃了", self.zombie_originClass, NSStringFromSelector(sel)]
                           userInfo:nil] raise];
    // 这里可以延迟1~3s,将错误信息上报，如果使用了第三方bug提交，可以不延迟，自动会捕获异常
}

@end

@interface NSObject ()

@property (nonatomic, unsafe_unretained) Class zombie_originClass;

@end

@implementation NSObject (Zombie)

// 这里可以配置需要检测的僵尸对象的前缀，如果数组为空，表示检测所有的
char *zombieChekClassPrefixList[] = {"WS"};

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, NSSelectorFromString(@"dealloc")),
                                   class_getInstanceMethod(self, @selector(zombie_dealloc)));
}

- (Class)zombie_originClass {
    return nil;
}

- (void)zombie_dealloc {
    
    static Class originClass;
    size_t length = sizeof(zombieChekClassPrefixList) / sizeof(char *);
    
    if (length > 0) {
        for (int i = 0; i < length; i++) {
            // 这里使用C语言的比较是因为OC会生成对象从而崩溃
            if (strncmp(zombieChekClassPrefixList[i], object_getClassName(self), strlen(zombieChekClassPrefixList[i])) == 0) {
                originClass = self.class;
                object_setClass(self, [ZombieProxy class]);
                self.zombie_originClass = originClass;
                break;
            }
        }
        if (!self.zombie_originClass) {
            [self zombie_dealloc];
        }
    } else {
        originClass = self.class;
        object_setClass(self, [ZombieProxy class]);
        self.zombie_originClass = originClass;
    }
}

@end
