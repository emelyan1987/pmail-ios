//
//  NSArray+MailModel.m
//  planckMailiOS
//
//  Created by Matko Lajbaher on 11/18/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "NSMutableArray+PMThread.h"

@implementation NSMutableArray(PMThread)

-(BOOL)changedMail:(PMThread*)mail
{
    for(PMThread *model in self)
    {
        if([model.id isEqualToString:mail.id])
        {
            if(model.version!=mail.version) return YES;
        }
    }
    
    return NO;
}
-(BOOL)isContainMail:(PMThread *)mail
{
    for(PMThread *model in self)
    {
        if([model.id isEqualToString:mail.id])
            return YES;
    }
    
    return NO;
}

-(void)changeMail:(PMThread*)mail
{
    for(PMThread *model in self)
    {
        if([model.id isEqualToString:mail.id])
        {
            model.messagesCount = mail.messagesCount;
            model.isUnread = mail.isUnread;
        }
    }
}
-(void)addMail:(PMThread *)mail
{
    [self addObject:mail];
    
    [self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        PMThread *model1 = obj1;
        PMThread *model2 = obj2;
        
        return [model2.lastMessageDate compare:model1.lastMessageDate];
    }];
}
@end
