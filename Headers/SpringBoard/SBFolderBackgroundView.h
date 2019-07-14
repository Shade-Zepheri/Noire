@interface SBFolderBackgroundView : UIView <NRESettingsObserver> {
    UIView *_tintView;
}

// Added by me
@property (strong, nonatomic) MTMaterialView *overlayView;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end