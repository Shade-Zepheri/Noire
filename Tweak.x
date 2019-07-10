#import "NRESettings.h"
#import <MaterialKit/MTVibrantStyling.h>
#import <MaterialKit/MTVibrantStylingProvider.h>
#import <MaterialKit/UILabel+MTVibrantStylingAdditions.h>
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>
#import <Widgets/WGShortLookStyleButton.h>
#import <Widgets/WGWidgetPlatterView.h>
#import <HBLog.h>

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
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];
    }

    return self;
}


- (void)layoutSubviews {
    %orig;
    
    NRESettings *settings = NRESettings.sharedSettings;
    if (self.recipe == MTMaterialRecipeNotificationsDark || !settings.enabled) {
        // Dont configure if already configured
        return;
    }

        [self updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];            

    UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
    overlayView.hidden = YES;
    self.sashHidden = YES;
}

- (void)updateWithRecipe:(NSInteger)recipe options:(NSUInteger)options {
    // Bug: Apple doesn't recalculate the content view frame when updating the recipe
    // The content view assumes an incorrect frame
    [self setValue:@(NO) forKey:@"_didSetInitialCustomContentViewFrame"];

    %orig;
}

- (NSUInteger)_optionsForMainOverlay {
    // Since Apples imp appears to be broke
    return (self.recipe == MTMaterialRecipeNotificationsDark) ? MTMaterialOptionsBaseOverlay : MTMaterialOptionsPrimaryOverlay;
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (!settings.enabled && ![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    if (!settings.enabled) {
        [self updateWithRecipe:MTMaterialRecipeWidgetHosts options:MTMaterialOptionsGamma | MTMaterialOptionsBlur];

        UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
        overlayView.hidden = NO;
        self.sashHidden = NO;
        
        [self setNeedsLayout];

        return;
    }

        [self updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];

    UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
    overlayView.hidden = YES;
    self.sashHidden = YES;
}

%end

%hook WGShortLookStyleButton
%property (retain, nonatomic) PLPlatterView *darkeningView;

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

    if (self.darkeningView) {
        self.darkeningView.frame = self.bounds;
    }
}

- (void)_configureBackgroundViewIfNecessary {
    %orig;

    // Configure platterview
    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    // Set actual view hidden
    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    backgroundView.hidden = YES;

    if (self.darkeningView) {
            return;
        }

    self.darkeningView = [[%c(PLPlatterView) alloc] initWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];
    self.darkeningView.cornerRadius = [self _backgroundViewCornerRadius];
    [self addSubview:self.darkeningView];

    // Update overlay
    MTMaterialView *overlayView = self.darkeningView.mainOverlayView;
    [overlayView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];

    // Update label
    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    [titleLabel mt_removeAllVibrantStyling];
    MTVibrantStyling *styling = [self.darkeningView.vibrantStylingProvider vibrantStylingWithStyle:1];
    [titleLabel mt_applyVibrantStyling:styling];
    [self.darkeningView addSubview:titleLabel];
}

- (CGFloat)_backgroundViewCornerRadius {
    // Bug: Always returns 0 despite what reversing suggest
    // Manually implement what should happen

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    return backgroundView.cornerRadius;
}

- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius {
    %orig;

    if (self.darkeningView) {
        self.darkeningView.cornerRadius = cornerRadius;
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (!settings.enabled && ![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    if (!settings.enabled) {
        if (self.darkeningView) {
            [self.darkeningView removeFromSuperview];
            self.darkeningView = nil;
        }

        backgroundView.hidden = NO;

        // Update label styling
        UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
        [titleLabel mt_removeAllVibrantStyling];
        MTVibrantStyling *styling = [backgroundView.vibrantStylingProvider vibrantStylingWithStyle:1];
        [titleLabel mt_applyVibrantStyling:styling];
        [backgroundView addSubview:titleLabel];

        [self setNeedsLayout];
        return;
    }

    if (self.darkeningView) {
            return;
        }

    self.darkeningView = [[%c(PLPlatterView) alloc] initWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];
    self.darkeningView.cornerRadius = [self _backgroundViewCornerRadius];
    [self addSubview:self.darkeningView];

    MTMaterialView *overlayView = self.darkeningView.mainOverlayView;
    [overlayView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];

    // Update label styling
    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    [titleLabel mt_removeAllVibrantStyling];
    MTVibrantStyling *styling = [self.darkeningView.vibrantStylingProvider vibrantStylingWithStyle:1];
    [titleLabel mt_applyVibrantStyling:styling];
    [self.darkeningView addSubview:titleLabel];

    [self setNeedsLayout];
}

%end