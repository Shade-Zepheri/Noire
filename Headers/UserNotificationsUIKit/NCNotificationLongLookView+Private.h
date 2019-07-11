#import <PlatterKit/PLExpandedPlatterView.h>

@interface NCNotificationLongLookView : PLExpandedPlatterView <NRESettingsObserver>
@property (strong, nonatomic) MTMaterialView *overlayView; // Added by me

// Also added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end