#import <MaterialKit/MTMaterialView.h>

@interface WGShortLookStyleButton : UIControl {
    MTMaterialView *_backgroundView;
    UILabel *_titleLabel;
}

@property (strong, nonatomic) MTMaterialView *overlayView; // Added by me

@end