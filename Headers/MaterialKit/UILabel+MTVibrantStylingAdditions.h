@class MTVibrantStyling;

@interface UILabel (MTVibrantStylingAdditions)

- (void)mt_applyVibrantStyling:(MTVibrantStyling *)styling;
- (void)mt_removeAllVibrantStyling;

@end