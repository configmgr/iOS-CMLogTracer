//
//  CMLogImporter.h
//  CMLogTracer
//
//  Created by Andre Bocchini on 10/20/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMDataStore.h"
#import "CMLogFile.h"
#import "CMLogEntry.h"

@interface CMLogImporter : NSObject

@property (nonatomic) CMDataStore *dataStore;

- (id)initWithDataStore:(CMDataStore *)dataStore;
- (CMLogFile *)importLogFileWithName:(NSString *)name andContents:(NSString *)contents;

@end
