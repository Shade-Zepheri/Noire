#import <UIKit/UIKit.h>

@class NRESettings;

@protocol NRESettingsObserver <NSObject>
@optional

- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end

typedef NS_ENUM(NSUInteger, NREMaterialTheme) {
    NREMaterialThemeColored,
    NREMaterialThemeDark
};

// Settings keys
static NSString *const NREPreferencesEnabledKey = @"enabled";
static NSString *const NREPreferencesMaterialThemeKey = @"darkVariant";

@interface NRESettings : NSObject
@property (class, strong, readonly) NRESettings *sharedSettings;

@property (assign, readonly, nonatomic) BOOL enabled;
@property (getter=isUsingDark, readonly, nonatomic) BOOL usingDark;

@property (strong, readonly, nonatomic) NSHashTable *observers;

- (void)addObserver:(id<NRESettingsObserver>)observer;
- (void)removeObserver:(id<NRESettingsObserver>)observer;

@end