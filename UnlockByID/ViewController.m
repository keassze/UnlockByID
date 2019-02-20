//
//  ViewController.m
//  UnlockByID
//
//  Created by 何松泽 on 2018/12/20.
//  Copyright © 2018 HSZ. All rights reserved.
//

#import "ViewController.h"
#import "UnLockByIDUtils/UnlockByIDUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"test" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor brownColor]];
    [btn addTarget:self action:@selector(checkID) forControlEvents:UIControlEventTouchUpInside];
    [btn setFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:btn];
}

- (void)checkID
{
    [[UnlockByIDUtils shareManager] showVerityWithAllowPassword:YES result:^(BOOL isSuc, UnlockByIDUtilsState state) {
        NSLog(@"%d",state);
    }];
}

@end
