//
//  PMLocationManager.h
//  planckMailiOS
//
//  Created by LionStar on 1/7/16.
//  Copyright © 2016 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PMLocationManager : NSObject
+(CLLocationCoordinate2D) GetLocationFromAddressString: (NSString*) addressStr;
@end
