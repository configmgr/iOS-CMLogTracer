//
//  CMLogsViewController.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/15/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <DBChooser/DBChooser.h>
#import "CMAppDelegate.h"
#import "CMLogsViewController.h"
#import "CMLogFile.h"
#import "CMLogEntriesViewController.h"
#import "CMUtils.h"
#import "CMLogImporter.h"

@interface CMLogsViewController ()

@property (nonatomic) UIAlertView *logFileNamePrompt;
@property (nonatomic) UIView *progressIndicator;
@property (nonatomic) NSArray *logFiles;

@end

@implementation CMLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataStore = [(CMAppDelegate *)[[UIApplication sharedApplication] delegate] dataStore];
    self.logFiles = self.dataStore.logFiles;
    
    if (!self.importQueue) {
        self.importQueue = [[NSMutableArray alloc] init];
    }

    [self registerForOrientationChangeNotifications];
    [self initializeToolbarButtons];
    [self loadFirstRunHelpScreenIfThisIsTheAppsFirstRun];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForOrientationChangeNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}

- (void)orientationChanged {
    if (self.progressIndicator) {
        [self dismissImportProgressIndicator];
        [self displayImportProgressIndicator];
    }
}

- (void)dismissAnyVisibleImportDialogs {
    if ([self.logFileNamePrompt isVisible]) {
        [self.logFileNamePrompt dismissWithClickedButtonIndex:0 animated:NO];
        [self.importQueue removeAllObjects];
    }
}

- (void)loadFirstRunHelpScreenIfThisIsTheAppsFirstRun {
    if (![self isNotFirstRun]) {
        [self performSegueWithIdentifier:@"LoadFirstRunHelpScreen" sender:self];
        [self setNotFirstRunPreference];
    } else {
        NSLog(@"This is not the app's first run.  Skipping first run help screen.");
    }
}

- (BOOL)isNotFirstRun {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"SCNotFirstRun"];
}

- (void)setNotFirstRunPreference {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SCNotFirstRun"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)initializeToolbarButtons {
    UIBarButtonItem *addLogButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLogFileButtonTapped:)];
    
    self.navigationItem.rightBarButtonItem = addLogButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)addLogFileButtonTapped:(id)sender {
    if (self.isEditing) {
        [self setEditing:NO];
    }
    
    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect
                                    fromViewController:self completion:^(NSArray *results) {
         if ([results count]) {
             NSString *logFileContents;
             NSString *logFileName;
             
             logFileContents = [[NSString alloc] initWithContentsOfURL:[[results objectAtIndex:0] link] encoding:NSUTF8StringEncoding error:nil];
             logFileName = [[results objectAtIndex:0] name];

             [self addLogFileToImportQueueWithName:logFileName andContents:logFileContents];
         }
     }];
}

- (void)addLogFileToImportQueueWithName:(NSString *)name andContents:(NSString *)contents {
    NSDictionary *logFile = @{ @"name": name, @"contents": contents };
    [self.importQueue addObject:logFile];
}

- (void)processImportQueue {
    if (self.importQueue.count > 0) {
        NSOperationQueue *queue = [NSOperationQueue new];
        NSDictionary *logFile = self.importQueue[0];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                selector:@selector(importLogFileWithName:)
                                                                                  object:logFile];
        [self.importQueue removeAllObjects];
        [queue addOperation:operation];
        [self displayImportProgressIndicator];
    }
}

- (void)successfulImport {
    [self.dataStore reload];
    [self.tableView reloadData];
    NSIndexPath *indexPathForLastRow = [NSIndexPath indexPathForItem:self.dataStore.logFiles.count-1 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPathForLastRow animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self dismissImportProgressIndicator];
}

- (void)failedImport {
    [self dismissImportProgressIndicator];
    [self displayAlertForFailedImport];
}

- (void)importLogFileWithName:(NSDictionary *)fileNameAndContents {
    CMLogImporter *logImporter;
    CMLogFile *logFile;
    NSString *name = fileNameAndContents[@"name"];
    NSString *contents = fileNameAndContents[@"contents"];

    logImporter = [[CMLogImporter alloc] initWithDataStore:self.dataStore];
    logFile = [logImporter importLogFileWithName:name andContents:contents];

    if (logFile) {
        NSLog(@"Successfully imported log file: %@", name);
        [self.dataStore saveChanges];
        [self performSelectorOnMainThread:@selector(successfulImport) withObject:nil waitUntilDone:NO];
    } else {
        NSLog(@"Failed to import log file: %@", name);
        [self performSelectorOnMainThread:@selector(failedImport) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Import progress indicator

- (void)displayImportProgressIndicator {
    self.progressIndicator = [[[NSBundle mainBundle] loadNibNamed:@"ImportProgressIndicator" owner:self options:nil] objectAtIndex:0];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.progressIndicator viewWithTag:0];
    
    [self.progressIndicator.layer setCornerRadius:10.0f];
    
    CGFloat screenWidth, screenHeight;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        screenWidth = [UIScreen mainScreen].bounds.size.height;
        screenHeight = [UIScreen mainScreen].bounds.size.width;
    } else {
        screenWidth = [UIScreen mainScreen].bounds.size.width;
        screenHeight = [UIScreen mainScreen].bounds.size.height;
    }

    self.progressIndicator.center = CGPointMake(screenWidth/2, screenHeight/2 - 30);
    
    [self.view addSubview:self.progressIndicator];
    [spinner startAnimating];
    self.tableView.userInteractionEnabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)dismissImportProgressIndicator {
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[self.progressIndicator viewWithTag:0];
    
    [spinner stopAnimating];
    [self.progressIndicator removeFromSuperview];
    self.progressIndicator = nil;
    self.tableView.userInteractionEnabled = YES;
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - Custom alerts

- (void)displayAlertForFailedImport {
    UIAlertView *failedImportAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Import Error", nil)
                                                                message:NSLocalizedString(@"There was a problem with the file you were trying to import.  Aborting operation.", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                                      otherButtonTitles:nil, nil];
    [failedImportAlert show];
}

- (void)displayPromptForLogFileName {
    if (self.importQueue.count > 0) {
        [self setNotFirstRunPreference];

        NSDictionary *logFile = [self.importQueue objectAtIndex:0];
        NSString *logFileName = logFile[@"name"];
        self.logFileNamePrompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"File Name", nil)
                                                                   message:@""
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                         otherButtonTitles:NSLocalizedString(@"Ok", nil), nil];
        [self.logFileNamePrompt setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [self.logFileNamePrompt setDelegate:self];
        [self.logFileNamePrompt show];

        UITextField *textField = [self.logFileNamePrompt textFieldAtIndex:0];
        [textField setText:logFileName];
        UITextPosition *from = [textField positionFromPosition:[textField beginningOfDocument] offset:0];
        UITextPosition *to = [textField positionFromPosition:from offset:logFileName.length];
        [textField setSelectedTextRange:[textField textRangeFromPosition:from toPosition:to]];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *logFileName = [[alertView textFieldAtIndex:0] text];

    if (buttonIndex == 1 && logFileName.length > 0) {
        NSDictionary *originalLogFile = [self.importQueue objectAtIndex:0];
        NSDictionary *newLogFile = @{@"name": logFileName, @"contents": originalLogFile[@"contents"] };

        [self.importQueue removeAllObjects];
        [self.importQueue addObject:newLogFile];
        [self processImportQueue];
    } else {
        [self.importQueue removeAllObjects];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataStore.logFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *logFileName = [self.dataStore.logFiles[indexPath.row] name];
    NSDate *logFileDateAdded = [NSDate dateWithTimeIntervalSince1970:[self.dataStore.logFiles[indexPath.row] dateAdded]];
    
    cell.textLabel.text = logFileName;
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Added on: %@", nil), [CMUtils localizedDateAndTimeStringFromDate:logFileDateAdded]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.dataStore removeLogFile:self.dataStore.logFiles[indexPath.row]];
        [self.dataStore saveChanges];
        [self.dataStore reload];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoadLogEntries"]) {
        NSIndexPath *indexPathOfSelectedRow = [self.tableView indexPathForSelectedRow];
        CMLogFile *logFile = self.dataStore.logFiles[indexPathOfSelectedRow.row];
        [[segue destinationViewController] setLogFile:logFile];
    }
}

@end
