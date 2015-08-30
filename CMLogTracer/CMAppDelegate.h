//
//  CMAppDelegate.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMDataStore.h"

@interface CMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) CMDataStore *dataStore;

@end
