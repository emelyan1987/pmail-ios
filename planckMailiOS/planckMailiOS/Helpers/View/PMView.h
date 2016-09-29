//
//  PMView.h
//  planckMailiOS
//
//  Created by nazar on 11/11/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PMView : UIView

@property(nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;
@property(nonatomic, strong) IBInspectable UIColor *borderColor;

@end
