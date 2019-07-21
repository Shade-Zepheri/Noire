#import "NRERootListController.h"
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
        appearanceSettings.navigationBarBackgroundColor = [UIColor colorWithRed:0.07 green:0.07 blue:0.07 alpha:1.0];
        appearanceSettings.statusBarTintColor = [UIColor whiteColor];
        appearanceSettings.translucentNavigationBar = NO;
        appearanceSettings.tableViewCellSeparatorColor = [UIColor clearColor];

        self.hb_appearanceSettings = appearanceSettings;

        // Navbar icon
        self.titleView = [[NRENavigationTitleView alloc] initWithFrame:CGRectZero];
        self.titleView.icon = [UIImage imageNamed:@"icon" inBundle:self.bundle];
        self.titleView.title = @"Noire";
        self.titleView.subtitle = @"Version: 0.3";
        self.titleView.showingIcon = YES;
        self.navigationItem.titleView = self.titleView;
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
    [self.headerImageView.topAnchor constraintEqualToAnchor:headerContainerView.topAnchor].active = YES;
    [self.headerImageView.leadingAnchor constraintEqualToAnchor:headerContainerView.leadingAnchor].active = YES;
    [self.headerImageView.trailingAnchor constraintEqualToAnchor:headerContainerView.trailingAnchor].active = YES;
    [self.headerImageView.bottomAnchor constraintEqualToAnchor:headerContainerView.bottomAnchor].active = YES;

    self.table.tableHeaderView = headerContainerView;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Get rid of shadow
    self.realNavigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;

    // Update navbar stuffs
    self.titleView.showingIcon = offsetY < 140.0;

    // Update image offset
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
