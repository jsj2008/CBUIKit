//
//  CBUIFetchResultsDataSource.m
//  CBUIKit
//
//  Created by Christian Beer on 14.01.10.
//  Copyright 2010 Christian Beer. All rights reserved.
//

#import "CBUIFetchResultsDataSource.h"

@implementation CBUIFetchResultsDataSource

@synthesize fetchedResultsController = _fetchedResultsController;

- (id) initWithTableView:(UITableView*)tableView
            fetchRequest:(NSFetchRequest*)fetchRequest managedObjectContext:(NSManagedObjectContext*)context 
      sectionNameKeyPath:(NSString*)sectionNameKeyPath
               cacheName:(NSString*)cacheName {
	self = [super initWithTableView:tableView];
    if (!self) return nil;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:context
                                 sectionNameKeyPath:sectionNameKeyPath
                                 cacheName:cacheName];
    _fetchedResultsController.delegate = self;
    
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"!! fetchedResultsControlloer performFetch failed: %@", error);
        return nil;
    }

	return self;
}
- (id) initWithTableView:(UITableView*)tableView
            fetchRequest:(NSFetchRequest*)fetchRequest managedObjectContext:(NSManagedObjectContext*)context 
               cacheName:(NSString*)cacheName {
    return [self initWithTableView:tableView
                      fetchRequest:fetchRequest 
              managedObjectContext:context 
                sectionNameKeyPath:nil 
                         cacheName:cacheName];
}

+ (CBUIFetchResultsDataSource*) dataSourceWithTableView:(UITableView*)tableView
                                           fetchRequest:(NSFetchRequest*)fetchRequest managedObjectContext:(NSManagedObjectContext*)context
                                        sectionNameKeyPath:(NSString*)sectionNameKeyPath cacheName:(NSString*)cacheName {
	CBUIFetchResultsDataSource *ds = [[[self class] alloc] initWithTableView:tableView
                                                                fetchRequest:fetchRequest
                                                           managedObjectContext:context
                                                             sectionNameKeyPath:sectionNameKeyPath
                                                                      cacheName:cacheName];
	
	return [ds autorelease];
    
}

+ (CBUIFetchResultsDataSource*) dataSourceWithTableView:(UITableView*)tableView fetchRequest:(NSFetchRequest*)fetchRequest 
                                   managedObjectContext:(NSManagedObjectContext*)context cacheName:(NSString*)cacheName {
    return [self dataSourceWithTableView:tableView fetchRequest:fetchRequest managedObjectContext:context 
                         sectionNameKeyPath:nil cacheName:cacheName];
}

- (void) dealloc {
    [_fetchedResultsController dealloc], _fetchedResultsController = nil;
    
    [super dealloc];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	int count = [[_fetchedResultsController sections] count];
	return count;//count > 0 ? count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *sections = [_fetchedResultsController sections];
	if (sections.count > 0) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
		return [sectionInfo numberOfObjects];
	} else {
		return 0;
	}
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo name];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectAtIndexPath:indexPath];
    
    if ([object isKindOfClass:[NSManagedObject class]]) {
        NSManagedObject *managedObject = (NSManagedObject*)object;
        
        [managedObject.managedObjectContext deleteObject:managedObject];
        
        NSError *error = nil;
        if (![managedObject.managedObjectContext save:&error]) {
            NSLog(@"Was unable to delete object: %@", error);
        }
    }
}

#pragma mark NSFetchedResultsControllerDelegate

#if 0 // hack because of crappy NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView reloadData];
}

#else

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                        withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                      withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [_tableView endUpdates];
}
#endif

#pragma mark CBUITableViewDataSource

- (id) objectAtIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *managedObject = [_fetchedResultsController objectAtIndexPath:indexPath];
	return managedObject;
}

@end



@implementation CBUIFetchResultsByKeyPathDataSource 

@synthesize objectKeyPath;

- (void) dealloc {
    [objectKeyPath release], objectKeyPath = nil;
    [super dealloc];
}

#pragma mark CBUITableViewDataSource

- (id) objectAtIndexPath:(NSIndexPath*)indexPath {
    NSManagedObject *managedObject = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    if (!objectKeyPath) return managedObject;
    
	return [managedObject valueForKeyPath:objectKeyPath];
}

@end