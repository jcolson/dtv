//
//  dtvAppDelegate.h
//  dtv
//
//  Created by Jay Colson on 1/3/09.
//  Copyright Jay Colson 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dtvAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
