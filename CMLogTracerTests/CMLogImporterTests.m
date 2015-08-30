//
//  CMLogImporterTests.m
//  CMLogTracer
//
//  Created by Andre Bocchini on 10/20/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CMDataStore.h"
#import "CMLogImporter.h"

@interface CMLogImporterTests : XCTestCase

@property (nonatomic) NSMutableArray *logFiles;

@end

@implementation CMLogImporterTests

- (void)setUp
{
    [super setUp];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [testBundle bundlePath];
    NSArray *allFiles = [fileManager contentsOfDirectoryAtPath:bundlePath error:nil];
    NSArray *logFileNames = [allFiles filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.log'"]];
    
    self.logFiles = [[NSMutableArray alloc] init];
    for (NSString *fileName in logFileNames) {
        [self.logFiles addObject:[bundlePath stringByAppendingPathComponent:fileName]];
    }
}

- (void)tearDown
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *userPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = (userPaths.count > 0) ? [userPaths objectAtIndex:0] : nil;
    NSArray *contentsOfDocumentsDirectory = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    for (NSString *document in contentsOfDocumentsDirectory) {
        NSString *currentDocument = [documentsDirectory stringByAppendingPathComponent:document];
        [fileManager removeItemAtPath:currentDocument error:nil];
    }

    [super tearDown];
}

- (void)testLogsWithMajorErrorsDoNotGetImported
{
    CMDataStore *dataStore = [[CMDataStore alloc] init];
    CMLogImporter *logImporter = [[CMLogImporter alloc] initWithDataStore:dataStore];
    NSMutableArray *failedImports = [[NSMutableArray alloc] init];

    for (NSString *logFilePath in self.logFiles) {
        NSLog (@"Importing: %@", [logFilePath lastPathComponent]);
        
        NSString *logFileContents = [NSString stringWithContentsOfFile:logFilePath encoding:NSUTF8StringEncoding error:nil];
        CMLogFile *importedLogFile = [logImporter importLogFileWithName:[logFilePath lastPathComponent] andContents:logFileContents];
        if (importedLogFile == nil) {
            [failedImports addObject:[logFilePath lastPathComponent]];
        }
    }
    
    XCTAssertEqual((int)failedImports.count, 4, @"There should be 4 failed imports");
}

@end
