//
//  CMLogImporter.m
//  CMLogTracer
//
//  Created by Andre Bocchini on 10/20/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMLogImporter.h"
#import "CMUtils.h"

@implementation CMLogImporter

@synthesize dataStore = _dataStore;

- (id)initWithDataStore:(CMDataStore *)dataStore {
    self = [super init];
    if (self) {
        self.dataStore = dataStore;
    }
    return self;
}

- (CMLogFile *)importLogFileWithName:(NSString *)name andContents:(NSString *)contents {
    CMLogFile *newLogFile;

    newLogFile = [self.dataStore createLogFile];
    newLogFile.name = name;
    newLogFile.dateAdded = [[NSDate date] timeIntervalSince1970];
    
    if (![self populateLogFile:newLogFile withEntriesFromFileContents:contents]) {
        [self.dataStore removeLogFile:newLogFile];
        newLogFile = nil;
    }
    
    return newLogFile;
}

- (BOOL)populateLogFile:(CMLogFile *)logFile withEntriesFromFileContents:(NSString *)contents {
    int64_t lineNumber;
    NSScanner *scanner = [NSScanner scannerWithString:contents];

    lineNumber = 1;
    while (![scanner isAtEnd]) {
        NSString *message;
        NSString *messageProperties;
        NSString *messageStartIndicator = @"<![LOG[";
        NSString *messageEndIndicator = @"]LOG]!>";
        NSRange messagePropertiesContentRange;
        NSMutableDictionary *messagePropertyDictionary;

        [scanner scanUpToString:messageEndIndicator intoString:&message];
        if ([[message substringToIndex:messageStartIndicator.length] isEqualToString:messageStartIndicator]) {
            message = [message substringFromIndex:messageStartIndicator.length];
            message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else {
            NSLog(@"Found some bad data when parsing a message in log file: %@", logFile.name);
            return NO;
        }
        
        [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&messageProperties];
        messagePropertiesContentRange = NSMakeRange(messageEndIndicator.length+1, messageProperties.length-1-messageEndIndicator.length-1);
        messageProperties = [messageProperties substringWithRange:messagePropertiesContentRange];

        NSArray *messagePropertyList = [messageProperties componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (messagePropertyList.count != 7) {
            NSLog(@"Found some bad data when parsing propeties for log file: %@", logFile.name);
            return NO;
        }
        
        messagePropertyDictionary = [[NSMutableDictionary alloc] init];
        for (NSString *messageProperty in messagePropertyList) {
            NSArray *propertyComponents;
            NSString *propertyName;
            NSString *propertyValue;

            propertyComponents = [messageProperty componentsSeparatedByString:@"="];
            propertyName = propertyComponents[0];
            propertyValue = [propertyComponents[1] substringWithRange:NSMakeRange(1, [propertyComponents[1] length]-2)];

            [messagePropertyDictionary setObject:propertyValue forKey:propertyName];
        }

        CMLogEntry *logEntry = [self createLogEntryWithMessage:message andProperties:messagePropertyDictionary];
        logEntry.lineNumber = lineNumber;
        [logFile addLogEntriesObject:logEntry];
        lineNumber++;
    }
    
    return YES;
}

- (CMLogEntry *)createLogEntryWithMessage:(NSString *)message andProperties:(NSDictionary *)properties {
    CMLogEntry *entry;
    NSString *timeString, *dateString;
    NSDate *date;

    timeString = [properties objectForKey:@"time"];
    dateString = [properties objectForKey:@"date"];
    date = [CMUtils dateFromLogEntryDateString:dateString andTimeString:timeString];
    
    entry = [self.dataStore createLogEntry];

    entry.message = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    entry.dateTime = [date timeIntervalSinceReferenceDate];
    entry.component = [properties objectForKey:@"component"];
    entry.type = [properties objectForKey:@"type"];
    entry.thread = [properties objectForKey:@"thread"];
    entry.file = [properties objectForKey:@"file"];

    return entry;
}

@end
