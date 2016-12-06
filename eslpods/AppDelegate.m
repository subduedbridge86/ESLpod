//
//  AppDelegate.m
//  個人用
//
//  Created by 金子誠也 on 2015/05/15.
//  Copyright (c) 2015年 金子誠也. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 起動2回目以降
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]) {
//        
//        // ここに2回目以降の処理を書く
//        // 今回は特に記述しなくていい
//        // Storyboard を呼ぶ
//        UIStoryboard *TutorialSB = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        
//        // Storyboard の中のどの ViewContorller を呼ぶか
//        // @""の中は Storyboard IDを記述する。ココ間違えばブラック画面かな。
//        UISplitViewController* vc = [TutorialSB instantiateViewControllerWithIdentifier: @"main"];
//        // その画面を表示させる
//        [self.window setRootViewController:vc];
//        
//    } else { // 初回起動時はこっち
//        // UserDefault に一度起動したことを記録
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
//        [[NSUserDefaults standardUserDefaults] synchronize]; //すぐに更新
//        
//        // チュートリアル画面を表示
//        // Storyboard を呼ぶ
//        UIStoryboard *TutorialSB = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        
//        // Storyboard の中のどの ViewContorller を呼ぶか
//        // @""の中は Storyboard IDを記述する。ココ間違えばブラック画面かな。
//        UISplitViewController* vc = [TutorialSB instantiateViewControllerWithIdentifier: @"TutorialViewController"];
//        // その画面を表示させる
//        [self.window setRootViewController:vc];
//        
//    }
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
