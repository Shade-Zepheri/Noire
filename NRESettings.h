#import <UIKit/UIKit.h>

@class NRESettings;

@protocol NRESettingsObserver <NSObject>
@optional

- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end

// Settings keys
static NSString *const NREPreferencesEnabledKey = @"enabled";

@interface NRESettings : NSObject
@property (class, strong, readonly) NRESettings *sharedSettings;
@property (strong, readonly, nonatomic) NSHashTable *observers;

@property (assign, readonly, nonatomic) BOOL enabled;

- (void)addObserver:(id<NRESettingsObserver>)observer;
- (void)removeObserver:(id<NRESettingsObserver>)observer;

@end