//
//  WKPlainRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKPlainRow.h"
#import "PMTypeContainer.h"

@interface WKPlainRow ()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLable;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *mainGroup;

@property (nonatomic, retain) PMTypeContainer *typeContainer;

@end

@implementation WKPlainRow

- (void)setTypeContainer:(PMTypeContainer *)typeContainer {
  _typeContainer = typeContainer;
  
  
  
    
  if([typeContainer.email_address length] > 0 && typeContainer.isNameSpace) {
    NSArray *arr = [typeContainer.email_address componentsSeparatedByString:@"@"];
    if([arr count] == 2) {
        NSString *newTitle = [[arr[1] componentsSeparatedByString:@"."] firstObject];
        newTitle = [newTitle stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[newTitle substringToIndex:1] uppercaseString]];
        
        if(typeContainer.unreadCount > 0)
            newTitle = [NSString stringWithFormat:@"%@ (%i)", newTitle, (int)typeContainer.unreadCount];
        [self.titleLable setText:[NSString stringWithFormat:@"%@\n%@", arr[0], newTitle]];
    }
  } else if (!typeContainer.isNameSpace) {
    [self.titleLable setText:typeContainer.provider];
  }
}

- (void)setTitle:(NSString *)title {
  [self.titleLable setText:title];
}

@end
