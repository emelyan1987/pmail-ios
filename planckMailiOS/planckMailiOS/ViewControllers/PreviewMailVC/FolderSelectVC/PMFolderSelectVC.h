//
//  PMFolderSelectVC.h
//  planckMailiOS
//
//  Created by LionStar on 4/11/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PMFolderSelectVCDelegate <NSObject>

- (void)didSelectFolder:(NSString*)folderId;

@end
@interface PMFolderSelectVC : UIViewController

@property (nonatomic, strong) id<PMFolderSelectVCDelegate> delegate;

@property (nonatomic, strong) NSString *accountId;
@end
