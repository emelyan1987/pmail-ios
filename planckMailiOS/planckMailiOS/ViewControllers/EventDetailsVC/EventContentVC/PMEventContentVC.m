//
//  PMEventContentVC.m
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMEventContentVC.h"
#import "PMEventAlertVC.h"
#import "UIViewController+PMStoryboard.h"

#import "PMEventModel.h"

#import "NSDate+DateConverter.h"
#import "PMEventContentTitleCell.h"
#import "PMEventParticipantCell.h"

#import "PMParticipantModel.h"
#import "PMPreviewPeopleVC.h"
#import "PMContactModel.h"
#import "PMDraftModel.h"
#import "PMMailComposeVC.h"
#import "PMTextManager.h"
#import "PMLocationManager.h"
#import "AlertManager.h"
#import "PMCreateContactVC.h"
#import "PMPeopleVC.h"
#import "PMSettingsManager.h"
#import "PMSFCreateContactNC.h"
#import "PMSFCreateLeadNC.h"
#import <MapKit/MapKit.h>
#import "DBMessage.h"
#import "PMEventRSVPCell.h"
#import "PMRSVPManager.h"
#import "PMEventDescriptionCell.h"
#import "PMEventDescriptionVC.h"
#import "Config.h"

#define EVENT_CONTENT_TITLE_CELL @"eventContentTitleCell"
#define EVENT_CONTENT_RSVP_CELL @"eventContentRSVPCell"
#define EVENT_CONTENT_DESCRIPTION_CELL @"eventContentDescriptionCell"
#define EVENT_CONTENT_PLACE_CELL @"eventContentPlaceCell"
#define EVENT_CONTENT_PARTICIPANT_CELL @"eventContentParticipantCell"
#define EVENT_CONTENT_ALERT_CELL @"eventContentAlertCell"



@interface PMEventContentVC () <UITableViewDataSource, UITableViewDelegate>
{
    
    __weak IBOutlet UITableView *_tableView;
    
    PMParticipantModel *organizer;
    NSString *status;
    
    NSMutableArray *participants;
    NSMutableArray *sections;
    NSMutableDictionary *cells;
}
@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIView *actionView1;

@end

@implementation PMEventContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _actionView.layer.cornerRadius = _actionView.frame.size.height/2;
    _actionView1.layer.cornerRadius = _actionView1.frame.size.height/2;
    
    _actionView.hidden = YES;
    _actionView1.hidden = YES;
    
    [self setOrganizerAndStatus];
    
    [self loadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    if([self.delegate respondsToSelector:@selector(eventContentVCDidAppear:)])
        [self.delegate eventContentVCDidAppear:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setOrganizerAndStatus
{
    if(!_currentEvent.participants || _currentEvent.participants.count==0)
    {
        _actionView.hidden = YES; _actionView1.hidden = YES; return;
    }
    
    BOOL hasOrganizer = NO;
    if(_currentEvent.messageId)
    {
        DBMessage *message = [DBMessage getMessageWithId:_currentEvent.messageId];
        
        if(message)
        {
            NSDictionary *from = [message getFrom];
            if(from)
            {
                organizer = [[PMParticipantModel alloc] initWithDictionary:from];
                organizer.isOrganizer = YES;
                
                for(PMParticipantModel *participant in _currentEvent.participants)
                {
                    DBNamespace *namespace = [DBNamespace getNamespaceWithAccountId:_currentEvent.accountId];
                    if([participant.email isEqualToString:namespace.email_address])
                    {
                        status = participant.status;
                    }
                }
                
                hasOrganizer = YES;
            }
        }
    }
    
    if(hasOrganizer)
    {
        _actionView.hidden = YES; _actionView1.hidden = NO;
    }
    else
    {
        _actionView.hidden = NO; _actionView1.hidden = YES;
    }
    
}

-(void)loadData
{
    sections = [NSMutableArray new];
    cells = [NSMutableDictionary new];
    
    // Set main section(Title, RSVP, Description)
    NSMutableArray *cellsForMainSection = [NSMutableArray new];
    [cellsForMainSection addObject:EVENT_CONTENT_TITLE_CELL];
    if(status) [cellsForMainSection addObject:EVENT_CONTENT_RSVP_CELL];
    if(_currentEvent.eventDescription && _currentEvent.eventDescription.length) [cellsForMainSection addObject:EVENT_CONTENT_DESCRIPTION_CELL];
    
    NSString *mainSection = @"main";
    [sections addObject:mainSection];
    [cells setObject:cellsForMainSection forKey:mainSection];
    
    // Set location section
    if(_currentEvent.location && _currentEvent.location.length)
    {
        NSString *placeSection = @"place";
        [sections addObject:placeSection];
        [cells setObject:@[EVENT_CONTENT_PLACE_CELL] forKey:placeSection];
    }
    
    // Set participants section
    NSMutableArray *cellsForParticipantSection = [NSMutableArray new];
    participants = [NSMutableArray new];
    if(organizer)
    {
        [cellsForParticipantSection addObject:EVENT_CONTENT_PARTICIPANT_CELL];
        [participants addObject:organizer];
    }
    for(PMParticipantModel *participant in _currentEvent.participants)
    {
        [cellsForParticipantSection addObject:EVENT_CONTENT_PARTICIPANT_CELL];
        [participants addObject:participant];
    }
    
    NSString *participantSection = @"participant";
    [sections addObject:participantSection];
    [cells setObject:cellsForParticipantSection forKey:participantSection];
    
    // Set location section
    if(_currentEvent.alertMessage && _currentEvent.alertMessage.length)
    {
        NSString *alertSection = @"alert";
        [sections addObject:alertSection];
        [cells setObject:@[EVENT_CONTENT_ALERT_CELL] forKey:alertSection];
    }
    
}
- (void)updateWithEvent:(PMEventModel *)event {
    _currentEvent = event;
}

#pragma mark - Table view data source

-(CGFloat)calculateDescriptionCellHeight
{
    if(_currentEvent.eventDescription.length>0){
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(46, 0, self.view.frame.size.width-46, 23)];
        lbl.numberOfLines = 2;
        lbl.lineBreakMode = NSLineBreakByWordWrapping;
        [lbl setText:_currentEvent.eventDescription];
        [lbl sizeToFit];
        
        CGFloat height = lbl.frame.size.height+20;
        if(height>70) height = 70;
        return height;
    }
    else return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = [cells objectForKey:sections[section]];
    
    return rows.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [cells objectForKey:sections[indexPath.section]][indexPath.row];
    
    if([cellIdentifier isEqualToString:EVENT_CONTENT_TITLE_CELL])
        return 108;
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_DESCRIPTION_CELL])
        return 60;
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_PARTICIPANT_CELL])
        return 60;
    
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [cells objectForKey:sections[indexPath.section]][indexPath.row];
    
    if([cellIdentifier isEqualToString:EVENT_CONTENT_TITLE_CELL])
    {
        PMEventContentTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_CONTENT_TITLE_CELL];
        [cell setEvent:_currentEvent];
        
        return cell;
        
    }
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_RSVP_CELL])
    {
        PMEventRSVPCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_CONTENT_RSVP_CELL];
        [cell bindData:status];
        
        __weak typeof(self) weakSelf = self;
        cell.btnRSVPTapAction = ^(id sender) {
            [weakSelf showRSVPAlert:sender];
        };
        
        return cell;
    }
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_DESCRIPTION_CELL])
    {
        PMEventDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"eventContentDescriptionCell"];
        cell.lblDescription.text = [[PMTextManager shared] convertHTML:_currentEvent.eventDescription];
        return cell;
    }
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_PLACE_CELL])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_CONTENT_PLACE_CELL];
        cell.textLabel.text = _currentEvent.location;
        return cell;
    }
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_PARTICIPANT_CELL])
    {
        PMParticipantModel *participant = participants[indexPath.row];
        
        PMEventParticipantCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_CONTENT_PARTICIPANT_CELL];
        
        [cell bindModel:participant];
        
        return  cell;
    }
    else if([cellIdentifier isEqualToString:EVENT_CONTENT_ALERT_CELL])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_CONTENT_ALERT_CELL];
        cell.textLabel.text = _currentEvent.alertMessage;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellIdentifier = [cell reuseIdentifier];
    
    if([cellIdentifier isEqualToString:EVENT_CONTENT_DESCRIPTION_CELL])
    {
        PMEventDescriptionVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventDescriptionVC"];
        vc.event = _currentEvent;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if([cellIdentifier isEqualToString:EVENT_CONTENT_PARTICIPANT_CELL])
    {
        PMParticipantModel *participant = _currentEvent.participants[indexPath.row];
        
        NSString *email = participant.email;
        NSString *name = participant.name;
        
        __block DBSavedContact *contact = [DBSavedContact getContactWithEmail:email];
        
        if(contact)
        {
            PMPreviewPeopleVC *lPreviewPeople = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMPreviewPeopleVC"];
            lPreviewPeople.contact = contact;
            
            self.navigationController.navigationBarHidden = NO;
            [self.navigationController pushViewController:lPreviewPeople animated:YES];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:email message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction *actionCreate = [UIAlertAction actionWithTitle:@"Create New Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                PMCreateContactVC *controller = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMCreateContactVC"];
                
                NSDictionary *data = @{@"emails":[NSMutableArray arrayWithArray:@[email]], @"name":name};
                controller.data = data;
                
                [self presentViewController:controller animated:YES completion:nil];
            }];
            [alert addAction:actionCreate];
            
            UIAlertAction *actionUpdate = [UIAlertAction actionWithTitle:@"Add to Existing Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                PMPeopleVC *controller = [PEOPLE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMPeopleVC"];
                controller.isPicker = YES;
                controller.email = email;
                
                
                self.navigationController.navigationBarHidden = NO;
                [self.navigationController pushViewController:controller animated:YES];
            }];
            [alert addAction:actionUpdate];
            
            if([[PMSettingsManager instance] getEnabledSalesforce])
            {
                UIAlertAction *actionCreateSalesforceContact = [UIAlertAction actionWithTitle:@"Create New Salesforce Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    PMSFCreateContactNC *controller = [SALESFORCE_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFCreateContactNC"];
                    
                    NSArray *names = [name componentsSeparatedByString:@" "];
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"Email":email}];
                    if(names.count)
                    {
                        [data setObject:names[0] forKey:@"FirstName"];
                        if(names.count>1) [data setObject:[names lastObject] forKey:@"LastName"];
                        if(names.count>2) [data setObject:names[1] forKey:@"MiddleName"];
                    }
                    controller.data = data;
                    
                    [self presentViewController:controller animated:YES completion:nil];
                }];
                [alert addAction:actionCreateSalesforceContact];
                
                UIAlertAction *actionCreateSalesforceLead = [UIAlertAction actionWithTitle:@"Create New Salesforce Lead" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    PMSFCreateLeadNC *controller = [LEADS_STORYBOARD instantiateViewControllerWithIdentifier:@"PMSFCreateLeadNC"];
                    
                    NSArray *names = [name componentsSeparatedByString:@" "];
                    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{@"Email":email}];
                    if(names.count)
                    {
                        [data setObject:names[0] forKey:@"FirstName"];
                        if(names.count>1) [data setObject:[names lastObject] forKey:@"LastName"];
                        if(names.count>2) [data setObject:names[1] forKey:@"MiddleName"];
                    }
                    controller.data = data;
                    
                    [self presentViewController:controller animated:YES completion:nil];
                }];
                [alert addAction:actionCreateSalesforceLead];
            }
            UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:actionCancel];
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            alert.popoverPresentationController.sourceView = cell;
            alert.popoverPresentationController.sourceRect = cell.bounds;
            
            [self presentViewController:alert animated:YES completion:nil];
            
        }

        
    }
    else if(indexPath.section == 1)
    {
        if(_currentEvent.location && _currentEvent.location.length>0)
        {
            
            /*NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?address=%@", _currentEvent.location];
            NSURL *url = [NSURL URLWithString:urlString];
            if([[UIApplication sharedApplication] canOpenURL:url])
                [[UIApplication sharedApplication] openURL:url];
            else
                [AlertManager showErrorMessage:@"Can't open map"];*/
            
            /*NSString *urlString = [NSString stringWithFormat:@"http://maps.apple.com/?address=%@", _currentEvent.location];
            if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps://"]]) {
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic"]];
            } else {
                NSLog(@"Can't use comgooglemaps://");
            }*/
            
            CLLocationCoordinate2D coordinates = [PMLocationManager GetLocationFromAddressString:_currentEvent.location];
            MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinates addressDictionary:nil];
            MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
            item.name = _currentEvent.location;
            [item openInMapsWithLaunchOptions:nil];
        }
    }
}
- (IBAction)btnEveryonePressed:(id)sender {
    [self showReplyAlert:NO];

}
- (IBAction)btnOrganizerPressed:(id)sender
{
    [self showReplyAlert:YES];
}

-(void)showReplyAlert:(BOOL)isOrganizer
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:nil
                                  message:nil
                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction
                              actionWithTitle:@"I'm running late"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  [self reply:@"I'm running late" isOrganizer:isOrganizer];
                              }];
    
    UIAlertAction *action2 = [UIAlertAction
                              actionWithTitle:@"Send a note"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                                  [self reply:@"Send a note" isOrganizer:isOrganizer];
                              }];
    
    UIAlertAction *actionCancel = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:actionCancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)reply:(NSString*)message isOrganizer:(BOOL)isOrganizer
{
    NSMutableArray *to = [NSMutableArray new];
    
    if(isOrganizer)
    {
        NSDictionary *toDic = @{@"name":organizer.name, @"email":organizer.email};
        
        [to addObject:toDic];
    }
    else
    {
        for(PMParticipantModel *participant in _currentEvent.participants)
        {
            NSDictionary *toDic = @{@"name":participant.name?participant.name:@"", @"email":participant.email};
            [to addObject:toDic];
        }
    }
    
    PMDraftModel *lDraft = [PMDraftModel new];
    lDraft.to = to;
    lDraft.subject = [NSString stringWithFormat:@"Re: %@", _currentEvent.title];
    lDraft.body = [NSString stringWithFormat:@"%@", message];
    
    PMMailComposeVC *lNewMailComposeVC = [MAIL_STORYBOARD instantiateViewControllerWithIdentifier:@"PMMailComposeVC"];
    lNewMailComposeVC.draft = lDraft;
    lNewMailComposeVC.messageId = _currentEvent.messageId;
    [self.navigationController presentViewController:lNewMailComposeVC animated:YES completion:nil];
}

-(void)showRSVPAlert:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actionAccept = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:_currentEvent.id type:RSVP_TYPE_ACCEPT completion:nil];
    }];
    UIAlertAction *actionTentative = [UIAlertAction actionWithTitle:@"Tentative" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:_currentEvent.id type:RSVP_TYPE_TENTATIVE completion:nil];
        
        
    }];
    UIAlertAction *actionDecline = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
        
        [[PMRSVPManager sharedInstance] sendRSVP:_currentEvent.id type:RSVP_TYPE_DECLINE completion:nil];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionAccept];
    [alert addAction:actionTentative];
    [alert addAction:actionDecline];
    [alert addAction:actionCancel];
    
    UIButton *btn = (UIButton*)sender;
    alert.popoverPresentationController.sourceView = btn;
    alert.popoverPresentationController.sourceRect = btn.bounds;
    
    [self presentViewController:alert animated:YES completion:nil];
}
@end
