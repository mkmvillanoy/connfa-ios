//
//  DCprogramViewController.m
//  DrupalCon
//
//  Created by Rostyslav Stepanyak on 7/28/14.
//  Copyright (c) 2014 Lemberg Solution. All rights reserved.
//

#import "DCProgramViewController.h"
#import "DCProgramItemsViewController.h"
#import "DCMainProxy+Additions.h"
#import "NSDate+DC.h"

@interface DCProgramViewController ()
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) NSArray *dates;

@property (nonatomic) int currentIndex;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@end

@implementation DCProgramViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _dates = [[NSArray alloc] initWithArray:[[DCMainProxy sharedProxy] days]];
    [self addPageController];
}

-(void) addPageController {
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    DCProgramItemsViewController *programItemsViewController = [self viewControllerAtIndex:0];
    
    self.viewControllers = [[NSArray alloc] initWithObjects: programItemsViewController, nil];
    [self.pageViewController setViewControllers:self.viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.delegate = self;
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0,  30, self.view.frame.size.width, self.view.frame.size.height - (30));
    [self addChildViewController: _pageViewController];
    [self.view addSubview: _pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    [self displayDateForDay: 0];
}

-(void) displayDateForDay: (int) day {
    NSDate * date = _dates[day];
    self.dateLabel.text = [date pageViewDateString];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if(completed){
       NSUInteger currentIndex = [[self.pageViewController.viewControllers lastObject] pageIndex];
        self.currentIndex = currentIndex;
        [self displayDateForDay: self.currentIndex];
    }
}


-(IBAction) previousDayClicked:(id)sender
{
    if(self.currentIndex == 0)
        return;
    
    NSMutableArray *arrayOfViewController = [[NSMutableArray alloc] init];
    
    for(int i = _dates.count-1; i >= 0; i--) {
        if(i < self.currentIndex) {
            [arrayOfViewController addObject: [self viewControllerAtIndex:i]];
            break;
        }
    }
    self.currentIndex -= 1;
    [self displayDateForDay: self.currentIndex];

    [self.pageViewController setViewControllers: arrayOfViewController direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
}


-(IBAction) nextDayClicked:(id)sender
{
    if(self.currentIndex >= _dates.count-1)
        return;
    
    NSMutableArray *arrayOfViewController = [[NSMutableArray alloc] init];
    for(int i = 0; i < _dates.count; i++) {
        if(i > self.currentIndex) {
            [arrayOfViewController addObject: [self viewControllerAtIndex:i]];
            break;
        }

    }
    self.currentIndex += 1;
    [self displayDateForDay: self.currentIndex];
    [self.pageViewController setViewControllers: arrayOfViewController direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}

#pragma mark page view delegate and datasource
- (DCProgramItemsViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((_dates.count == 0) || (index >= _dates.count)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    DCProgramItemsViewController *programItemsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgramItemsViewController"];
    programItemsViewController.pageIndex = index;
    return programItemsViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
     NSUInteger index = ((DCProgramItemsViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((DCProgramItemsViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == _dates.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return _dates.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end