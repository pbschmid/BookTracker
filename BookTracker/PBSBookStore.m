//
//  PBSBookStore.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSBookStore.h"
#import "PBSBookResult.h"

static NSString * const GoogleAPIKey = @"YOUR_API_KEY_HERE";

@interface PBSBookStore ()

@property (nonatomic, readwrite, strong) NSMutableArray *bookResults;

@end

@implementation PBSBookStore

#pragma mark - Initializers

+ (PBSBookStore *)sharedPBSBookStore
{
    static PBSBookStore *_sharedPBSBookStore = nil;
    static dispatch_once_t oncePredicate = 0;
    dispatch_once(&oncePredicate, ^{
        _sharedPBSBookStore = [[PBSBookStore alloc] init];
    });
    return _sharedPBSBookStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - AFNetworking

- (NSString *)createURLFromText:(NSString *)text category:(NSInteger)category
{
    NSString *searchText;
    switch (category) {
        case 0:
            // normal search
            searchText = text;
            break;
        case 1:
            // title search
            searchText = [NSString stringWithFormat:@"intitle:%@", text];
            break;
        case 2:
            // author search
            searchText = [NSString stringWithFormat:@"inauthor:%@", text];
            break;
        case 3:
            // isbn search
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
    NSString *urlString = [self createURLFromText:text category:category];
    NSDictionary *params = @{@"format" : @"json"};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"userId" forHTTPHeaderField:GoogleAPIKey];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation,
                                                       id responseObject) {
        // search successful, parse objects
        [self parseResponseObject:responseObject];
        block(YES, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // search failed, show network error
        block(NO, error);
    }];
}

#pragma mark - JSON parsing

- (void)parseResponseObject:(NSDictionary *)responseObject
{
    self.bookResults = [[NSMutableArray alloc] init];
    NSArray *results = responseObject[@"items"];
    if (!results) {
        // no results, return
        return;
    }
    
    for (NSDictionary *bookResult in results) {
        NSDictionary *bookDetails = bookResult[@"volumeInfo"];
        PBSBookResult *bookResult = [[PBSBookResult alloc] init];
        bookResult.title = bookDetails[@"title"];
        bookResult.subtitle = bookDetails[@"subtitle"];
        bookResult.author = bookDetails[@"authors"][0];
        bookResult.publisher = bookDetails[@"publisher"];
        bookResult.bookDescription = bookDetails[@"description"];
        bookResult.language = bookDetails[@"language"];
        bookResult.imageLink = bookDetails[@"imageLinks"][@"thumbnail"];
        bookResult.previewLink = bookDetails[@"infoLink"];
        bookResult.pages = bookDetails[@"pageCount"];
        bookResult.rating = bookDetails[@"averageRating"];
        bookResult.numberOfRatings = bookDetails[@"ratingsCount"];
        bookResult.year = bookDetails[@"publishedDate"];
        bookResult.ISBN10 = [bookResult formatNumber:bookDetails[@"industryIdentifiers"][0][@"identifier"]];
        [self.bookResults addObject:bookResult];
    }
}

@end
