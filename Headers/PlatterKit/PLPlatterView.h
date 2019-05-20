#import <MaterialKit/MTMaterialView.h>

@interface PLPlatterView : UIView
@property (readonly, nonatomic) MTMaterialRecipe recipe; 
@property (readonly, nonatomic) MTMaterialOptions options; 
@property (readonly, nonatomic) MTMaterialView *backgroundMaterialView; 
@property (readonly, nonatomic) MTMaterialView *mainOverlayView; 

- (instancetype)initWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options;

- (void)updateWithRecipe:(MTMaterialRecipe)recipe options:(MTMaterialOptions)options;

@end