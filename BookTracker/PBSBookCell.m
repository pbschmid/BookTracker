//
//  PBSBookCell.m
//  BookTracker
//
//  Created by Philippe Schmid on 15.10.14.
//  Copyright (c) 2014 Philippe Schmid. All rights reserved.
//

#import "PBSBookCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation PBSBookCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    UIView *selectedView = [[UIView alloc] initWithFrame:CGRectZero];
    selectedView.backgroundColor = [UIColor colorWithRed:45/255.0f green:29/255.0f
                                                    blue:19/255.0f alpha:0.5f];
    self.selectedBackgroundView = selectedView;
    
    self.titleLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:1.0f];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    self.authorLabel.textColor = [UIColor colorWithRed:45/255.0f green:29/255.0f blue:19/255.0f alpha:0.8f];
    self.authorLabel.backgroundColor = [UIColor clearColor];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.text = @"";
    self.authorLabel.text = @"";
    [self.coverImageView cancelImageRequestOperation];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
