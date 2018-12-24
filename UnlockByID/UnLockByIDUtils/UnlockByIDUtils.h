//
//  UnlockByIDUtils.h
//  UnlockByID
//
//  Created by 何松泽 on 2018/12/20.
//  Copyright © 2018 HSZ. All rights reserved.
//

/*
 IOS 8.0以下不支持TouchID||FaceID
 使用FaceID | TouchID时需要保证APP处于活跃，
 因此不要在applicationWillEnterForeground | didReceiveRemoteNotification调用
 */
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnlockByIDUtilsState) {
    UnlockByIDUtilsUnSupport = 0,       // 设备不支持
    UnlockByIDUtilsSuccess,             // 验证成功
    UnlockByIDUtilsFail,                // 验证失败
    UnlockByIDUtilsCancelByUser,        // 用户取消验证
    UnlockByIDUtilsCancelBySystem,      // 验证被系统取消
    UnlockByIDUtilsUserFallback,        // 用户点击了输入密码()
    UnlockByIDUtilsTouchIDNotSet,       // 用户没有设置TouchID|FaceID
    UnlockByIDUtilsPasscodeNotSet,      // 用户没有设置密码
    UnlockByIDUtilsTouchIDNotAvailable, // TouchID|FaceID 无效
    UnlockByIDUtilsBiometryNotEnrolled, // 没有录入 TouchID|FaceID
    UnlockByIDUtilsAppCancel,           // 取消ID授权(后台挂起)
    UnlockByIDUtilsInvalidContext,      // 取消ID授权(Context失效)
};

typedef void(^UnlockByIDUtilsCallBack)(BOOL isSuc,UnlockByIDUtilsState state);

NS_ASSUME_NONNULL_BEGIN

@interface UnlockByIDUtils : NSObject

+ (instancetype)shareManager;


/**
 生物类ID验证（默认不允许使用密码进行操作）

 @param reason 底部描述（文本：验证+支持的ID+以进行reason）
 @param result 验证结果回调
 */
- (void)showVerityWithReason:(NSString *)reason
                      result:(UnlockByIDUtilsCallBack)result;

/**
 生物类ID验证

 @param title 底部文本（用于在此验证）
 @param allowPassword 是否允许密码通过验证
 @param result 验证结果回调
 */
- (void)showVerityWithTitle:(NSString *)title
              allowPassword:(BOOL)allowPassword
                     result:(UnlockByIDUtilsCallBack)result;

@end

NS_ASSUME_NONNULL_END
