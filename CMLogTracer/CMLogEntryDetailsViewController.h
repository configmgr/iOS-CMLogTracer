//
//  CMLogEntryDetailsViewController.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMLogEntry.h"

@interface CMLogEntryDetailsViewController : UITableViewController

@property (nonatomic) CMLogEntry *logEntry;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *componentLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *threadLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end
