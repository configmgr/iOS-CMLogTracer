//
//  CMLogsViewController.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/15/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMDataStore.h"

@interface CMLogsViewController : UITableViewController <UIAlertViewDelegate>

@property (nonatomic) CMDataStore *dataStore;
@property (nonatomic) NSMutableArray *importQueue;

- (void)displayPromptForLogFileName;
- (void)addLogFileToImportQueueWithName:(NSString *)name andContents:(NSString *)contents;
- (void)dismissAnyVisibleImportDialogs;

@end
