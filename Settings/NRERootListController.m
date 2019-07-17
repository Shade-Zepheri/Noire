#include "NRERootListController.h"
#import <CepheiPrefs/HBSupportController.h>
#import <UIKit/UIImage+Private.h>
#import <TechSupport/TSContactViewController.h>

@implementation NRERootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

#pragma mark - UIViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set appearance
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0];
        appearanceSettings.navigationBarTintColor = [UIColor whiteColor];
        appearanceSettings.navigationBarTitleColor = [UIColor redColor];
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0];
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.translucentNavigationBar = NO;
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];

        self.hb_appearanceSettings = appearanceSettings;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create header view
    UIView *headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerImageView.image = [UIImage imageNamed:@"Header" inBundle:self.bundle];
    self.headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerContainerView addSubview:self.headerImageView];

    // Constraint up
    [self.headerImageView.topAnchor constraintEqualToAnchor:headerContainerView.topAnchor];
    [self.headerImageView.leadingAnchor constraintEqualToAnchor:headerContainerView.leadingAnchor];
    [self.headerImageView.trailingAnchor constraintEqualToAnchor:headerContainerView.trailingAnchor];
    [self.headerImageView.bottomAnchor constraintEqualToAnchor:headerContainerView.bottomAnchor];

    self.table.tableHeaderView = headerContainerView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update image offset
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > 0) {
        offsetY = 0;
    }

    self.headerImageView.frame = CGRectMake(0, offsetY, CGRectGetWidth(self.table.bounds), 200 - offsetY);
}

#pragma mark - Support

- (void)showSupportEmailController {
    TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.shade.noire"];
    [self.navigationController pushViewController:supportController animated:YES];
}

@end
