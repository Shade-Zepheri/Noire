@class SBWallpaperEffectView;

@interface SBDockView : UIView <NRESettingsObserver> {
	SBWallpaperEffectView *_backgroundView;
}

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end