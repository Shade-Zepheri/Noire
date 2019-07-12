@interface SBUIActionViewLabel : UIView {
    UILabel *_label;
}

@property (strong, nonatomic) UIColor *textColor;

- (void)mt_applyVibrantStyling:(MTVibrantStyling *)styling;
- (void)mt_removeAllVibrantStyling;

@end