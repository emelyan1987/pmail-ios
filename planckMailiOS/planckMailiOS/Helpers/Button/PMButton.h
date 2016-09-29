//
//  PMButton.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 11/15/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface PMButton : UIButton
@property(nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic, strong) IBInspectable UIColor *borderColor;
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;
@end
