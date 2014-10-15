//
//  PBSBookStore.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSBookStore.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const APIKEY = @"AIzaSyBa8IvCnzpRl2wiKSyzJnaXxWUWQNPn38A";

@implementation PBSBookStore

- (NSString *)createURLFromText:(NSString *)text category:(NSInteger)category
{
    NSString *categoryName;
    switch (category) {
        case 0:
            categoryName = @"";
            break;
        case 1:
            categoryName = @"";
            break;
        case 2:
            categoryName = @"";
            break;
        case 3:
            categoryName = @"";
            break;
    }
    
    //NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    //NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://www.googleapis.com/books/v1/volumes?q=%@&country=CH&key=AIzaSyBa8IvCnzpRl2wiKSyzJnaXxWUWQNPn38A",
                           text];
    return urlString;
}

- (void)fetchResultsForText:(NSString *)text category:(NSInteger)category
{
    NSString *urlString = [self createURLFromText:text category:category];
    
    NSLog(@"%@", urlString);
    
    //NSURL *url = [NSURL URLWithString:urlString];
    //NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success!");
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ %@", error, [error userInfo]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    /*
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success!");
        NSLog(@"%@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@ %@", error, [error userInfo]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }];
    
    [[NSOperationQueue mainQueue] addOperation:operation];*/
}

@end
