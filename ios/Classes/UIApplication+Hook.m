//
//  UIApplication+Hook.m
//  flutter_wechate_share_plugin
//
//  Created by apple on 2021/5/19.
//

#import "UIApplication+Hook.h"
#import <objc/runtime.h>
#import "FlutterWechateSharePlugin.h"
@implementation UIApplication (Hook)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oldMethod = class_getInstanceMethod([self class], @selector(setDelegate:));
        Method newMethod = class_getInstanceMethod([self class], @selector(flutter_setDelegate:));
        methodExchange([self class], oldMethod, newMethod);
    });
}

static inline void
/// 方法交换
/// @param class 需要交换方法的类
/// @param oldMethod 类的方法
/// @param newMethod 交换后的实现方法
methodExchange(Class class,Method oldMethod,Method newMethod)
{
    BOOL isAddedMethod = class_addMethod(class, method_getName(oldMethod), method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (isAddedMethod) {
        class_replaceMethod(class, method_getName(newMethod), method_getImplementation(oldMethod), method_getTypeEncoding(oldMethod));
    } else {
        method_exchangeImplementations(oldMethod, newMethod);
    }
}

static inline void
/// 获取要交换的两个方法
/// @param class 被交换的类
/// @param selector 实现交换的类
classSelectorHook(Class class,SEL selector)
{
    Method oldMethod = class_getInstanceMethod(class, selector);
    NSString *oldSelName = NSStringFromSelector(method_getName(oldMethod));

    // 在FlutterWechateSharePlugin实现
    Method newMethod = class_getInstanceMethod([FlutterWechateSharePlugin class], NSSelectorFromString([NSString stringWithFormat:@"flutter_%@",oldSelName]));

    methodExchange(class, oldMethod, newMethod);
}

- (void)flutter_setDelegate:(id<UIApplicationDelegate>) delegate
{
    static dispatch_once_t delegateOnceToken;
    dispatch_once(&delegateOnceToken, ^{
        // 交换application的一些方法
        classSelectorHook([delegate class], @selector(application:handleOpenURL:));
        classSelectorHook([delegate class], @selector(application:openURL:options:));
        classSelectorHook([delegate class], @selector(application:openURL:sourceApplication:annotation:));
        classSelectorHook([delegate class], @selector(application:continueUserActivity:restorationHandler:));
    });

    // 此时的flutter_setDelegate为原delegate，保证不影响原始功能
    [self flutter_setDelegate:delegate];
}



@end
