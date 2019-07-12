@class MTMaterialView, SBUIActionView;

@interface SBUIIconForceTouchWrapperViewController : UIViewController <NRESettingsObserver>
@property (readonly, nonatomic) UIViewController *childViewController;

// Additions by me
@property (strong, nonatomic) MTMaterialView *overlayView;

- (MTMaterialView *)backgroundMaterialView;
- (NSArray<SBUIActionView *> *)actionViews;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end