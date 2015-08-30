//
//  CMUtils.h
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/16/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMUtils : NSObject

+ (NSString *)localizedDateAndTimeStringFromDate:(NSDate *)date;
+ (NSString *)localizedTimeStringFromDate:(NSDate *)date;
+ (NSString *)localizedDateStringFromDate:(NSDate *)date;
+ (NSDate *)dateFromLogEntryDateString:(NSString *)dateString andTimeString:(NSString *)timeString;

@end
