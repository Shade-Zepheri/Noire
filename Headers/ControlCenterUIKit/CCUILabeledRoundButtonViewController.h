@class CCUICAPackageDescription, CCUILabeledRoundButton;

@interface CCUILabeledRoundButtonViewController : UIViewController
@property (strong, nonatomic) CCUILabeledRoundButton *buttonContainer;
@property (strong, nonatomic) UIControl *button;
@property (strong, nonatomic) CCUICAPackageDescription *glyphPackageDescription;
@property (copy, nonatomic) NSString *glyphState;
@property (copy, nonatomic) NSString *title; 
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) BOOL labelsVisible;
@property (getter=isEnabled, nonatomic) BOOL enabled;

- (instancetype)initWithGlyphPackageDescription:(CCUICAPackageDescription *)packageDescription highlightColor:(UIColor *)highlightColor useLightStyle:(BOOL)useLightStyle;

@end