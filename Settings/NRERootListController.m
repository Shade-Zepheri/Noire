#include "NRERootListController.h"
#import <CepheiPrefs/HBSupportController.h>
#import <TechSupport/TSContactViewController.h>

@implementation NRERootListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
    return @"Root";
}

#pragma mark - Support

- (void)showSupportEmailController {
    TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:@"com.shade.noire"];
    [self.navigationController pushViewController:supportController animated:YES];
}

@end
