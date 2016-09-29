//
//  PMMailTitleView.m
//  planckMailiOS
//
//  Created by admin on 7/5/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMMailTitleView.h"

@interface PMMailTitleView () {
    __weak IBOutlet UILabel *_titleLable;
    __weak IBOutlet UILabel *_subTitleLable;
}
@end

@implementation PMMailTitleView

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLable.text = _title;
}

- (void)setSubTitle:(NSString *)subTitle {
    _subTitle = subTitle;
    _subTitleLable.text = _subTitle;
}

@end
