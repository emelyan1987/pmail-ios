//
//  PMFileItem.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMFileItem : NSObject

@property NSString *name;
@property NSString *path;
@property NSString *fullpath;
@property long long size;
@property NSDate *modifiedTime;
@property BOOL isDirectory;
@property NSString *type;

@end
