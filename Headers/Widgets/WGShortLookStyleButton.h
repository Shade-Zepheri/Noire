@class MTMaterialView, PLPlatterView;

@interface WGShortLookStyleButton : UIControl <NRESettingsObserver> {
    MTMaterialView *_backgroundView;
    UILabel *_titleLabel;
}

- (void)invalidateCachedGeometry;
- (CGFloat)_dimension;
- (CGFloat)_backgroundViewCornerRadius;
- (void)_setBackgroundViewCornerRadius:(CGFloat)cornerRadius;

// Added by me
@property (strong, nonatomic) PLPlatterView *darkeningView;
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end