@class PLPlatterView;

@interface NCNotificationViewControllerView : UIView <NRESettingsObserver> {
    NSArray<PLPlatterView *> *_stackedPlatters;
}

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end