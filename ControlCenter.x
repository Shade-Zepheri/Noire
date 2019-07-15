#import "NRESettings.h"
#import <Cephei/HBPreferences.h>
#import <ControlCenterUIKit/ControlCenterUIKit.h>
#import <MaterialKit/MaterialKit.h>
#import <HBLog.h>

%group Modules
// These must be in here in order to not hook too early or late;

#pragma mark - Toggle

%hook CCUIDisplayBackgroundViewController
%property (retain, nonatomic) CCUILabeledRoundButtonViewController *noireButton;
%property (retain, nonatomic) NRESettings *settings;

- (void)viewDidLoad {
    %orig;

    // Register for settings changes
    self.settings = NRESettings.sharedSettings;
    [self.settings addObserver:self];

    // Add our button
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/com.shade.noire.bundle"];
    CCUICAPackageDescription *packageDescription = [CCUICAPackageDescription descriptionForPackageNamed:@"StyleMode" inBundle:bundle];
    self.noireButton = [[CCUILabeledRoundButtonViewController alloc] initWithGlyphPackageDescription:packageDescription highlightColor:[UIColor whiteColor] useLightStyle:NO];
    self.noireButton.title = [bundle localizedStringForKey:@"APPEARANCE" value:@"" table:nil];
    self.noireButton.labelsVisible = YES;
    [self.noireButton.button addTarget:self action:@selector(_noireButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.noireButton.view];
}

- (void)dealloc {
    // Unregister observer
    [self.settings removeObserver:self];

    %orig;
}

- (void)_updateState {
    %orig;

    // Set button state
    self.noireButton.enabled = !self.settings.enabled;
    NSString *state = self.settings.enabled ? @"dark" : @"light";
    self.noireButton.glyphState = state;

    NSString *subtitleKey = self.settings.enabled ? @"DARK" : @"LIGHT";
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Application Support/com.shade.noire.bundle"];
    self.noireButton.subtitle = [bundle localizedStringForKey:subtitleKey value:@"" table:nil];
}

- (void)viewWillLayoutSubviews {
    %orig;

    // Update placement and size
    self.noireButton.view.frame = self.nightShiftButton.view.bounds;

    if (self.trueToneButton) {
        // Layout for 3 toggles
    }

    // Layout for 2 toggles
}

%new 
- (void)_noireButtonPressed:(UIControl *)button {
    // Toggle noire
    [self _toggleNoire];
}

%new
- (void)_toggleNoire {
    // Change settings
    BOOL enabled = self.settings.enabled;
    HBPreferences *preferences = [HBPreferences preferencesForIdentifier:@"com.shade.noire"];
    [preferences setBool:!enabled forKey:NREPreferencesEnabledKey];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shade.noire/ReloadPrefs"), NULL, NULL, YES);

    // Update state
    [self _updateState];
}

%new
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    [self _updateState];
}

%end


#pragma mark - Control Center theming

%hook CCUIConnectivityModuleViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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

- (void)viewDidLoad {
    %orig;

    // Check if enabled
    NRESettings *settings = NRESettings.sharedSettings;
    if (!settings.enabled) {
        return;
    }

    // Theme buttons
    for (CCUILabeledRoundButtonViewController *buttonViewController in self.buttonViewControllers) {
        CCUILabeledRoundButton *buttonContainer = buttonViewController.buttonContainer;
        CCUIRoundButton *buttonView = buttonContainer.buttonView;
        MTMaterialView *alternateStateBackgroundView = buttonView.alternateSelectedStateBackgroundView;
        if (!alternateStateBackgroundView) {
            // Nothing to configure
            continue;
        }

        [alternateStateBackgroundView transitionToRecipe:MTMaterialRecipeNotificationsDark options:MTMaterialOptionsSecondaryOverlay weighting:alternateStateBackgroundView.weighting];
    }
}

%new 
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath {
    if (![keyPath isEqualToString:@"enabled"]) {
        return;
    }

    // Update theme
    for (CCUILabeledRoundButtonViewController *buttonViewController in self.buttonViewControllers) {
        CCUILabeledRoundButton *buttonContainer = buttonViewController.buttonContainer;
        CCUIRoundButton *buttonView = buttonContainer.buttonView;
        MTMaterialView *alternateStateBackgroundView = buttonView.alternateSelectedStateBackgroundView;

        MTMaterialRecipe recipe = settings.enabled ? MTMaterialRecipeNotificationsDark : MTMaterialRecipeControlCenterModules;
        MTMaterialOptions options = settings.enabled ? MTMaterialOptionsSecondaryOverlay : MTMaterialOptionsPrimaryOverlay;
        [alternateStateBackgroundView transitionToRecipe:recipe options:options weighting:alternateStateBackgroundView.weighting];
    }
}

%end
%end

#pragma mark - Initializer

%hook CCUIModuleInstanceManager

- (void)_updateModuleInstances {
    %orig;

    // Load hooks when modules are loaded
    %init(Modules);
}

%end

%ctor {
    // Init inital hook
    %init;
}