@interface SBFolderIconImageView : UIView <NRESettingsObserver> {
    UIView *_backgroundView;
}

// Added by me
@property (strong, nonatomic) MTMaterialView *overlayView;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end