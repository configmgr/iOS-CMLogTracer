//
//  CMLogFile.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/16/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMLogEntry;

@interface CMLogFile : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic) NSTimeInterval dateAdded;
@property (nonatomic, retain) NSSet *logEntries;
@end

@interface CMLogFile (CoreDataGeneratedAccessors)

- (void)addLogEntriesObject:(CMLogEntry *)value;
- (void)removeLogEntriesObject:(CMLogEntry *)value;
- (void)addLogEntries:(NSSet *)values;
- (void)removeLogEntries:(NSSet *)values;

@end
