//
//  CMLogEntry.h
//  CMLogTracer
//
//  Created by Andre Bocchini on 11/5/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CMLogFile;

@interface CMLogEntry : NSManagedObject

@property (nonatomic, retain) NSString * component;
@property (nonatomic) NSTimeInterval dateTime;
@property (nonatomic, retain) NSString * file;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * thread;
@property (nonatomic, retain) NSString * type;
@property (nonatomic) int64_t lineNumber;
@property (nonatomic, retain) CMLogFile *logFile;

@end
