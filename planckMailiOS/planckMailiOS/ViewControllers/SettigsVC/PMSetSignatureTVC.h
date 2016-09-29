//
//  PMDefaultEmailVC.h
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PMSetSignatureTVC;

@protocol PMSetSignatureTVCDelegate <NSObject>

-(void)signatureTVC:(PMSetSignatureTVC*)tvc didSetSignature:(BOOL)perAccount signatureData:(NSDictionary*)signatureData;

@end

@interface PMSetSignatureTVC : UITableViewController

@property(nonatomic, strong) id<PMSetSignatureTVCDelegate> delegate;
@end
