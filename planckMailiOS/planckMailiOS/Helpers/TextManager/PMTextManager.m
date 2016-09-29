//
//  PMTextManager.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/6/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMTextManager.h"
#import "NSAttributedString+HTML.h"
#import "FTWCache.h"
#import "PMAPIManager.h"

@implementation PMTextManager

+ (PMTextManager*)shared {
    static PMTextManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMTextManager new];
    });
    return sharedManager;
}

-(NSString*)convertHTML:(NSString*)HTMLString
{
    NSData *data = [HTMLString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data documentAttributes:NULL];
    NSLog(@"%@", attrString);
    
    return [attrString string];
}

-(NSInteger)countOfLines:(NSString*)text
{
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSArray *rows = [text componentsSeparatedByCharactersInSet:separator];
    
    return rows.count;
}

-(void)getSummarizedTextFromHTML:(NSString *)html messageId:(NSString *)messageId completion:(void (^)(NSString *, BOOL))completion
{
    if(completion==nil) return;
    
    NSData *cacheData = [FTWCache objectForKey:messageId];
    NSArray *summaries = [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
    
    if(summaries!=nil)
    {
        NSString *highlightedHTML = [self summarize:summaries html:html];
        
        completion(highlightedHTML, YES);
    }
    else
    {
        NSString *plainText = [self convertHTML:html];
        
        if(plainText==nil || plainText.length==0) return;
        NSInteger lines = [self countOfLines:plainText];
        NSInteger length = lines * 25 / 100;
        length = length==0?lines:length;
        
        [[PMAPIManager shared] getSummariesFromText:plainText lines:length completion:^(id data, id error, BOOL success) {
            if(error==nil)
            {
                NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:data];
                [FTWCache setObject:cacheData forKey:messageId];
                NSString *highlightedHTML = [self summarize:data html:html];
                completion(highlightedHTML, YES);
            }
            else
            {
                completion(nil, NO);
            }
        }];
    }
}

-(NSString *)summarize:(NSArray*)summaries html:(NSString*)html
{
    
    for(NSString *summary in summaries)
    {
        html = [self highlightWithText:summary html:html];
    }
    
    
    return html;
}


-(NSString*)highlightWithText:(NSString*)text html:(NSString*)html
{
    if(html == nil) return nil;
    
    NSMutableArray *keywordArrayToReplace = [[NSMutableArray alloc] init];
    
    NSMutableCharacterSet *seperatorSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSArray *tokens = [text componentsSeparatedByCharactersInSet:seperatorSet];
    
    NSMutableString *keyword = [[NSMutableString alloc] init];
    NSString *prevKeyword = [[NSString alloc] init];
    
    for(NSString *token in tokens)
    {
        if(token.length>0)
        {
            
            if(keyword.length>0)
                [keyword appendString:[@" " stringByAppendingString:token]];
            else
                [keyword appendString:token];
            
            if([html containsString:keyword])
            {
                prevKeyword = [keyword copy];
            }
            else
            {
                if(prevKeyword.length > 0)
                {
                    [keywordArrayToReplace addObject:prevKeyword];
                }
                [keyword setString:token];
                prevKeyword = @"";
            }
        }
    }
    
    [keywordArrayToReplace addObject:keyword];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"length" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [keywordArrayToReplace sortUsingDescriptors:sortDescriptors];
    
    
    for(NSString *keyword in keywordArrayToReplace)
    {
        html = [html stringByReplacingOccurrencesOfString:keyword withString:[NSString stringWithFormat:@"<span class='highlighted'>%@</span>", keyword]];
    }
    
    return html;
}

-(NSString*)getLabelLettersFromText:(NSString *)text
{
    NSMutableString *labelLetters = [[NSMutableString alloc] init];
    
    
    NSArray *labelTokens = [text componentsSeparatedByString:@" "];
    
    
    
        char firstLetter = 0, secondLetter = 0;
        
        for(NSString *token in labelTokens)
        {
            if(firstLetter == 0 && token!=nil && token.length>0)
            {
                firstLetter = [token characterAtIndex:0];
            }
            else if(token!=nil && token.length>0)
            {
                secondLetter = [token characterAtIndex:0];
            }
        }
        
        if(firstLetter)
            [labelLetters appendFormat:@"%c", firstLetter];
    
        if(secondLetter)
            [labelLetters appendFormat:@"%c", secondLetter];
    
    
    
    
    return [labelLetters uppercaseString];
}

- (NSString*)ConvertPriceToHumanReadableString:(double)amount currency:(NSString*)currency
{
    if(currency==nil) currency = @"$";
    
    if (amount < 1000)
        return([NSString stringWithFormat:@"%@%1.2f", currency, amount]);
    amount = amount / 1000;
    if (amount<1000)
        return([NSString stringWithFormat:@"%@%1.2fK", currency,amount]);
    amount = amount / 1000;
    if (amount<1000)
        return([NSString stringWithFormat:@"%@%1.2fM", currency,amount]);
    amount = amount / 1000;
    
    return([NSString stringWithFormat:@"%@%1.2fG", currency,amount]);
}

-(NSString*)getCallablePhoneNumber:(NSString *)phoneNumber
{
    NSString *number = [phoneNumber stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [phoneNumber length])];
    
    
    return number;
}

-(BOOL)isValidEmail:(NSString *)email
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
@end
