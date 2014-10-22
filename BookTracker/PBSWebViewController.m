//
//  PBSWebViewController.m
//  BookTracker
//
//  Created by Philippe Schmid on 22.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSWebViewController.h"

@interface PBSWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *previewWebView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *forwardButton;

@end

@implementation PBSWebViewController

#pragma mark - Initializers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    titleLabel.text = @"Preview";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    [self configureWebView];
    [self customizeNavigationBar];
}

- (void)configureWebView
{
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.previewWebView.scalesPageToFit = YES;
    [self.previewWebView loadRequest:request];
}

#pragma mark - Customization

- (void)customizeNavigationBar
{
    self.backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(goBack)];
    self.forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"Forward"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(goForward)];
    
    self.navigationItem.rightBarButtonItems = @[self.forwardButton, self.backButton];
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}

#pragma mark - UIWebViewDelegate

- (void)goBack
{
    if (self.previewWebView.canGoBack) {
        [self.previewWebView goBack];
    }
}

- (void)goForward
{
    if (self.previewWebView.canGoForward) {
        [self.previewWebView goForward];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (self.previewWebView.canGoBack) {
        self.backButton.enabled = YES;
    } else {
        self.backButton.enabled = NO;
    }
    
    if (self.previewWebView.canGoForward) {
        self.forwardButton.enabled = YES;
    } else {
        self.forwardButton.enabled = NO;
    }
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
