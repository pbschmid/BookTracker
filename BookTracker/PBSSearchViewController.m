//
//  PBSSearchViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSConstants.h"
#import "PBSSearchViewController.h"
#import "PBSDetailViewController.h"
#import "PBSBookStore.h"
#import "PBSBookResult.h"
#import "PBSBookCell.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

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

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavigationBar];
    self.tableView.rowHeight = 88.0f;
    self.tableView.separatorColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.5f];
    // load cell nib
    UINib *cellNib = [UINib nibWithNibName:NothingFoundCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:NothingFoundCellIdentifier];
}

- (void)customizeNavigationBar
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = NSLocalizedString(@"BookTracker", @"Navigation: Title");
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
     if ([self.bookStore.bookResults count] == 0) {
         // no results, show empty cell
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NothingFoundCellIdentifier
                                                                 forIndexPath:indexPath];
         cell.selectionStyle = UITableViewCellSelectionStyleNone;
         cell.userInteractionEnabled = NO;
         return cell;
     } else {
         // successfully fetched results, show cell with book details
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookCell"];
         [self configureCell:cell atIndexPath:indexPath];
         return cell;
     }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PBSBookResult *bookResult = self.bookStore.bookResults[indexPath.row];
    PBSBookCell *bookCell = (PBSBookCell *)cell;
    bookCell.titleLabel.text = [NSString stringWithFormat:@"%@", bookResult.title];
    bookCell.authorLabel.text = [NSString stringWithFormat:@"%@", bookResult.author];
    [bookCell.coverImageView setImageWithURL:[NSURL URLWithString:bookResult.imageLink]];
    bookCell.coverImageView.layer.cornerRadius = 10.0f;
    bookCell.coverImageView.clipsToBounds = YES;
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
    PBSBookResult *bookResult = self.bookStore.bookResults[indexPath.row];
    [self performSegueWithIdentifier:@"BookDetail" sender:bookResult];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"BookDetail"]) {
        PBSDetailViewController *detailVC = (PBSDetailViewController *)segue.destinationViewController;
        detailVC.bookResult = (PBSBookResult *)sender;
        detailVC.savedBook = NO;
        detailVC.managedObjectContext = self.managedObjectContext;
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    self.searchBar.text = @"";
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

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
    if ([self.searchBar.text length] > 0) {
        
        // show loading hud
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = NSLocalizedString(@"Loading...", @"HUD: Loading");
        [hud show:YES];
        
        // ask shared store to search for book
        self.bookStore = [PBSBookStore sharedPBSBookStore];
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
}

- (void)booksRetrieved
{
    [self.tableView reloadData];
}

- (void)showNetworkError:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                        message:NSLocalizedString(@"There was a network error. Please try again.", @"Error: Network")
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    [self.tableView reloadData];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
