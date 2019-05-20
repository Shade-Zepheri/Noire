#import <UIKit/UIKit.h>
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>
#import <Widgets/WGShortLookStyleButton.h>
#import <Widgets/WGWidgetPlatterView.h>

#pragma mark - Dock

%hook SBDockView

- (instancetype)initWithDockListView:(UIView *)dockListView forSnapshot:(BOOL)snapshot {
    self = %orig;
    if (self) {
        SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
        [effectView setStyle:14];
    }

    return self;
}

%end

#pragma mark - Notifications

%hook NCNotificationOptions

- (BOOL)prefersDarkAppearance {
    return YES;
}

%end

#pragma mark - Widgets

%hook WGWidgetPlatterView

- (instancetype)initWithFrame:(CGRect)frame andCornerRadius:(CGFloat)cornerRadius {
    self = %orig;
    if (self) {
        [self updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];
    }

    return self;

}

- (NSUInteger)_optionsForMainOverlay {
    return MTMaterialOptionsBaseOverlay;
}

%end

// Could be simplified to 1 hook, but this result looks better
%hook WGShortLookStyleButton
%property (retain, nonatomic) MTMaterialView *overlayView;

- (void)layoutSubviews {
    %orig;

    self.overlayView.frame = self.bounds;
}

- (void)_configureBackgroundViewIfNecessary {
    %orig;

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    // [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];
    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    if (self.overlayView) {
        return;
    }

    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    [self insertSubview:self.overlayView aboveSubview:backgroundView];
}

- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius {
    %orig;

    [self.overlayView _setCornerRadius:cornerRadius];
}

%end