#import <MaterialKit/MTMaterialView.h>

@class MTVibrantStylingProvider;

@interface PLPlatterView : UIView
@property (readonly, nonatomic) MTMaterialRecipe recipe; 
@property (readonly, nonatomic) MTMaterialOptions options; 
@property (readonly, nonatomic) MTMaterialView *backgroundMaterialView; 
@property (readonly, nonatomic) MTMaterialView *mainOverlayView; 
@property (nonatomic,readonly) MTVibrantStylingProvider * vibrantStylingProvider;
@property (assign, nonatomic) CGFloat cornerRadius;

- (instancetype)initWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options;

- (void)updateWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options;

@end