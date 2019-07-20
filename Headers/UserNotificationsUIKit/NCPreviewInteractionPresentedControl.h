@class MTMaterialView, NCPreviewInteractionPresentedContentView;

@interface NCPreviewInteractionPresentedControl : UIControl <NRESettingsObserver>
@property (getter=_contentView, readonly, nonatomic) NCPreviewInteractionPresentedContentView *contentView;
@property (getter=_backgroundMaterialView, readonly, nonatomic) MTMaterialView *backgroundMaterialView;
@property (getter=_overlayMaterialView, readonly, nonatomic) MTMaterialView *overlayMaterialView;

- (void)_configureMaterialViewsIfNecessary;

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end