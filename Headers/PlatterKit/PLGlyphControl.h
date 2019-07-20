@class MTMaterialView;

@interface PLGlyphControl : UIControl <NRESettingsObserver>
@property (getter=_backgroundMaterialView, strong, nonatomic) MTMaterialView *backgroundMaterialView; 
@property (getter=_overlayMaterialView, strong, nonatomic) MTMaterialView *overlayMaterialView;
@property (copy, nonatomic) NSString *groupName; 
@property (readonly, nonatomic) MTMaterialRecipe materialRecipe;
@property (readonly, nonatomic) MTMaterialOptions backgroundMaterialOptions;
@property (readonly, nonatomic) MTMaterialOptions overlayMaterialOptions;

- (instancetype)initWithMaterialRecipe:(MTMaterialRecipe)recipe backgroundMaterialOptions:(MTMaterialOptions)backgroundMaterialOptions overlayMaterialOptions:(MTMaterialOptions)overlayMaterialOptions;

- (void)_updateGlyphViewVibrantStyling;
- (void)_configureMaterialView:(MTMaterialView **)materialView ifNecessaryWithOptions:(MTMaterialOptions)options positioningAtIndex:(NSUInteger)index;
- (CGFloat)_cornerRadius;

// Also added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end