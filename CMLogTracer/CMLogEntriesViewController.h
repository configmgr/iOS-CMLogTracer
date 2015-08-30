//
//  CMLogEntriesViewController.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMLogFile.h"

@interface CMLogEntriesViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic) CMLogFile *logFile;
@property (nonatomic) NSArray *logEntries;

@end
