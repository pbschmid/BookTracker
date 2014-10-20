//
//  PBSListViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "PBSListViewController.h"
#import "PBSDetailViewController.h"
#import "PBSBookCell.h"
#import "PBSBook.h"

static NSString * const NothingFoundCellIdentifier = @"PBSNothingFoundCell";

@interface PBSListViewController () <UINavigationControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) NSInteger objectsInDataStore;

@end

@implementation PBSListViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationController.delegate = self;
        self.objectsInDataStore = 0;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Deallocating ListViewController...");
    self.fetchedResultsController.delegate = nil;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 88.0f;
    self.tableView.separatorColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.5f];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = @"MyBooks";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    UINib *cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [NSFetchedResultsController deleteCacheWithName:@"BookCache"];
    [self performFetch];
    
    if (self.objectsInDataStore > 0) {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

#pragma mark - Core Data

- (void)performFetch
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error Loading Objects: %@", [error localizedDescription]);
        [[NSNotificationCenter defaultCenter] postNotificationName:
                                              ManagedObjectContextSaveDidFailNotification object:nil];
        return;
    }
    
    self.objectsInDataStore = self.fetchedResultsController.fetchedObjects.count;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"PBSBook"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        [fetchRequest setFetchBatchSize:20];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                            managedObjectContext:self.managedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:@"BookCache"];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections]
                                                    objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.objectsInDataStore > 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyBookCell"];
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                                                forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PBSBookCell *bookCell = (PBSBookCell *)cell;
    PBSBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    bookCell.titleLabel.text = [NSString stringWithFormat:@"%@", book.title];
    bookCell.authorLabel.text = [NSString stringWithFormat:@"%@", book.author];
    
    [bookCell.coverImageView setImageWithURL:[NSURL URLWithString:book.imageLink]];
    bookCell.coverImageView.layer.cornerRadius = 10.0f;
    bookCell.coverImageView.clipsToBounds = YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PBSBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"MyBookDetail" sender:book];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.objectsInDataStore > 0) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PBSBook *book = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:book];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error Updating Objects: %@", [error localizedDescription]);
            [[NSNotificationCenter defaultCenter] postNotificationName:
                                                  ManagedObjectContextSaveDidFailNotification object:nil];
            return;
        }
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    PBSDetailViewController *detailVC = (PBSDetailViewController *)segue.destinationViewController;
    detailVC.book = (PBSBook *)sender;
    detailVC.savedBook = YES;
    detailVC.managedObjectContext = self.managedObjectContext;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
            
        // insert
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        // delete
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        // move
        case NSFetchedResultsChangeMove:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        // update
        case NSFetchedResultsChangeUpdate:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath]
                                  withRowAnimation:UITableViewRowAnimationFade];
            break;
            
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
            
            // insert
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            // delete
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
