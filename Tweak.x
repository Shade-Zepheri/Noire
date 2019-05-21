#import "NRESettings.h"
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>
#import <Widgets/WGShortLookStyleButton.h>
#import <Widgets/WGWidgetPlatterView.h>

#pragma mark - Dock

%hook SBDockView

- (instancetype)initWithDockListView:(UIView *)dockListView forSnapshot:(BOOL)snapshot {
    self = %orig;
    if (self) {
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        NSInteger style = settings.enabled ? 14 : 12;
        SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
        [effectView setStyle:style];
    }

    return self;
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    NSInteger style = settings.enabled ? 14 : 12;
    SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
    [effectView setStyle:style];
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

%hook WGShortLookStyleButton
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)init {
    self = %orig;
    if (self) {
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];
    }

    return self;
}

- (void)layoutSubviews {
    %orig;

    if (self.overlayView) {
        self.overlayView.frame = self.bounds;
    }
}

- (void)_configureBackgroundViewIfNecessary {
    %orig;

    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    if (settings.usingDark) {
        [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];
    } else {
        if (self.overlayView) {
            return;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

        self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
        [self insertSubview:self.overlayView aboveSubview:backgroundView];
    }
}

- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius {
    %orig;

    if (self.overlayView) {
        [self.overlayView _setCornerRadius:cornerRadius];
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (!settings.enabled && ![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    if (!settings.enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeNotifications options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];
        [self setNeedsLayout];
        return;
    }

    if (settings.usingDark) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }
        
        [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];
    } else {
        if (self.overlayView) {
            return;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

        self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
        [self insertSubview:self.overlayView aboveSubview:backgroundView];
    }

    [self setNeedsLayout];
}

%end