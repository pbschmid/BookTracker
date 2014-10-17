//
//  PBSBookStore.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSBookStore.h"
#import "PBSBook.h"
#import <AFNetworking/AFNetworking.h>

static NSString * const GoogleAPIKey = @"AIzaSyBa8IvCnzpRl2wiKSyzJnaXxWUWQNPn38A";

@interface PBSBookStore ()

@property (nonatomic, readwrite, strong) NSMutableArray *bookResults;

@end

@implementation PBSBookStore

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSLog(@"Initializing BookStore...");
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"Deallocating BookStore...");
}

#pragma mark - AFNetworking

- (NSString *)createURLFromText:(NSString *)text category:(NSInteger)category
{
    NSString *searchText;
    switch (category) {
        case 0:
            searchText = text;
            break;
        case 1:
            searchText = [NSString stringWithFormat:@"intitle:%@", text];
            break;
        case 2:
            searchText = [NSString stringWithFormat:@"inauthor:%@", text];
            break;
        case 3:
            searchText = [NSString stringWithFormat:@"isbn:%@", text];
            break;
    }
    
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *language = [locale localeIdentifier];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSString *escapedText = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:
                @"https://www.googleapis.com/books/v1/volumes?q=%@&maxResults=40&lang=%@&country=%@",
                escapedText, language, countryCode];
    
    return urlString;
}

- (void)fetchResultsForText:(NSString *)text category:(NSInteger)category completion:(CompletionBlock)block
{
    if ([text length] > 0) {
        
        NSString *urlString = [self createURLFromText:text category:category];
        NSDictionary *params = @{@"format" : @"json"};
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager.requestSerializer setValue:@"userId" forHTTPHeaderField:GoogleAPIKey];
        
        [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation,
                                                               id responseObject) {
            
            NSLog(@"Success!");
            //NSLog(@"%@", responseObject[@"items"]);
            [self parseResponseObject:responseObject];
            block(YES, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"%@", [error userInfo]);
            block(NO, error);
            
        }];
    }
}

#pragma mark - JSON parsing

- (void)parseResponseObject:(NSDictionary *)responseObject
{
    NSArray *results = responseObject[@"items"];
    
    if (!results) {
        NSLog(@"Results empty.");
        return;
    }
    
    self.bookResults = [[NSMutableArray alloc] init];
    
    for (NSDictionary *bookResult in results) {
        
        NSDictionary *bookDetails = bookResult[@"volumeInfo"];
        
        PBSBook *book = [[PBSBook alloc] init];
        book.title = bookDetails[@"title"];
        book.authors = bookDetails[@"authors"][0];
        
        book.subtitle = bookDetails[@"subtitle"];
        book.publisher = bookDetails[@"publisher"];
        book.publishedDate = bookDetails[@"publishedDate"];
        book.description = bookDetails[@"description"];
        book.language = bookDetails[@"language"];
        book.pages = bookDetails[@"pageCount"];
        
        book.categories = bookDetails[@"categories"][0];
        book.type = bookDetails[@"printType"];
        //book.ISBN = bookDetails[@"industryIdentifiers"][@"identifier"];
        book.imageLink = bookDetails[@"imageLinks"][@"thumbnail"];
        //book.previewLink = bookDetails[@"previewLink"];
        
        book.rating = bookDetails[@"averageRating"];
        book.numberOfRatings = bookDetails[@"ratingsCount"];
        
        [self.bookResults addObject:book];
    }
}

@end
