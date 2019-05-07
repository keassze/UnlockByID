//
//  UnlockByIDUtils.m
//  UnlockByID
//
//  Created by 何松泽 on 2018/12/20.
//  Copyright © 2018 HSZ. All rights reserved.
//

#import "UnlockByIDUtils.h"
#import <LocalAuthentication/LocalAuthentication.h>

static UnlockByIDUtils *_unlockByIDUtils = nil;
@implementation UnlockByIDUtils

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _unlockByIDUtils = [[UnlockByIDUtils alloc] init];
    });
    return _unlockByIDUtils;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)showVerityWithAllowPassword:(BOOL)allowPassword
                             result:(UnlockByIDUtilsCallBack)result
{
    __weak typeof(self)weakSelf = self;
    __block UnlockByIDUtilsState currentState = UnlockByIDUtilsUnSupport;
    __block BOOL idIsSuc = NO;
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
        // 设备低于8.0的不支持调用
        if (result) {
            result(idIsSuc,currentState);
        }
        return;
    }
    
    /*
     每次验证都要初始化context
     原因是验证结果回调(成功|失败)后的context不再reply
     */
    LAContext *context = [[LAContext alloc] init];
    context.localizedFallbackTitle = allowPassword ? @"输入密码" : @" ";
    
    NSString *title;
    if (@available(ios 11,*)) {
        title = [self getReasonTitleByBiometryType:context.biometryType];
    }
    
    LAPolicy policy = allowPassword ? LAPolicyDeviceOwnerAuthentication : LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    NSError *error;
    if ([context canEvaluatePolicy:policy error:&error]) {
        // 设备支持TouchID或者FaceID
        [context evaluatePolicy:policy localizedReason:title reply:^(BOOL success, NSError * _Nullable error) {
            idIsSuc = success;
            // 获取当前error类型
            currentState = [weakSelf translateLAErrorToUnlockByIDUtilsByError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    result(idIsSuc,currentState);
                    return;
                }
            });
            
        }];
    }else {
        currentState = [weakSelf translateLAErrorToUnlockByIDUtilsByError:error];
        if (result) {
            result(idIsSuc,currentState);
        }
    }
}

- (NSString *)getReasonTitleByBiometryType:(LABiometryType)type
{
    NSString *reasonTitle = @"";
    if (type == LABiometryTypeFaceID) {
        reasonTitle = [NSString stringWithFormat:@"验证面容"];
    }else if (type == LABiometryTypeTouchID) {
        reasonTitle = [NSString stringWithFormat:@"验证指纹"];
    }else if (type == LABiometryTypeNone) {
        reasonTitle = [NSString stringWithFormat:@"输入密码"];
    }
    
    return reasonTitle;
}

- (UnlockByIDUtilsState)translateLAErrorToUnlockByIDUtilsByError:(NSError *)error
{
    UnlockByIDUtilsState currentState = UnlockByIDUtilsSuccess;
    if (!error) {
        return currentState;
    }
    
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber10_11) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        switch (error.code) {
                
            case LAErrorTouchIDLockout:
                currentState = UnlockByIDUtilsBiometryLockout;
                return currentState;
            case LAErrorTouchIDNotEnrolled:
                currentState = UnlockByIDUtilsBiometryNotEnrolled;
                return currentState;
            case LAErrorTouchIDNotAvailable:
                currentState = UnlockByIDUtilsBiometryNotAvailable;
                return currentState;
                
            default:
                break;
        }
#pragma clang diagnostic pop
    }
    
    switch (error.code) {
        case LAErrorAuthenticationFailed:
            currentState = UnlockByIDUtilsFail;
            break;
        case LAErrorUserCancel:
            currentState = UnlockByIDUtilsCancelByUser;
            break;
        case LAErrorSystemCancel:
            currentState = UnlockByIDUtilsCancelBySystem;
            break;
        case LAErrorUserFallback:
            currentState = UnlockByIDUtilsUserFallback;
            break;
        case LAErrorPasscodeNotSet:
            currentState = UnlockByIDUtilsPasscodeNotSet;
            break;
        case LAErrorBiometryNotEnrolled:
            currentState = UnlockByIDUtilsBiometryNotEnrolled;
            break;
        case LAErrorAppCancel:
            currentState = UnlockByIDUtilsAppCancel;
            break;
        case LAErrorInvalidContext:
            currentState = UnlockByIDUtilsInvalidContext;
            break;
        case LAErrorBiometryNotAvailable:
            currentState = UnlockByIDUtilsBiometryNotAvailable;
            break;
        case LAErrorBiometryLockout:
            currentState = UnlockByIDUtilsBiometryLockout;
            break;
        case LAErrorNotInteractive:
            currentState = UnlockByIDUtilsNotInteractive;
            break;
            
        default:
            currentState = UnlockByIDUtilsFail;
            break;
    }
    return currentState;
}

@end


