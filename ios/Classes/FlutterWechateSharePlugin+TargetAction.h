//
//  FlutterWechateSharePlugin+TargetAction.h
//  flutter_wechate_share_plugin
//
//  Created by apple on 2021/5/19.
//

#import "FlutterWechateSharePlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface FlutterWechateSharePlugin (TargetAction)

+ (BOOL)performAppDelegateTarget:(Class)cls action:(SEL)sel params:(id)arg, ...;

@end

NS_ASSUME_NONNULL_END
