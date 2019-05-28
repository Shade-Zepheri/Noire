#import "PLPlatterView.h"

@interface PLTitledPlatterView : PLPlatterView {
    UIView *_headerOverlayView;
}

@property (getter=isSashHidden, assign, nonatomic) BOOL sashHidden;

@end