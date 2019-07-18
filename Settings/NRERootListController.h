#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import "NRENavigationTitleView.h"

@interface NRERootListController : HBRootListController
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) NRENavigationTitleView *titleView;

@end
