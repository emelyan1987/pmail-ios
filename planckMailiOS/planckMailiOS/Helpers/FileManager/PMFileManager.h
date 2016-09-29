//
//  PMFileManager.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PMFileManager : NSObject

+(NSString *)MobileDirectory;
+(NSString *)DownloadDirectory:(NSString*)storeType;
+(NSString *)ThumbnailDirectory:(NSString*)storeType;


+(NSString *)IconFileByExt:(NSString *)filename;
+(NSString *)RelativeTime:(int)datetimestamp;

+(BOOL)IsThumbnailAbaliable:(NSString *)filename;
+(UIImage *)ThumbnailFromFile:(NSString *)path;
+(NSString*)FileSizeAsString:(long long)size;

+(NSString*)MimeTypeForFile:(NSString*)filepath;
+(NSString*)ExtensionForMime:(NSString*)mimetype;
+(BOOL)IsEqualToType:(NSString*)type filename:(NSString*)filename;
@end
