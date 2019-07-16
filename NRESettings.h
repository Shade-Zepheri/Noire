#import <UIKit/UIKit.h>

@class NRESettings;

@protocol NRESettingsObserver <NSObject>
@optional

- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end

// Settings keys
static NSString *const NREPreferencesEnabledKey = @"enabled";

static NSString *const NREPreferences3DTouchKey = @"3dtouch";
static NSString *const NREPreferencesControlCenterKey = @"controlcenter";
static NSString *const NREPreferencesDockKey = @"dock";
static NSString *const NREPreferencesFoldersKey = @"folders";
static NSString *const NREPreferencesNotificationsKey = @"notifications";
static NSString *const NREPreferencesWidgetsKey = @"widgets";

@interface NRESettings : NSObject
@property (class, strong, readonly) NRESettings *sharedSettings;
@property (strong, readonly, nonatomic) NSHashTable *observers;

@property (assign, readonly, nonatomic) BOOL enabled;

@property (assign, readonly, nonatomic) BOOL forceTouch;
@property (assign, readonly, nonatomic) BOOL controlCenter;
@property (assign, readonly, nonatomic) BOOL dock;
@property (assign, readonly, nonatomic) BOOL folders;
@property (assign, readonly, nonatomic) BOOL notifications;
@property (assign, readonly, nonatomic) BOOL widgets;

- (void)addObserver:(id<NRESettingsObserver>)observer;
- (void)removeObserver:(id<NRESettingsObserver>)observer;

@end