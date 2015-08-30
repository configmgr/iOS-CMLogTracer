//
//  CMLogEntriesViewController.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/14/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMLogEntriesViewController.h"
#import "CMLogEntryDetailsViewController.h"
#import "CMLogFile.h"
#import "CMLogEntry.h"
#import "CMUtils.h"

@interface CMLogEntriesViewController ()

@property (nonatomic) NSMutableArray *searchResults;

@end

@implementation CMLogEntriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:YES];
    NSSortDescriptor *lineNumberDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineNumber" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:dateDescriptor, lineNumberDescriptor, nil];
    
    self.logEntries = [self.logFile.logEntries sortedArrayUsingDescriptors:sortDescriptors];
    self.searchResults = [[NSMutableArray alloc] init];
    
    UINib *logEntryTableCellNib = [UINib nibWithNibName:@"LogEntryTableCell" bundle:nil];
    [self.tableView registerNib:logEntryTableCellNib forCellReuseIdentifier:@"LogEntryTableCell"];
    [self.searchDisplayController.searchResultsTableView registerNib:logEntryTableCellNib forCellReuseIdentifier:@"LogEntryTableCell"];
    
    self.navigationItem.title = self.logFile.name;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath;
    CMLogEntry *logEntry;
    
    indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
    if (indexPath) {
        logEntry = self.searchResults[indexPath.row];
    } else {
        indexPath = [self.tableView indexPathForSelectedRow];
        logEntry = self.logEntries[indexPath.row];
    }

    [(CMLogEntryDetailsViewController *)[segue destinationViewController] setLogEntry:logEntry];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return self.logEntries.count;
    } else {
        return self.searchResults.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CMLogEntry *logEntry;
    UITableViewCell *cell;
    NSString *entryTimeAndDate;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"LogEntryTableCell" forIndexPath:indexPath];

    if (tableView == self.tableView) {
        logEntry = self.logEntries[indexPath.row];
    } else {
        logEntry = self.searchResults[indexPath.row];
    }
    
    entryTimeAndDate = [CMUtils localizedDateAndTimeStringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:logEntry.dateTime]];
    
    [(UILabel *)[cell viewWithTag:1] setText:logEntry.message];
    [(UILabel *)[cell viewWithTag:2] setText:[NSString stringWithFormat:@"%@", entryTimeAndDate]];
    [(UILabel *)[cell viewWithTag:3] setText:[NSString stringWithFormat:NSLocalizedString(@"Line: %d", nil), logEntry.lineNumber]];
    
    if ([logEntry.type isEqualToString:@"2"]) {
        cell.backgroundColor = [UIColor colorWithRed:255/255.0f green:255.0/255.0f blue:0/255.0f alpha:0.6f];
    } else if ([logEntry.type isEqualToString:@"3"]) {
        cell.backgroundColor = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:0.6f];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"DisplayLogEntryDetails" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

#pragma mark - Search

- (void)buildSearchResultsForSearchString:(NSString *)searchString {
    NSString *trimmedSearchString;
    NSString *scope;
    NSCompoundPredicate *finalPredicate;
    
    scope = [NSString stringWithFormat:@"%d", (int)self.searchDisplayController.searchBar.selectedScopeButtonIndex+1];
    trimmedSearchString = [searchString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.searchResults = [self.logEntries mutableCopy];
    
    NSExpression *lhs = [NSExpression expressionForKeyPath:@"message"];
    NSExpression *rhs = [NSExpression expressionForConstantValue:trimmedSearchString];
    NSPredicate *messagePredicate = [NSComparisonPredicate predicateWithLeftExpression:lhs
                                                                       rightExpression:rhs
                                                                              modifier:NSDirectPredicateModifier
                                                                                  type:NSContainsPredicateOperatorType
                                                                               options:NSCaseInsensitivePredicateOption];
    
    if ([scope isEqualToString:@"2"] || [scope isEqualToString:@"3"]) {
        NSPredicate *scopePredicate = [NSPredicate predicateWithFormat:@"(SELF.type == %@)", scope];
        finalPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:@[messagePredicate, scopePredicate]];
    } else {
        finalPredicate = (NSCompoundPredicate *)[NSCompoundPredicate andPredicateWithSubpredicates:@[messagePredicate]];
    }
    
    self.searchResults = [[self.searchResults filteredArrayUsingPredicate:finalPredicate] mutableCopy];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self buildSearchResultsForSearchString:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self buildSearchResultsForSearchString:self.searchDisplayController.searchBar.text];
}

@end
