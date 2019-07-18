#import "NRESettings.h"
#import <ControlCenterUIKit/ControlCenterUIKit.h>
#import <MaterialKit/MaterialKit.h>
#import <PlatterKit/PlatterKit.h>
#import <SpringBoard/SpringBoard+Private.h>
#import <SpringBoardUI/SpringBoardUI.h>
#import <UIKit/UIKit+Private.h>
#import <UserNotificationsUIKit/UserNotificationsUIKit.h>
#import <Widgets/Widgets.h>
#import <HBLog.h>

#pragma mark - Dock

%hook SBDockView

- (instancetype)initWithDockListView:(UIView *)dockListView forSnapshot:(BOOL)snapshot {
    self = %orig;
    if (self) {
        // Register observer
        NRESettings *settings = NRESettings.sharedSettings;
        [settings addObserver:self];

        // Apply tweak
        BOOL enabled = settings.enabled && settings.dock;
        NSInteger style = enabled ? 14 : 12;
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"dock"]) {
        return;
    }

    // Apply theming
    BOOL enabled = settings.enabled && settings.dock;
    NSInteger style = enabled ? 14 : 12;
    SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
    [effectView setStyle:style];
}

%end

#pragma mark - Notifications

%hook NCNotificationOptions

// Its really that easy apparently
- (BOOL)prefersDarkAppearance {
    NRESettings *settings = NRESettings.sharedSettings;
    BOOL enabled = settings.enabled && settings.notifications;
    return enabled || %orig;
}

%end

%hook NCNotificationViewControllerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        // Register observer
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

- (void)_configureStackedPlatters {
    %orig;

    // Update stacked platters
    NSArray<PLPlatterView *> *platterViews = [self valueForKey:@"_stackedPlatters"];
    for (PLPlatterView *platterView in platterViews) {
        // Update recipe
        [platterView updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];

        // Update platter overlay
        MTMaterialView *mainOverlayView = platterView.mainOverlayView;
        [mainOverlayView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay weighting:mainOverlayView.weighting];
    } 
}

%end

%hook NCNotificationLongLookView
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)init {
    self = %orig;
    if (self) {
        // Register observer
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

    // Check if enabled
    NRESettings *settings = NRESettings.sharedSettings;
    BOOL enabled = settings.enabled && settings.notifications;
    if (!enabled) {
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

    // Check if overlay
    if (!self.overlayView) {
        return;
    }

    // Update frames
    MTMaterialView *backgroundView = [self valueForKey:@"_actionsBackgroundView"];
    self.overlayView.frame = backgroundView.frame;
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"notifications"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.notifications;
    MTMaterialView *backgroundView = [self valueForKey:@"_actionsBackgroundView"];
    if (!enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

        [backgroundView transitionToRecipe:MTMaterialRecipeWidgetHosts options:MTMaterialOptionsBlur | MTMaterialOptionsBaseOverlay weighting:backgroundView.weighting];

        [self setNeedsLayout];
        return;
    }

    // Apply theming
    [backgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur weighting:backgroundView.weighting];

    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay];
    self.overlayView.groupName = backgroundView.groupName;
    [self.overlayView _setContinuousCornerRadius:[backgroundView _continuousCornerRadius]];
    [backgroundView.superview insertSubview:self.overlayView aboveSubview:backgroundView];
}

%end

%hook PLGlyphControl

- (instancetype)initWithMaterialRecipe:(MTMaterialRecipe)recipe backgroundMaterialOptions:(MTMaterialOptions)backgroundMaterialOptions overlayMaterialOptions:(MTMaterialOptions)overlayMaterialOptions {
    // Intercept and modify recipe
    NRESettings *settings = NRESettings.sharedSettings;
    BOOL enabled = settings.enabled && settings.notifications;
    recipe = enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeNotifications;
    overlayMaterialOptions = enabled ? MTMaterialOptionsBaseOverlay : MTMaterialOptionsPrimaryOverlay;
    self = %orig(recipe, backgroundMaterialOptions, overlayMaterialOptions);
    if (self) {
        // Register observer
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

- (void)_configureBackgroundMaterialViewIfNecessary {
    %orig;

    // Fix corner radius
    MTMaterialView *backgroundMaterialView = self.backgroundMaterialView;
    backgroundMaterialView.clipsToBounds = YES;
    backgroundMaterialView.layer.cornerRadius = [self _cornerRadius];
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"notifications"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.notifications;
    MTMaterialRecipe recipe = enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeNotifications;
    MTMaterialOptions overlayMaterialOptions = enabled ? MTMaterialOptionsBaseOverlay : MTMaterialOptionsPrimaryOverlay;

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
        // Register observer
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
    BOOL enabled = settings.enabled && settings.widgets;
    if (self.recipe == MTMaterialRecipeNotificationsDark || !enabled) {
        // Dont configure if already configured
        return;
    }

    [self updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];

    UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
    overlayView.hidden = YES;
    self.sashHidden = YES;
}

- (void)updateWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options {
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"widgets"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.widgets;
    if (!enabled) {
        [self updateWithRecipe:MTMaterialRecipeWidgetHosts options:MTMaterialOptionsGamma | MTMaterialOptionsBlur];

        UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
        overlayView.hidden = NO;
        self.sashHidden = NO;

        [self setNeedsLayout];

        return;
    }

    // Update theming
    [self updateWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBlur];

    UIView *overlayView = [self valueForKey:@"_headerOverlayView"];
    overlayView.hidden = YES;
    self.sashHidden = YES;
}

%end

%hook WGShortLookStyleButton
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)init {
    self = %orig;
    if (self) {
        // Register observer
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

    if (self.overlayView) {
        self.overlayView.frame = self.bounds;
    }
}

- (void)_configureBackgroundViewIfNecessary {
    %orig;

    NRESettings *settings = NRESettings.sharedSettings;
    BOOL enabled = settings.enabled && settings.widgets;
    if (!enabled) {
        return;
    }

    // Hide original
    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    backgroundView.hidden = YES;

    if (self.overlayView) {
        return;
    }

    // Create overlay
    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
    [self.overlayView _setCornerRadius:backgroundView.cornerRadius];
    [self addSubview:self.overlayView];
    [self sendSubviewToBack:self.overlayView];
}

- (void)_configureTitleLabelIfNecessary {
    %orig;

    NRESettings *settings = NRESettings.sharedSettings;
    BOOL enabled = settings.enabled && settings.widgets;
    if (!enabled) {
        return;
    }

    // Set proper styling
    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    MTVibrantStyling *styling = [self.overlayView.vibrantStylingProvider vibrantStylingWithStyle:1];
    [titleLabel mt_removeAllVibrantStyling];
    [titleLabel mt_applyVibrantStyling:styling];
}

- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius {
    %orig;

    if (self.overlayView) {
        [self.overlayView _setCornerRadius:cornerRadius];
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"widgets"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.widgets;
    MTMaterialView *backgroundView = [self valueForKey:@"_backgroundView"];
    if (!enabled) {
        // Remove overlay if exists
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

        // Reset view
        backgroundView.hidden = NO;

        UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
        MTVibrantStyling *styling = [backgroundView.vibrantStylingProvider vibrantStylingWithStyle:1];
        [titleLabel mt_removeAllVibrantStyling];
        [titleLabel mt_applyVibrantStyling:styling];

        [self invalidateCachedGeometry];
        return;
    }

    // Hide view
    backgroundView.hidden = YES;

    // Create overlay
    self.overlayView = [%c(MTMaterialView) materialViewWithRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsBaseOverlay | MTMaterialOptionsBlur];
    [self.overlayView _setCornerRadius:backgroundView.cornerRadius];
    [self addSubview:self.overlayView];
    [self sendSubviewToBack:self.overlayView];
    
    // Update label
    UILabel *titleLabel = [self valueForKey:@"_titleLabel"];
    MTVibrantStyling *styling = [backgroundView.vibrantStylingProvider vibrantStylingWithStyle:1];
    [titleLabel mt_removeAllVibrantStyling];
    [titleLabel mt_applyVibrantStyling:styling];

    // Force relayout
    [self invalidateCachedGeometry];
}

%end

#pragma mark - 3D Touch

%hook SBUIIconForceTouchWrapperViewController
%property (retain, nonatomic) MTMaterialView *overlayView;

- (instancetype)initWithChildViewController:(UIViewController *)childViewController {
    self = %orig;
    if (self) {
        // Register observer
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
    BOOL enabled = settings.enabled && settings.forceTouch;
    if (!enabled) {
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

    // Check if overlay
    if (!self.overlayView) {
        return;
    }

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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"3dtouch"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.forceTouch;
    MTMaterialView *backgroundView = [self backgroundMaterialView];
    if (!enabled) {
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

    // Apply theme
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

        BOOL enabled = settings.enabled && settings.controlCenter;
        if (enabled) {
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"controlcenter"]) {
        return;
    }

    // Update theme
    BOOL enabled = settings.enabled && settings.controlCenter;
    MTMaterialView *highlightView = [self valueForKey:@"_highlightedBackgroundView"];
    CGFloat initialAlpha = highlightView.alpha;
    MTMaterialRecipe recipe = enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeControlCenterModules;
    MTMaterialOptions options = enabled ? MTMaterialOptionsSecondaryOverlay : MTMaterialOptionsPrimaryOverlay;
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

        BOOL enabled = settings.enabled && settings.controlCenter;
        if (enabled) {
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"controlcenter"]) {
        return;
    }

    // Update theme
    BOOL enabled = settings.enabled && settings.controlCenter;
    MTMaterialView *backgroundView = [self valueForKey:@"_continuousValueBackgroundView"];
    MTMaterialRecipe recipe = enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeControlCenterModules;
    MTMaterialOptions options = enabled ? MTMaterialOptionsSecondaryOverlay : MTMaterialOptionsPrimaryOverlay;
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

        BOOL enabled = settings.enabled && settings.folders;
        if (enabled) {
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"folders"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.folders;
    if (!enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

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

        BOOL enabled = settings.enabled && settings.folders;
        if (enabled) {
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
    if (![keyPath isEqualToString:@"enabled"] && ![keyPath isEqualToString:@"folders"]) {
        return;
    }

    BOOL enabled = settings.enabled && settings.folders;
    if (!enabled) {
        if (self.overlayView) {
            [self.overlayView removeFromSuperview];
            self.overlayView = nil;
        }

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