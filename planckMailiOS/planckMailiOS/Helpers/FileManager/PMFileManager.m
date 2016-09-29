//
//  PMFileManager.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 10/28/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMFileManager.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation PMFileManager

+(NSString*)MobileDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Local"];
    
    if(![fileManager fileExistsAtPath:folder])
    {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success || error) {
            return nil;
        }
    }
    
    return folder;
}

+(NSString*)DownloadDirectory:(NSString*)storeType
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Download", storeType]];
    
    if(![fileManager fileExistsAtPath:folder])
    {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success || error) {
            return nil;
        }
    }
    
    return folder;
}

+(NSString*)ThumbnailDirectory:(NSString*)storeType
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *folder = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Thumbnail", storeType]];
    
    if(![fileManager fileExistsAtPath:folder])
    {
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success || error) {
            return nil;
        }
    }
    
    return folder;
}

+(BOOL)IsThumbnailAbaliable:(NSString *)filename
{
    BOOL supportsThumbnail = NO;
    
    NSString *extension = [[filename pathExtension] lowercaseString];
    
    if ([extension isEqualToString:@"png"] ||
        [extension isEqualToString:@"jpg"] ||
        [extension isEqualToString:@"jpeg"] ||
        [extension isEqualToString:@"gif"] ||
        [extension isEqualToString:@"tiff"] ||
        [extension isEqualToString:@"tif"] ||
        [extension isEqualToString:@"bmp"] ||
        [extension isEqualToString:@"avi"] ||
        [extension isEqualToString:@"m4v"] ||
        [extension isEqualToString:@"mov"] ||
        [extension isEqualToString:@"mp4"])
    {
        supportsThumbnail = YES;
    }
    
    
    return supportsThumbnail;
}

+ (UIImage *)ThumbnailFromFile:(NSString *)path {
    
    NSString *ext = [[path pathExtension] lowercaseString];
    
    if([ext isEqualToString:@"mov"] || [ext isEqualToString:@"avi"] || [ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mpg"] || [ext isEqualToString:@"flv"])
    {
        NSURL *url = [NSURL fileURLWithPath:path];
        UIImage *theImage = nil;
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 60);
        CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
        
        theImage = [[UIImage alloc] initWithCGImage:imgRef];
        
        CGImageRelease(imgRef);
        
        
        return theImage;
    }
    else if([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"gif"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"ico"])
    {
        UIImage *originalImage = [UIImage imageWithContentsOfFile:path];
        CGSize destinationSize = CGSizeMake(64, 64 * originalImage.size.height / originalImage.size.width);
        UIGraphicsBeginImageContext(destinationSize);
        [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return newImage;
    }
    
    return nil;
}


+(NSString *)IconFileByExt:(NSString *)fileext
{
    NSString *ext = [fileext lowercaseString];
    if([ext isEqualToString:@"doc"] || [ext isEqualToString:@"docx"] || [ext isEqualToString:@"rtf"])
        return @"doc.png";
    else if([ext isEqualToString:@"ppt"] || [ext isEqualToString:@"pptx"])
        return @"ppt.png";
    else if([ext isEqualToString:@"xls"] || [ext isEqualToString:@"xlsx"])
        return @"xls.png";
    else if([ext isEqualToString:@"pdf"])
        return @"pdf.png";
    else if([ext isEqualToString:@"zip"] || [ext isEqualToString:@"rar"] || [ext isEqualToString:@"gz"])
        return @"zip.png";
    else if([ext isEqualToString:@"jpg"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"gif"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"ico"])
        return @"image.png";
    else if([ext isEqualToString:@"mp3"] || [ext isEqualToString:@"wma"])
        return @"music.png";
    else if([ext isEqualToString:@"mov"] || [ext isEqualToString:@"avi"] || [ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mpg"] || [ext isEqualToString:@"flv"])
        return @"video.png";
    else
        return @"file.png";
}

+(NSString *)RelativeTime:(int)datetimestamp
{
    NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:datetimestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unitFlags =  NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth|NSCalendarUnitWeekdayOrdinal|NSCalendarUnitWeekday|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *messageDateComponents = [calendar components:unitFlags fromDate:aDate];
    NSDateComponents *todayDateComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSUInteger dayOfYearForMessage = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:aDate];
    NSUInteger dayOfYearForToday = [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
    
    
    NSString *dateString;
    
    if ([messageDateComponents year] == [todayDateComponents year] &&
        [messageDateComponents month] == [todayDateComponents month] &&
        [messageDateComponents day] == [todayDateComponents day])
    {
        dateString = [NSString stringWithFormat:@"%02d:%02d", (int)[messageDateComponents hour], (int)[messageDateComponents minute]];
    } else if ([messageDateComponents year] == [todayDateComponents year] &&
               dayOfYearForMessage == (dayOfYearForToday-1))
    {
        dateString = @"Yesterday";
    } else if ([messageDateComponents year] == [todayDateComponents year] &&
               dayOfYearForMessage > (dayOfYearForToday-6))
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE"];
        dateString = [dateFormatter stringFromDate:aDate];
    } else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yy"];
        dateString = [NSString stringWithFormat:@"%02d/%02d/%@", (int)[messageDateComponents day], (int)[messageDateComponents month], [dateFormatter stringFromDate:aDate]];
        
    }
    
    return dateString;
}

+(NSString*)FileSizeAsString:(long long)size
{
    float floatSize = size;
    if (floatSize < 1023)
        return([NSString stringWithFormat:@"%1.0fB", floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1fKB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1fMB",floatSize]);
    floatSize = floatSize / 1024;
    
    return([NSString stringWithFormat:@"%1.1fGB",floatSize]);
}

+(NSString*)MimeTypeForFile:(NSString *)filepath
{
    NSString *extension = [[filepath pathExtension] lowercaseString];
    
    if([extension isEqualToString:@"jpe"] || [extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
        return @"image/jpeg";
    else if([extension isEqualToString:@"png"])
        return @"image/png";
    else if([extension isEqualToString:@"asf"] || [extension isEqualToString:@"asr"] || [extension isEqualToString:@"asx"])
        return @"video/x-ms-asf";
    else if([extension isEqualToString:@"avi"])
        return @"video/x-msvideo";
    else if([extension isEqualToString:@"mov"] || [extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"])
        return @"video/quicktime";
    else if([extension isEqualToString:@"mp2"] || [extension isEqualToString:@"mpa"] || [extension isEqualToString:@"mpe"] || [extension isEqualToString:@"mpeg"] || [extension isEqualToString:@"mpg"])
        return @"video/mpeg";
    else if([extension isEqualToString:@"mp3"])
        return @"audio/mpeg";
    else if([extension isEqualToString:@"txt"])
        return @"text/plain";
    else if([extension isEqualToString:@"gz"])
        return @"application/x-gzip";
    else if([extension isEqualToString:@"zip"])
        return @"application/zip";
    else if([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"])
        return @"application/msword";
    
    return @"application/octet-stream";
    
}

+(BOOL)IsEqualToType:(NSString *)type filename:(NSString *)filename
{
    
    NSString *extension = [[filename pathExtension] lowercaseString];
    
    
    if([type isEqualToString:@"image"] && ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || [extension isEqualToString:@"png"] || [extension isEqualToString:@"gif"]))
    {
        return YES;
    }
    else if([type isEqualToString:@"doc"] && ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"] || [extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"] || [extension isEqualToString:@"rtf"]))
    {
        return YES;
    }
    else if([type isEqualToString:@"ppt"] && ([extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"]))
    {
        return YES;
    }
    else if([type isEqualToString:@"pdf"] && [extension isEqualToString:@"pdf"])
    {
        return YES;
    }
    else if([type isEqualToString:@"zip"] && ([extension isEqualToString:@"zip"] || [extension isEqualToString:@"rar"] || [extension isEqualToString:@"gz"]))
    {
        return YES;
    }
    return NO;
}

+(NSString*)ExtensionForMime:(NSString *)mimetype
{
    // get a UTI for a mime type
    CFStringRef mimeType = (__bridge CFStringRef)mimetype;
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType, NULL);
    // uti now equals "public.png"
    
    CFStringRef extension = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassFilenameExtension);
    return (__bridge NSString*)extension;
}


@end
