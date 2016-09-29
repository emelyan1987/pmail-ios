//
//  PMDefaultEmailVC.m
//  planckMailiOS
//
//  Created by LionStar on 12/25/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMSoundSelectTVC.h"
#import "PMSettingsManager.h"
#import "Config.h"
#import <AVFoundation/AVFoundation.h>

@interface PMSoundSelectTVC () <UITableViewDataSource, UITableViewDelegate>
{
    NSArray *_sounds;
    NSString *_selectedSound;
    
    AVAudioPlayer *backgroundMusicPlayer;
}
@end

@implementation PMSoundSelectTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBar];
    
    [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _sounds = @[@"Off", @"Default", @"Alert", @"Bright", @"Chime", @"Chirp", @"Dots", @"Glossy", @"Light", @"Note"];
    _selectedSound = [self.type isEqualToString:@"mail"]?[[PMSettingsManager instance] getMailNotificationSound:self.email]:[[PMSettingsManager instance] getCalendarNotificationSound:self.email];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setNavigationBar
{
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    
    
    
    lblTitle.text =  @"Notification Sound";
    lblTitle.textColor = [UIColor whiteColor];
    
    float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    
    lblTitle.frame = CGRectMake(0, 0, maximumLabelSize, 35);
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, maximumLabelSize, 35)];
    
    [headerview addSubview:lblTitle];
    
    self.navigationItem.titleView = headerview;
}

-(void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma UITableViewDataSource & UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _sounds.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sound = _sounds[indexPath.row];
    
    static NSString *cellIdentifier = @"soundItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = sound;
    
    if([_selectedSound isEqualToString:sound])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _selectedSound = _sounds[indexPath.row];
    
    if(![_selectedSound isEqualToString:@"Off"])
    {
        NSError *error;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:_selectedSound ofType:@"mp3"];
        NSURL *soundURL = [NSURL fileURLWithPath:filePath];
        backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
        [backgroundMusicPlayer prepareToPlay];
        [backgroundMusicPlayer play];

    }
    
    if([self.type isEqualToString:@"mail"])
        [[PMSettingsManager instance] setMailNotificationSound:_selectedSound email:self.email];
    else
        [[PMSettingsManager instance] setCalendarNotificationSound:_selectedSound email:self.email];

    
    [tableView reloadData];
    
    if([self.delegate respondsToSelector:@selector(soundSelectTVC:didSelectSound:)])
        [self.delegate soundSelectTVC:self didSelectSound:_selectedSound];
    
}
@end
