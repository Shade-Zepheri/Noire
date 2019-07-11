@class MTMaterialView;

@interface SBUIIconForceTouchWrapperViewController : UIViewController <NRESettingsObserver>

// Additions by me
@property (strong, nonatomic) MTMaterialView *overlayView;

- (MTMaterialView *)backgroundMaterialView;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end