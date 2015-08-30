//
//  CMAppDelegate.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <DBChooser/DBChooser.h>
#import "CMAppDelegate.h"
#import "CMLogsViewController.h"

@implementation CMAppDelegate

@synthesize dataStore;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.dataStore = [[CMDataStore alloc] init];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation
{
    if ([[DBChooser defaultChooser] handleOpenURL:url]) {
        // This was a Chooser response and handleOpenURL automatically ran the
        // completion block
        return YES;
    } else {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* inboxPath = [documentsDirectory stringByAppendingPathComponent:@"Inbox"];
        NSArray *inboxFiles = [fileManager contentsOfDirectoryAtPath:inboxPath error:nil];
        NSString *logFilePath = [inboxPath stringByAppendingPathComponent:inboxFiles[0]];
        NSString *logFileName = [logFilePath lastPathComponent];
        NSString *logFileContents = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
        [fileManager removeItemAtPath:logFilePath error:nil];

        UINavigationController *navigationController = (UINavigationController *)[[app keyWindow] rootViewController];
        CMLogsViewController *logsViewController = (CMLogsViewController *)[[navigationController viewControllers] objectAtIndex:0];
        [logsViewController addLogFileToImportQueueWithName:logFileName andContents:logFileContents];
    }
    
    return NO;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    UINavigationController *navigationController = (UINavigationController *)[self.window rootViewController];
    CMLogsViewController *logsViewController = (CMLogsViewController *)[[navigationController viewControllers] objectAtIndex:0];

    [logsViewController dismissAnyVisibleImportDialogs];
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
{
    UINavigationController *navigationController = (UINavigationController *)[self.window rootViewController];
    CMLogsViewController *logsViewController = (CMLogsViewController *)[[navigationController viewControllers] objectAtIndex:0];

    if (logsViewController.importQueue.count > 0) {
        [navigationController popToRootViewControllerAnimated:YES];
        [logsViewController displayPromptForLogFileName];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
