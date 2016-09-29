//
//  PMTextManager.h
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMTextManager : NSObject

+(PMTextManager *)shared;

-(NSString*)convertHTML:(NSString*)HTMLString;
-(NSInteger)countOfLines:(NSString*)text;

-(void)getSummarizedTextFromHTML:(NSString*)html messageId:(NSString*)messageId completion:(nullable void (^)(NSString *result, BOOL success))completion;

-(NSString*)getLabelLettersFromText:(NSString*)text;

-(NSString*)ConvertPriceToHumanReadableString:(double)amount currency:(NSString*)currency;

-(NSString*)getCallablePhoneNumber:(NSString*)phoneNumber;

-(BOOL)isValidEmail:(NSString*)email;
@end
