#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MTMaterialRecipe) {
    MTMaterialRecipeNone,
    MTMaterialRecipeNotifications,
    MTMaterialRecipeWidgetHosts,
    MTMaterialRecipeWidgets,
    MTMaterialRecipeControlCenterModules,
    MTMaterialRecipeSwitcherContinuityItem,
    MTMaterialRecipePreviewBackground,
    MTMaterialRecipeNotificationsDark,
    MTMaterialRecipeControlCenterModulesSheer
};

typedef NS_OPTIONS(NSUInteger, MTMaterialOptions) {
    MTMaterialOptionsNone             = 0,
    MTMaterialOptionsGamma            = 1 << 0,
    MTMaterialOptionsBlur             = 1 << 1,
    MTMaterialOptionsZoom             = 1 << 2,
    MTMaterialOptionsLuminanceMap     = 1 << 3,
    MTMaterialOptionsBaseOverlay      = 1 << 4,
    MTMaterialOptionsPrimaryOverlay   = 1 << 5,
    MTMaterialOptionsSecondaryOverlay = 1 << 6,
    MTMaterialOptionsAuxiliaryOverlay = 1 << 7,
    MTMaterialOptionsCaptureOnly      = 1 << 8
};

@class MTVibrantStylingProvider;

@interface MTMaterialView : UIView
@property (weak, readonly, nonatomic) MTVibrantStylingProvider *vibrantStylingProvider; 
@property (assign, nonatomic) CGFloat weighting; 
@property (nonatomic,copy) NSString *groupName;

+ (instancetype)materialViewWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options;

- (CGFloat)cornerRadius;
- (void)_setCornerRadius:(CGFloat)cornerRadius;

- (void)transitionToRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options weighting:(CGFloat)weighting;

@end