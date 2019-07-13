@class CCUILabeledRoundButtonViewController;

@interface CCUIConnectivityModuleViewController : UIViewController <NRESettingsObserver>
@property (copy, nonatomic) NSArray<CCUILabeledRoundButtonViewController *> *buttonViewControllers;

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end