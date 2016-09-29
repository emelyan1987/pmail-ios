//
//  WKSectionRow.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/31/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SERCION_ROW_TYPE @"section_row_type"

@class WKInterfaceLabel;
@interface WKSectionRow : NSObject

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLabel;

- (void)setTitle:(NSString *)title;

@end
