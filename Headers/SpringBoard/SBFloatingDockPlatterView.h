@class _UIBackdropView;

@interface SBFloatingDockPlatterView : UIView <NRESettingsObserver>
@property (strong, nonatomic) _UIBackdropView *backgroundView;

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end