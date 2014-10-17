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

@interface PBSListViewController ()

@property (nonatomic, strong) NSMutableArray *savedBooks;

@end

@implementation PBSListViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
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
    [self fetchObjectContext];
}

#pragma mark - Core Data

- (void)fetchObjectContext
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PBSBook"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"Error Loading Objects: %@", [error localizedDescription]);
    }
    
    self.savedBooks = (NSMutableArray *)fetchedObjects;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.savedBooks count] > 0) {
        return [self.savedBooks count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.savedBooks count] > 0) {
        
        PBSBookCell *cell = (PBSBookCell *)[tableView dequeueReusableCellWithIdentifier:@"MyBookCell"];
        PBSBook *book = self.savedBooks[indexPath.row];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@", book.title];
        cell.authorLabel.text = [NSString stringWithFormat:@"%@", book.author];
        [cell.coverImageView setImageWithURL:[NSURL URLWithString:book.imageLink]];
        cell.coverImageView.layer.cornerRadius = 10.0f;
        cell.coverImageView.clipsToBounds = YES;
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                                                forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        
        return cell;
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PBSBook *book = self.savedBooks[indexPath.row];
    [self performSegueWithIdentifier:@"MyBookDetail" sender:book];
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

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
