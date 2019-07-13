@class MTMaterialView;

@interface CCUIModuleSliderView : UIControl <NRESettingsObserver> {
    MTMaterialView *_continuousValueBackgroundView;
}

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end