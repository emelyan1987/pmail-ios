//
//  PMEventDetailsVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventDetailsVC.h"
#import "UIViewController+PMStoryboard.h"
#import "PMEventModel.h"

#import "PMEventContentVC.h"
#import "PMAPIManager.h"
#import "PMCreateEventVC.h"


@interface PMEventDetailsVC () <UIPageViewControllerDataSource, PMEventContentVCDelegate, PMCreateEventVCDelegate> {
    
    NSArray *_events;
    PMEventModel *_currentEvent;
}
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSUInteger eventsCount;
@property(strong, nonatomic) UIPageViewController *pageController;
@end

@implementation PMEventDetailsVC

- (instancetype)initWithEvents:(NSArray *)events index:(NSUInteger)index
{
    self = [CALENDAR_STORYBOARD instantiateViewControllerWithIdentifier:@"PMEventDetailsVC"];
    if (self) {
        _events = events;
        _currentEvent = events[index];
        _index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
    PMEventContentVC *initialViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventContentVC"];
    
    
    [initialViewController updateWithEvent:_currentEvent];
    [initialViewController setPageIndex:_index];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    //[self.pageController didMoveToParentViewController:self];
    
    
    
    [self setNavigationBar];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlerNotificationEventChanged:) name:NOTIFICATION_EVENT_UPDATED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handlerNotificationEventChanged:(NSNotification*)notification
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSUInteger)eventsCount
{
    return _events.count;
}

#pragma mark - Private methods

- (void)setNavigationBar
{
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backArrow.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onBack)];
    [self.navigationItem setLeftBarButtonItem:btnBack animated:NO];
    
    if (!_currentEvent.readonly) {
        UIBarButtonItem *btnEdit = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editEventBtnPressed:)];
        
        [self.navigationItem setRightBarButtonItem:btnEdit];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
    CGFloat width;
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = size.height;
    }
    else {
        width = size.width;
    }
    width -= 120;
    UILabel *lblTitle = [[UILabel alloc]init];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:18.0f]];
    lblTitle.text = _currentEvent.title;
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.numberOfLines = 1;
    lblTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    //float maximumLabelSize =  [lblTitle.text boundingRectWithSize:lblTitle.frame.size  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:lblTitle.font } context:nil].size.width;
    lblTitle.frame = CGRectMake(0, 0, width, 25);
    
    UILabel *lblCalendarTitle = [[UILabel alloc]init];
    [lblCalendarTitle setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    
    
    lblCalendarTitle.text = [_currentEvent getCalendar].name;
    lblCalendarTitle.textColor = [UIColor whiteColor];
    lblCalendarTitle.textAlignment = NSTextAlignmentCenter;
    lblCalendarTitle.numberOfLines = 1;
    lblCalendarTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    lblCalendarTitle.frame = CGRectMake(0, 26, width, 15);
    
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    
    [headerview addSubview:lblTitle];
    [headerview addSubview:lblCalendarTitle];
    
    self.navigationItem.titleView = headerview;
}

- (void)onBack
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)editEventBtnPressed:(id)sender
{
    PMCreateEventVC *lNewEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PMCreateEventVC"];
    
    UINavigationController *lNavContoller = [[UINavigationController alloc] initWithRootViewController:lNewEventVC];
    lNavContoller.navigationBarHidden = YES;
    lNewEventVC.isUpdate = YES;
    lNewEventVC.eventModel = _currentEvent;
    [lNewEventVC setTitle:@"Edit Event"];
    [lNewEventVC setDelegate:self];
    [self.tabBarController presentViewController:lNavContoller animated:YES completion:nil];
}

- (PMEventContentVC *)viewControllerAtIndex:(NSUInteger)index {
    PMEventContentVC *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PMEventContentVC"];
    
    PMEventModel *eventModel = _events[index];
    [childViewController setPageIndex:index];
    [childViewController updateWithEvent:eventModel];
    [childViewController setDelegate:self];
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = ((PMEventContentVC*) viewController).pageIndex;
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = ((PMEventContentVC*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    
    index++;
    if (index == self.eventsCount) {
        return nil;
    }
    
    return  [self viewControllerAtIndex:index];
}

-(void)eventContentVCDidAppear:(PMEventContentVC *)contentVC
{
    PMEventModel *eventModel = contentVC.currentEvent;
    
    _currentEvent = eventModel;
    
    [self setNavigationBar];
}


@end
