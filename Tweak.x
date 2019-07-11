#import "NRESettings.h"
#import <MaterialKit/MTVibrantStyling.h>
#import <MaterialKit/MTVibrantStylingProvider.h>
#import <MaterialKit/UILabel+MTVibrantStylingAdditions.h>
#import <PlatterKit/PLGlyphControl.h>
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>
#import <UserNotificationsUIKit/NCNotificationLongLookView+Private.h>
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

%hook NCNotificationLongLookView
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)init {
    self = %orig;
    if (self) {
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];
    }

    return self;
}

- (void)_configureActionsBackgroundViewIfNecessaryWithActions:(NSArray *)actions {
    %orig;

    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    // Update color
    MTMaterialView *backgroundView = [self valueForKey:@"_actionsBackgroundView"];
    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    self.overlayView.groupName = backgroundView.groupName;
    [self.overlayView _setContinuousCornerRadius:[backgroundView _continuousCornerRadius]];
    [backgroundView.superview insertSubview:self.overlayView aboveSubview:backgroundView];
}

- (void)_layoutActionsView {
    %orig;

    // Update frames
    MTMaterialView *backgroundView = [self valueForKey:@"_actionsBackgroundView"];
    self.overlayView.frame = backgroundView.frame;
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    MTMaterialView *backgroundView = [self valueForKey:@"_actionsBackgroundView"];
    if (!settings.enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeWidgetHosts options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];

        [self setNeedsLayout];
        return;
    }

    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    self.overlayView.groupName = backgroundView.groupName;
    [self.overlayView _setContinuousCornerRadius:[backgroundView _continuousCornerRadius]];
    [backgroundView.superview insertSubview:self.overlayView aboveSubview:backgroundView];
}

%end

%hook PLGlyphControl

- (instancetype)initWithMaterialRecipe:(MTMaterialRecipe)recipe backgroundMaterialOptions:(MTMaterialOptions)backgroundMaterialOptions overlayMaterialOptions:(MTMaterialOptions)overlayMaterialOptions {
    self = %orig;
    if (self) {
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        if (settings.enabled) {
            // Update ivars with darkmode values
            [self setValue:@(MTMaterialRecipeNotificationsDark) forKey:@"_materialRecipe"];
            [self setValue:@(MTMaterialOptionsBaseOverlay) forKey:@"_overlayMaterialOptions"];
        }
    }

    return self;
}

- (void)_configureBackgroundMaterialViewIfNecessary {
    %orig;

    // Fix corner radius
    MTMaterialView *backgroundMaterialView = self.backgroundMaterialView;
    backgroundMaterialView.clipsToBounds = YES;
    backgroundMaterialView.layer.cornerRadius = [self _cornerRadius];
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (!settings.enabled && ![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    MTMaterialRecipe recipe = settings.enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeNotifications;
    MTMaterialOptions overlayMaterialOptions = settings.enabled ? MTMaterialOptionsBaseOverlay : MTMaterialOptionsPrimaryOverlay;

    // Update ivars with values
    [self setValue:@(recipe) forKey:@"_materialRecipe"];
    [self setValue:@(overlayMaterialOptions) forKey:@"_overlayMaterialOptions"];

    [self setNeedsLayout];
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
}

- (void)_configureTitleLabelIfNecessary {
    %orig;

    // Set proper styling
    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    [titleLabel mt_removeAllVibrantStyling];
    MTVibrantStyling *styling = [self.darkeningView.vibrantStylingProvider vibrantStylingWithStyle:1];
    [titleLabel mt_applyVibrantStyling:styling];
    [self.darkeningView.customContentView addSubview:titleLabel];
}

- (CGFloat)_backgroundViewCornerRadius {
    // Set so checks platterview so it can be properly set

    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    // return (!self.darkeningView) ? backgroundView.cornerRadius : self.darkeningView.cornerRadius;
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
    [self.darkeningView.customContentView addSubview:titleLabel];

    [self setNeedsLayout];
}

%end