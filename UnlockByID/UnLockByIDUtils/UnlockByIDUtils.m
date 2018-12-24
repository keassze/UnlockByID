//
//  UnlockByIDUtils.m
//  UnlockByID
//
//  Created by 何松泽 on 2018/12/20.
//  Copyright © 2018 HSZ. All rights reserved.
//

#import "UnlockByIDUtils.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface UnlockByIDUtils()

@property (nonatomic, strong) LAContext *context;

@end

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

- (void)showVerityWithReason:(NSString *)reason result:(UnlockByIDUtilsCallBack)result
{
    [self showVerityWithTitle:[self getReasonTitleByBiometryType:_context.biometryType reason:reason] allowPassword:NO result:result];
}

- (void)showVerityWithTitle:(NSString *)title
              allowPassword:(BOOL)allowPassword
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
    self.context = [[LAContext alloc] init];
    self.context.localizedFallbackTitle = allowPassword ? @"输入密码" : @"";
    LAPolicy policy = allowPassword ? LAPolicyDeviceOwnerAuthentication : LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    NSError *error;
    if ([self.context canEvaluatePolicy:policy error:&error]) {
        // 设备支持TouchID或者FaceID
        [self.context evaluatePolicy:policy localizedReason:title reply:^(BOOL success, NSError * _Nullable error) {
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
        switch (error.code) {
                
            case LAErrorBiometryNotEnrolled:
                currentState = UnlockByIDUtilsBiometryNotEnrolled;
                NSLog(@"这手机不支持啊");
                break;
                
            case LAErrorPasscodeNotSet:
                currentState = UnlockByIDUtilsPasscodeNotSet;
                NSLog(@"没设置密码啊");
                break;
                
            default:
                NSLog(@"真的没有啊");
                break;
        }
        if (result) {
            result(idIsSuc,currentState);
        }
    }
}

- (NSString *)getReasonTitleByBiometryType:(LABiometryType)type reason:(NSString *)reason
{
    NSString *reasonTitle = @"";
    if (type == LABiometryTypeFaceID) {
        reasonTitle = [NSString stringWithFormat:@"验证面容以进行%@",reason];
    }else if (type == LABiometryTypeTouchID) {
        reasonTitle = [NSString stringWithFormat:@"验证指纹以进行%@",reason];
    }else if (type == LABiometryTypeNone) {
        reasonTitle = [NSString stringWithFormat:@"输入密码以进行%@",reason];
    }
    
    return reasonTitle;
}

- (UnlockByIDUtilsState)translateLAErrorToUnlockByIDUtilsByError:(NSError *)error
{
    UnlockByIDUtilsState currentState = UnlockByIDUtilsSuccess;
    if (!error) {
        return currentState;
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
        case LAErrorInvalidContext:
            currentState = UnlockByIDUtilsInvalidContext;
            break;
            
        default:
            currentState = UnlockByIDUtilsFail;
            break;
    }
    return currentState;
}

@end


