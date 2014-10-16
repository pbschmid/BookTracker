//
//  PBSSearchViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSSearchViewController.h"
#import "PBSBookStore.h"
#import "PBSBook.h"
#import "PBSBookCell.h"
#import "MBProgressHUD.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static NSString * const NothingFoundCellIdentifier = @"PBSNothingFoundCell";

@interface PBSSearchViewController () <UINavigationControllerDelegate, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) PBSBookStore *bookStore;

@end

@implementation PBSSearchViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Deallocating SearchViewController...");
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.rowHeight = 88.0f;
    self.tableView.separatorColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.5f];
    
    UINib *cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = @"BookTracker";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.bookStore.bookResults count] > 0) {
        return [self.bookStore.bookResults count];
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if ([self.bookStore.bookResults count] > 0) {
         
         PBSBookCell *cell = (PBSBookCell *)[tableView dequeueReusableCellWithIdentifier:@"BookCell"];
         PBSBook *bookResult = self.bookStore.bookResults[indexPath.row];
     
         cell.titleLabel.text = [NSString stringWithFormat:@"%@", bookResult.title];
         cell.authorLabel.text = [NSString stringWithFormat:@"%@", bookResult.authors];
         [cell.coverImageView setImageWithURL:[NSURL URLWithString:bookResult.imageLink]];
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
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self searchForBook];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (self.bookStore) {
        [self searchForBook];
    }
}

- (void)searchForBook
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Loading...";
    [hud show:YES];
    
    self.bookStore = [[PBSBookStore alloc] init];
    [self.bookStore fetchResultsForText:self.searchBar.text
                               category:self.searchBar.selectedScopeButtonIndex
                             completion:^(BOOL finished, NSError *error) {
                                 if (finished) {
                                     [hud hide:YES];
                                     [self booksRetrieved];
                                 } else {
                                     [hud hide:YES];
                                     [self showNetworkError:error];
                                 }
                             }];
}

- (void)booksRetrieved
{
    NSLog(@"All Books Retrieved.");
    [self.tableView reloadData];
}

- (void)showNetworkError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
