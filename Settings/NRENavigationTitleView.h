#import <UIKit/UIKit.h>

@interface NRENavigationTitleView : UIView
@property (getter=isShowingIcon, nonatomic) BOOL showingIcon;
@property (strong, nonatomic) UIImage *icon;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

@end