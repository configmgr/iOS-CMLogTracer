//
//  CMUtils.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/16/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMUtils.h"

@implementation CMUtils

+ (NSString *)localizedDateAndTimeStringFromDate:(NSDate *)date {
    NSString *dateString;
    NSDateFormatter *dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSString *)localizedTimeStringFromDate:(NSDate *)date {
    NSString *dateString;
    NSDateFormatter *dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSString *)localizedDateStringFromDate:(NSDate *)date {
    NSString *dateString;
    NSDateFormatter *dateFormatter;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (NSDate *)dateFromLogEntryDateString:(NSString *)dateString andTimeString:(NSString *)timeString {
    NSDate *date;
    NSDateFormatter *dateFormatter;
    NSRange timeRange;
    NSString *timeOnlyString;
    NSString *dateAndTimeString;
    
    timeRange = NSMakeRange(0, 12);
    timeOnlyString = [timeString substringWithRange:timeRange];
    
    dateAndTimeString = [NSString stringWithFormat:@"%@ %@", timeOnlyString, dateString];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm:ss.SSS MM-dd-yyyy";
    date = [dateFormatter dateFromString:dateAndTimeString];
    
    return date;
}

@end
