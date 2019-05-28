#import <PlatterKit/PLTitledPlatterView.h>

@interface WGWidgetPlatterView : PLTitledPlatterView <NRESettingsObserver>
// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end