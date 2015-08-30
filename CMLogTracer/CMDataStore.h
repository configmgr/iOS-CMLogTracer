//
//  CMDataStore.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/15/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CMLogFile.h"
#import "CMLogEntry.h"

@interface CMDataStore : NSObject

@property (nonatomic) NSMutableArray *logFiles;
@property (nonatomic) NSManagedObjectModel *model;
@property (nonatomic) NSManagedObjectContext *context;

- (NSString *)dataStorePath;
- (BOOL)saveChanges;
- (void)loadAllLogFiles;
- (CMLogFile *)createLogFile;
- (void)removeLogFile:(CMLogFile *)logFile;
- (CMLogEntry *)createLogEntry;
- (void)reload;

@end
