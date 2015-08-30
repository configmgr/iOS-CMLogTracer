//
//  CMDataStore.m
//  SCLogViewer
//
//  Created by Andre Bocchini on 10/15/13.
//  Copyright (c) 2013 Andre Bocchini. All rights reserved.
//

#import "CMDataStore.h"

@implementation CMDataStore

@synthesize logFiles;

- (id)init {
    self = [super init];
    if (self) {
        self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        NSString *dataStorePath = [self dataStorePath];
        NSURL *dataStoreURL = [NSURL fileURLWithPath:dataStorePath];
        NSError *error = nil;

        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dataStoreURL options:nil error:&error]) {
            [NSException raise:@"Failed to initialize data store" format:@"Reason: %@", error.localizedDescription];
        }
     
        self.context = [[NSManagedObjectContext alloc] init];
        self.context.persistentStoreCoordinator = psc;
        self.context.undoManager = nil;
        
        [self loadAllLogFiles];
    }
    return self;
}

- (NSString *)dataStorePath {
    NSArray *paths;
    NSString *documentsDirectory;
    NSString *dataStorePath;
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    dataStorePath = [documentsDirectory stringByAppendingPathComponent:@"data.store"];
    
    return dataStorePath;
}
             
- (BOOL)saveChanges {
    NSError *error;
    BOOL success;
    
    error = nil;
    success = [self.context save:&error];
    
    if (!success) {
        NSLog(@"Error saving to data store: %@", [error localizedDescription]);
    }
    
    return success;
}

- (void)loadAllLogFiles {
    if (!self.logFiles) {
        NSFetchRequest *fetchRequest;
        NSEntityDescription *entityDescription;
        NSSortDescriptor *sortDescriptor;
        NSError *error;
        NSArray *result;
        
        fetchRequest = [[NSFetchRequest alloc] init];
        entityDescription = [[self.model entitiesByName] objectForKey:@"CMLogFile"];
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES];
        
        [fetchRequest setEntity:entityDescription];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        
        result = [self.context executeFetchRequest:fetchRequest error:&error];
        if (!result) {
            [NSException raise:@"Failed to fetch from data store" format:@"Reason: %@", error.localizedDescription];
        }
        
        self.logFiles = [[NSMutableArray alloc] initWithArray:result];
    }
}

- (CMLogFile *)createLogFile {
    CMLogFile *logFile;
    NSSortDescriptor *logFilesSortDescriptor;
    NSArray *allSortDescriptors;
    
    logFile = [NSEntityDescription insertNewObjectForEntityForName:@"CMLogFile" inManagedObjectContext:self.context];
    [self.logFiles addObject:logFile];
    
    logFilesSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
    allSortDescriptors = @[logFilesSortDescriptor];
    self.logFiles = [[self.logFiles sortedArrayUsingDescriptors:allSortDescriptors] mutableCopy];
    
    return logFile;
}

- (void)removeLogFile:(CMLogFile *)logFile {
    [self.logFiles removeObjectIdenticalTo:logFile];
    [self.context deleteObject:logFile];
}

- (CMLogEntry *)createLogEntry {
    CMLogEntry *logEntry;
    
    logEntry = [NSEntityDescription insertNewObjectForEntityForName:@"CMLogEntry" inManagedObjectContext:self.context];
    
    return logEntry;
}

- (void)reload {
    NSSortDescriptor *logFilesSortDescriptor;
    NSArray *allSortDescriptors;
    
    logFilesSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateAdded" ascending:YES];
    allSortDescriptors = @[logFilesSortDescriptor];
    self.logFiles = [[self.logFiles sortedArrayUsingDescriptors:allSortDescriptors] mutableCopy];
}

@end
