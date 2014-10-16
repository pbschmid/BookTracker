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
    NSString *categoryName;
    switch (category) {
        case 0:
            categoryName = @"";
            break;
        case 1:
            categoryName = @"intitle:";
            break;
        case 2:
            categoryName = @"inauthor:";
            break;
        case 3:
            categoryName = @"isbn:";
            break;
    }
    
    NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    
    NSString *escapedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://www.googleapis.com/books/v1/volumes?q=%@&country=%@",
                           escapedText, countryCode];
    
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
        
        book.categories = bookDetails[@"categories"];
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
