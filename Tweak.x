#import "NRESettings.h"
#import <ControlCenterUIKit/ControlCenterUIKit.h>
#import <MaterialKit/MaterialKit.h>
#import <PlatterKit/PlatterKit.h>
#import <SpringBoard/SpringBoard+Private.h>
#import <SpringBoardUI/SpringBoardUI.h>
#import <UIKit/UIKit+Private.h>
#import <UserNotificationsUIKit/NCNotificationLongLookView+Private.h>
#import <Widgets/Widgets.h>
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

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
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

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
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

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
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

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
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

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
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

#pragma mark - 3D Touch

%hook SBUIIconForceTouchWrapperViewController
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)initWithChildViewController:(UIViewController *)childViewController {
    self = %orig;
    if (self) {
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];
    }

    return self;
}

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
}

- (void)loadView {
    %orig;

    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    // Get and update background view
    MTMaterialView *backgroundView = [self backgroundMaterialView];
    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    // Create overlay
    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    self.overlayView.groupName = backgroundView.groupName;
    [backgroundView.superview insertSubview:self.overlayView aboveSubview:backgroundView];

    // Theme labels
    for (SBUIActionView *actionView in [self actionViews]) {
        // Theme icon
        UIImageView *imageView = [actionView valueForKey:@"_imageView"];
        imageView.hidden = YES;
        UIImageView *legibilityImageView = [actionView valueForKey:@"_legibilityTreatedImageView"];
        legibilityImageView.opaque = YES;
        legibilityImageView.tintColor = [UIColor whiteColor];

        // Get each action and theme label
        SBUIActionViewLabel *titleLabel = [actionView valueForKey:@"_titleLabel"];
        titleLabel.hidden = YES;
        SBUIActionViewLabel *legibilityTitleLabel = [actionView valueForKey:@"_legibilityTreatedTitleLabel"];
        legibilityTitleLabel.textColor = [UIColor whiteColor];

        SBUIActionViewLabel *subtitleLabel = [actionView valueForKey:@"_subtitleLabel"];
        if (subtitleLabel) {
            // Theme subtitle
            subtitleLabel.hidden = YES;
            SBUIActionViewLabel *legibilitySubtitleLabel = [actionView valueForKey:@"_legibilityTreatedSubtitleLabel"];
            legibilitySubtitleLabel.textColor = [UIColor whiteColor];
        }
    }
}

- (void)viewDidLayoutSubviews {
    %orig;

    // Update frame
    MTMaterialView *backgroundView = [self backgroundMaterialView];
    self.overlayView.frame = backgroundView.bounds;
}

%new
- (NSArray<SBUIActionView *> *)actionViews {
    SBUIAppIconForceTouchShortcutViewController *shortcutViewController = (SBUIAppIconForceTouchShortcutViewController *)self.childViewController;
    SBUIActionPlatterViewController *actionViewController = [shortcutViewController valueForKey:@"_actionPlatterViewController"];
    UIStackView *stackView = [actionViewController valueForKey:@"_stackView"];
    return stackView.arrangedSubviews;
}

%new
- (MTMaterialView *)backgroundMaterialView {
    MTMaterialView *backgroundView;
    for (UIView *view in self.view.subviews) {
        if (![view isKindOfClass:%c(MTMaterialView)]) {
            continue;
        }

        backgroundView = (MTMaterialView *)view;
        break;
    }

    return backgroundView;
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    MTMaterialView *backgroundView = [self backgroundMaterialView];
    if (!settings.enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeWidgetHosts options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];

        for (SBUIActionView *actionView in [self actionViews]) {
            // Theme icon
            UIImageView *imageView = [actionView valueForKey:@"_imageView"];
            imageView.hidden = NO;
            UIImageView *legibilityImageView = [actionView valueForKey:@"_legibilityTreatedImageView"];
            legibilityImageView.opaque = NO;
            legibilityImageView.tintColor = [UIColor blackColor];

            // Get each action and theme label
            SBUIActionViewLabel *titleLabel = [actionView valueForKey:@"_titleLabel"];
            titleLabel.hidden = NO;
            SBUIActionViewLabel *legibilityTitleLabel = [actionView valueForKey:@"_legibilityTreatedTitleLabel"];
            legibilityTitleLabel.textColor = [UIColor blackColor];

            SBUIActionViewLabel *subtitleLabel = [actionView valueForKey:@"_subtitleLabel"];
            if (subtitleLabel) {
                // Theme subtitle
                subtitleLabel.hidden = NO;
                SBUIActionViewLabel *legibilitySubtitleLabel = [actionView valueForKey:@"_legibilityTreatedSubtitleLabel"];
                legibilitySubtitleLabel.textColor = [UIColor blackColor];
            }
        }

        [self.view setNeedsLayout];
        return;
    }

    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    self.overlayView.frame = backgroundView.bounds;
    self.overlayView.groupName = backgroundView.groupName;
    [backgroundView.superview insertSubview:self.overlayView aboveSubview:backgroundView];

    for (SBUIActionView *actionView in [self actionViews]) {
        // Theme icon
        UIImageView *imageView = [actionView valueForKey:@"_imageView"];
        imageView.hidden = YES;
        UIImageView *legibilityImageView = [actionView valueForKey:@"_legibilityTreatedImageView"];
        legibilityImageView.opaque = YES;
        legibilityImageView.tintColor = [UIColor whiteColor];

        // Get each action and theme label
        SBUIActionViewLabel *titleLabel = [actionView valueForKey:@"_titleLabel"];
        titleLabel.hidden = YES;
        SBUIActionViewLabel *legibilityTitleLabel = [actionView valueForKey:@"_legibilityTreatedTitleLabel"];
        legibilityTitleLabel.textColor = [UIColor whiteColor];

        SBUIActionViewLabel *subtitleLabel = [actionView valueForKey:@"_subtitleLabel"];
        if (subtitleLabel) {
            // Theme subtitle
            subtitleLabel.hidden = YES;
            SBUIActionViewLabel *legibilitySubtitleLabel = [actionView valueForKey:@"_legibilityTreatedSubtitleLabel"];
            legibilitySubtitleLabel.textColor = [UIColor whiteColor];
        }
    }
}

%end

#pragma mark - Control Center

// Theme light overlay
%hook CCUIButtonModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // Register observer
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        if (settings.enabled) {
            // Theme overlay
            MTMaterialView *highlightView = [self valueForKey:@"_highlightedBackgroundView"];
            CGFloat initialAlpha = highlightView.alpha;
            [highlightView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsSecondaryOverlay weighting:highlightView.weighting];

            // Fix for improper theming
            highlightView.alpha = initialAlpha;
        }
    } 

    return self;
}

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    // Update theme
    MTMaterialView *highlightView = [self valueForKey:@"_highlightedBackgroundView"];
    CGFloat initialAlpha = highlightView.alpha;
    MTMaterialRecipe recipe = settings.enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeControlCenterModules;
    MTMaterialOptions options = settings.enabled ? MTMaterialOptionsSecondaryOverlay : MTMaterialOptionsPrimaryOverlay;
    [highlightView transitionToRecipe:recipe options:options weighting:highlightView.weighting];

    // Fix alpha
    highlightView.alpha = initialAlpha;

    [self setNeedsLayout];
}

%end

%hook CCUIModuleSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // Register observer
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        if (settings.enabled) {
            // Theme overlay
            MTMaterialView *backgroundView = [self valueForKey:@"_continuousValueBackgroundView"];
            [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsSecondaryOverlay weighting:backgroundView.weighting];
        }
    } 

    return self;
}

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    // Update theme
    MTMaterialView *backgroundView = [self valueForKey:@"_continuousValueBackgroundView"];
    MTMaterialRecipe recipe = settings.enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeControlCenterModules;
    MTMaterialOptions options = settings.enabled ? MTMaterialOptionsSecondaryOverlay : MTMaterialOptionsPrimaryOverlay;
    [backgroundView transitionToRecipe:recipe options:options weighting:backgroundView.weighting];

    [self setNeedsLayout];
}

%end

#pragma mark - Folders

%hook SBFolderBackgroundView
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // Register observer
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        if (settings.enabled) {
            // Can create here because calling orig stack
            self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
            [self addSubview:self.overlayView];

            // Hide orig tint view
            UIView *tintView = [self valueForKey:@"_tintView"];
            tintView.hidden = YES;
        }
    } 

    return self;
}

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
}

- (void)layoutSubviews {
    %orig;

    if (self.overlayView) {
        UIView *tintView = [self valueForKey:@"_tintView"];
        self.overlayView.frame = tintView.bounds;
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    if (!settings.enabled) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;

        // Reshow tint
        UIView *tintView = [self valueForKey:@"_tintView"];
        tintView.hidden = NO;

        return;
    }

    // Create overlay
    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
    [self addSubview:self.overlayView];

    // Hide tint
    UIView *tintView = [self valueForKey:@"_tintView"];
    tintView.hidden = YES;

    [self setNeedsLayout];
}

%end

%hook SBFolderIconImageView
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // Register observer
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        if (settings.enabled) {
            // Hide orig tint view
            UIView *backgroundView = [self valueForKey:@"_backgroundView"];
            backgroundView.hidden = YES;

            // Can create here because calling orig stack
            self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
            [self.overlayView _setCornerRadius:backgroundView.layer.cornerRadius];
            [self addSubview:self.overlayView];
            [self sendSubviewToBack:self.overlayView];

        }
    } 

    return self;
}

- (void)dealloc {
    // Unregister observer
    NRESettings *settings = NRESettings.sharedSettings;
    [settings removeObserver:self];

    %orig;
}

- (void)layoutSubviews {
    %orig;

    if (self.overlayView) {
        UIView *backgroundView = [self valueForKey:@"_backgroundView"];
        self.overlayView.frame = backgroundView.bounds;
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    if (!settings.enabled) {
        [self.overlayView removeFromSuperview];
        self.overlayView = nil;

        // Reshow tint
        UIView *backgroundView = [self valueForKey:@"_backgroundView"];
        backgroundView.hidden = NO;

        return;
    }

    // Hide tint
    UIView *backgroundView = [self valueForKey:@"_backgroundView"];
    backgroundView.hidden = YES;

    // Create overlay
    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
    [self.overlayView _setCornerRadius:backgroundView.layer.cornerRadius];
    [self addSubview:self.overlayView];
    [self sendSubviewToBack:self.overlayView];

    [self setNeedsLayout];
}

%end