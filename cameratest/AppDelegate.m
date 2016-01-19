//
//  AppDelegate.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

  
  [Parse enableLocalDatastore];
  
  // ****************************************************************************
  // Uncomment this line if you want to enable Crash Reporting
  // [ParseCrashReporting enable];
  //
  [Parse setApplicationId:@"aIuqkMbhTodVE9zDhLau9H6750m9AgfvLf9KRsmD"
                clientKey:@"TERnI1nc1PAqgAHYsjIKHghuF4QgcjbHtdOqWXaz"];
  [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];

  // Uncomment and fill in with your Parse credentials:
  // [Parse setApplicationId:@"your_application_id" clientKey:@"your_client_key"];
  //
  // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
  // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
  // [PFFacebookUtils initializeFacebook];
  // ****************************************************************************
  
  [PFUser enableAutomaticUser];
  
  PFACL *defaultACL = [PFACL ACL];
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
//  self.viewController = [[ViewController alloc] initWithNibName:@"LoginCreate" bundle:nil];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  
  
  // If you would like all objects to be private by default, remove this line.
  [defaultACL setPublicReadAccess:YES];
  
  [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
  
  if (application.applicationState != UIApplicationStateBackground) {
    // Track an app open here if we launch with a push, unless
    // "content_available" was used to trigger a background push (introduced in iOS 7).
    // In that case, we skip tracking here to avoid double counting the app-open.
    BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
    BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
    BOOL noPushPayload = !launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
      [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
  }
  
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
  if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
  } else
#endif
  {
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                     UIRemoteNotificationTypeAlert |
                                                     UIRemoteNotificationTypeSound)];
  }
  
  

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{  [FBSDKAppEvents activateApp];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
  return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                        openURL:url
                                              sourceApplication:sourceApplication
                                                     annotation:annotation];
}

@end
