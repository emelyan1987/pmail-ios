//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMSoundSelectTVC;

@protocol PMSoundSelectTVCDelegate <NSObject>

-(void)soundSelectTVC:(PMSoundSelectTVC*)tvc didSelectSound:(NSString*)sound;

@end

@interface PMSoundSelectTVC : UITableViewController

@property(nonatomic, strong) id<PMSoundSelectTVCDelegate>delegate;

@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *email;
@end
