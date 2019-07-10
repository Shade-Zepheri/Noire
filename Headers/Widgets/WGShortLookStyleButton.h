@class MTMaterialView, PLPlatterView;

@interface WGShortLookStyleButton : UIControl <NRESettingsObserver> {
    MTMaterialView *_backgroundView;
    UILabel *_titleLabel;
}

@property (strong, nonatomic) PLPlatterView *darkeningView; // Added by me

- (CGFloat)_dimension;
- (CGFloat)_backgroundViewCornerRadius;
- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius;

// Also added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end