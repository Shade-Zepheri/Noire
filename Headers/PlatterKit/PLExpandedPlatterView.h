@class MTMaterialView, PLInterfaceActionGroupView;

@interface PLExpandedPlatterView : UIView {
    MTMaterialView *_actionsBackgroundView;
    PLInterfaceActionGroupView *_actionsView;
}

@property (getter=_headerContentView, readonly, nonatomic) UIView *headerContentView;

@end