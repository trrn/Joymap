//
//  PageViewController.m
//  Joymap
//
//  Created by gli on 2013/10/26.
//  Copyright (c) 2013年 sekken. All rights reserved.
//

#import "PageViewController.h"

#import "LayoutViewController.h"
#import "Layout.h"
#import "Pin.h"
#import "RouteViewController.h"
#import "TabBarController.h"

#import <UIView+AutoLayout.h>

@interface PageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@end

@implementation PageViewController {
    UIPageViewController *pageViewController_;
}

#pragma mark - Managing the detail item

- (void)setPin:(Pin *)newPin
{
    if (_pin != newPin) {
        _pin = newPin;
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.pin) {
        self.title = self.pin.name;
        _pageControl.numberOfPages = self.pin.layouts.count;
        LayoutViewController *vc = [self viewControllerAtIndex:0];
        if (vc) {
            [pageViewController_ setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    pageViewController_ = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageViewController_.delegate = self;
    pageViewController_.dataSource = self;

    [self configureView];

    [self addChildViewController:pageViewController_];
    [self.view addSubview:pageViewController_.view];

    [pageViewController_ didMoveToParentViewController:self];
    self.view.gestureRecognizers = pageViewController_.gestureRecognizers;
    
    [self.view bringSubviewToFront:self.pageControl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // when back button tapped
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
        [self close];
    }
}

- (void)close
{
    for (LayoutViewController *vc in pageViewController_.viewControllers) {
        [vc pageClosed];  // stop sound, movie
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    DLog();
}

#pragma mark - Page View Controller Data Source

- (LayoutViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((self.pin.layouts.count == 0) || (index >= self.pin.layouts.count)) {
        return nil;
    }

    Layout *layout = self.pin.layouts[index];

    NSString *iD = [NSString stringWithFormat:@"Layout%02d", layout.kind];
    LayoutViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:iD];
    vc.page = index;
    [vc setLayout:layout];

    return vc;
}

- (NSUInteger)indexOfViewController:(LayoutViewController *)viewController
{
    return [self.pin.layouts indexOfObject:viewController.layout];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(LayoutViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }

    --index;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self indexOfViewController:(LayoutViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    ++index;
    if (index >= self.pin.layouts.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed) {
        return;
    }
    self.pageControl.currentPage = [self indexOfViewController:viewController.viewControllers[0]];
    
    if (previousViewControllers[0]) {
        LayoutViewController *vc = previousViewControllers[0];
        [vc pageClosed];
    }
}

- (IBAction)selectAction:(id)sender {
    UIActionSheet *sheet = UIActionSheet.new;
    sheet.delegate = self;
    [sheet addButtonWithTitle:NSLocalizedString(@"Map", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Route", nil)];
    [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            /*
             * somehow, viewWillDisappear is not called.
             * so we call [self close] manually
             */
            [self close];
            TabBarController *tvc = (TabBarController *)self.tabBarController;
            [self.navigationController popViewControllerAnimated:NO];
            [tvc selectPin:_pin];
            break;
        }
        case 1: {
            NavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"RouteNavi"];
            RouteViewController *rvc = (RouteViewController *)nvc.topViewController;
            rvc.to = _pin;
            [self presentViewController:nvc animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
