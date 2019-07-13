@class CCUILabeledRoundButtonViewController, NRESettings;

@interface CCUIDisplayBackgroundViewController : UIViewController <NRESettingsObserver>
@property (strong, nonatomic) CCUILabeledRoundButtonViewController *nightShiftButton;
@property (strong, nonatomic) CCUILabeledRoundButtonViewController *trueToneButton;

- (void)_updateState;

// Added by me
@property (strong, nonatomic) CCUILabeledRoundButtonViewController *noireButton;
@property (strong, nonatomic) NRESettings *settings;

- (void)_noireButtonPressed:(UIControl *)button;
- (void)_toggleNoire;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end