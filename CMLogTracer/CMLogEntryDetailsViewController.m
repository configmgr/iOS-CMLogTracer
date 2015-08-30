//
//  CMLogEntryDetailsViewController.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMLogEntryDetailsViewController.h"
#import "CMUtils.h"

@implementation CMLogEntryDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"Line: %ld", nil), self.logEntry.lineNumber, nil];
    
    self.timeLabel.text = [CMUtils localizedTimeStringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.logEntry.dateTime]];
    self.dateLabel.text = [CMUtils localizedDateStringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:self.logEntry.dateTime]];
    self.componentLabel.text = self.logEntry.component;
    self.threadLabel.text = self.logEntry.thread;
    self.fileLabel.text = self.logEntry.file;
    self.messageLabel.text = self.logEntry.message;
    
    if ([self.logEntry.type isEqualToString:@"2"]) {
        self.typeLabel.text = [self.logEntry.type stringByAppendingString:NSLocalizedString(@" (Warning)", nil)];
        [self.typeLabel superview].backgroundColor = [UIColor colorWithRed:255/255.0f green:255.0/255.0f blue:0/255.0f alpha:0.7f];
    } else if ([self.logEntry.type isEqualToString:@"3"]) {
        self.typeLabel.text = [self.logEntry.type stringByAppendingString:NSLocalizedString(@" (Error)", nil)];
        [self.typeLabel superview].backgroundColor = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:0.7f];
    } else {
        self.typeLabel.text = self.logEntry.type;
        [self.typeLabel superview].backgroundColor = [UIColor whiteColor];
    }
}

- (CGSize)expectedMessageLabelSize {
    CGSize expectedSize;
    UIFont *currentFont;
    CGFloat currentWidth;
    CGSize maximumPossibleSize;
    CGRect properlySizedLabelTextRect;
    
    currentWidth = self.tableView.frame.size.width - 40;
    currentFont = self.messageLabel.font;
    maximumPossibleSize = CGSizeMake(currentWidth, 9999);
    properlySizedLabelTextRect = [self.messageLabel.text boundingRectWithSize:maximumPossibleSize
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:currentFont}
                                         context:nil];
    properlySizedLabelTextRect.size.height = properlySizedLabelTextRect.size.height;
    expectedSize = properlySizedLabelTextRect.size;
    
    return expectedSize;
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 6) {
        CGSize expectedLabelSize = [self expectedMessageLabelSize];
        return expectedLabelSize.height + 23;
    } else {
        return 44;
    }
}

-(BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        for (UIView *subView in cell.contentView.subviews) {
            if ([subView isKindOfClass:[UILabel class]]) {
                NSString *copiedText;
                UIPasteboard *pasteboard;
                
                copiedText = [(UILabel *)subView text];
                pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = copiedText;
            }
        }
    }
}

@end
