//
//  PMLoadMoreTVCell.m
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMLoadMoreTVCell.h"

@interface PMLoadMoreTVCell () {
    __weak IBOutlet UIActivityIndicatorView *_activity;
}
@end

@implementation PMLoadMoreTVCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)show {
    self.textLabel.textColor = [UIColor blueColor];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.text = @"Load more conversations";
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.userInteractionEnabled = YES;
    _activity.hidden = YES;
    [_activity stopAnimating];
}

- (void)hide {
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.text = @"Loading...";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = NO;
    _activity.hidden = NO;
    [_activity startAnimating];
}

@end
