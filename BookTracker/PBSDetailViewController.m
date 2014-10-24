//
//  PBSDetailViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSConstants.h"
#import "PBSDetailViewController.h"
#import "PBSSearchViewController.h"
#import "PBSListViewController.h"
#import "PBSWebViewController.h"
#import "PBSTextViewController.h"
#import "MBProgressHUD.h"
#import "PBSBookResult.h"
#import "PBSBook.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <QuartzCore/QuartzCore.h>

@interface PBSDetailViewController () <UINavigationControllerDelegate, UITextViewDelegate,
                                       UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UILabel *pagesLabel;
@property (nonatomic, weak) IBOutlet UILabel *publisherLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *languageLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *previewLabel;
@property (nonatomic, assign, getter=isSegueTriggered) BOOL segueTriggered;

@end

@implementation PBSDetailViewController

#pragma mark - Initializers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.navigationController.delegate = self;
        self.descriptionTextView.delegate = self;
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customizeNavigationBar];
    [self configureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.segueTriggered = NO;
}

- (void)customizeNavigationBar
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = NSLocalizedString(@"BookDetail", @"Navigation: Title");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Configure view with book details

- (void)configureView
{
    self.coverImageView.layer.cornerRadius = 10.0f;
    self.coverImageView.clipsToBounds = YES;
    [self customizeAppearance];
    
    if (!self.savedBook) {
        // configure view with fetched object
        [self configureViewForLoadedBook];
    } else {
        // configure view with core data object
        [self configureViewForSavedBook];
    }
}

- (void)customizeAppearance
{
    self.descriptionTextView.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                          blue:19/255.0f alpha:0.8f];
    self.publisherLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                     blue:19/255.0f alpha:0.8f];
    self.titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.authorLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.pagesLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.dateLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.ratingLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.previewLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                   blue:19/255.0f alpha:0.8f];
    self.languageLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                    blue:19/255.0f alpha:0.8f];
}

- (void)configureViewForLoadedBook
{
    // only the fetched book result can be saved
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:
                                              NSLocalizedString(@"Save", @"Navigation: Button Title")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(showMenu)];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.bookResult.imageLink]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.title];
    self.authorLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.author];
    self.publisherLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.publisher];
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.bookResult.bookDescription];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.year];
    self.languageLabel.text = [NSString stringWithFormat:@"%@", self.bookResult.language];
    
    self.pagesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ pages", @"Detail: Pages"),
                            self.bookResult.pages];
    self.previewLabel.text = [NSString stringWithFormat:NSLocalizedString(@"More on %@", @"Detail: More"),
                              self.bookResult.title];
    self.ratingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rating: %@/5 (%@ ratings)",
                                                                         @"Detail: Ratings"),
                             self.bookResult.rating, self.bookResult.numberOfRatings];
}

- (void)configureViewForSavedBook
{
    [self.coverImageView setImageWithURL:[NSURL URLWithString:self.book.imageLink]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.book.title];
    self.authorLabel.text = [NSString stringWithFormat:@"%@", self.book.author];
    self.publisherLabel.text = [NSString stringWithFormat:@"%@", self.book.publisher];
    self.descriptionTextView.text = [NSString stringWithFormat:@"%@", self.book.bookDescription];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.book.year];
    self.languageLabel.text = [NSString stringWithFormat:@"%@", self.book.language];
    
    self.pagesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@ pages", @"Detail: Pages"),
                            self.book.pages];
    self.previewLabel.text = [NSString stringWithFormat:NSLocalizedString(@"More on %@", @"Detail: More"),
                              self.book.title];
    self.ratingLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Rating: %@/5 (%@ ratings)",
                                                                         @"Detail: Ratings"),
                             self.book.rating, self.book.ratingNumber];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        NSString *previewLink;
        if (!self.savedBook) {
            // use loaded link from search result
            previewLink = self.bookResult.previewLink;
        } else {
            // use saved link from core data
            previewLink = self.book.previewLink;
        }
        [self performSegueWithIdentifier:@"Preview" sender:previewLink];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (!self.segueTriggered) {
        // avoid multiple segues with multiple touches
        self.segueTriggered = YES;
        [self performSegueWithIdentifier:@"TextView" sender:self.descriptionTextView.text];
    }
    return NO;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // save button
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = NSLocalizedString(@"Saving...", @"Actionsheet: Saving");
        [hud show:YES];
        [self save];
        [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1];
        [hud hide:YES afterDelay:1];
    } else {
        // cancel button
        [actionSheet dismissWithClickedButtonIndex:1 animated:YES];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    for (UIView *subview in actionSheet.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *menuButton = (UIButton *)subview;
            [menuButton setTitleColor:[UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f
                                                      alpha:1.0f] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Navigation

- (void)dismissViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // book preview segue
    if ([segue.identifier isEqualToString:@"Preview"]) {
        PBSWebViewController *webVC = (PBSWebViewController *)segue.destinationViewController;
        webVC.urlString = (NSString *)sender;
    }
    
    // description segue
    if ([segue.identifier isEqualToString:@"TextView"]) {
        PBSTextViewController *textVC = (PBSTextViewController *)segue.destinationViewController;
        textVC.textToShow = (NSString *)sender;
    }
}

- (void)showMenu
{
    if ([self checkForDuplicates]) {
        // book already saved, show alert view
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Duplicate",
                                                                                      @"Duplicate: Title")
                                                            message:NSLocalizedString(@"You already saved this book.", @"Duplicate: Text")
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        // new book, show action sheet for saving
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil
                                                          delegate:self
                                                 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel Button: Title")
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:NSLocalizedString(@"Save", @"Save Button: Title"), nil];
        [menu showInView:self.view];
    }
}

- (BOOL)checkForDuplicates
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PBSBook"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // fetch core data objects manually
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!fetchedObjects) {
        // show core data error
        [[NSNotificationCenter defaultCenter] postNotificationName:ManagedObjectContextSaveDidFailNotification object:nil];
    }
    
    // compare current book result to all saved books
    for (PBSBook *book in fetchedObjects) {
        if ([book.title isEqualToString:self.bookResult.title] &&
            [book.author isEqualToString:self.bookResult.author] &&
            [book.year isEqualToString:self.bookResult.year]) {
            return YES; // duplicate
        }
    }
    return NO; // no duplicate
}

#pragma mark - Core Data

- (void)save
{
    PBSBook *book = [NSEntityDescription insertNewObjectForEntityForName:@"PBSBook"
                                                  inManagedObjectContext:self.managedObjectContext];
    book.title = self.bookResult.title;
    book.subtitle = self.bookResult.subtitle;
    book.author = self.bookResult.author;
    book.publisher = self.bookResult.publisher;
    book.bookDescription = self.bookResult.bookDescription;
    book.year = self.bookResult.year;
    book.imageLink = self.bookResult.imageLink;
    book.previewLink = self.bookResult.previewLink;
    book.language = self.bookResult.language;
    book.pages = self.bookResult.pages;
    book.rating = self.bookResult.rating;
    book.ratingNumber = self.bookResult.numberOfRatings;
    book.isbn10 = self.bookResult.ISBN10;
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ManagedObjectContextSaveDidFailNotification object:nil];
        return;
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
