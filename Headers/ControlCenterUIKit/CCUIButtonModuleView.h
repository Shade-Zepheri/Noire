@class MTMaterialView;

@interface CCUIButtonModuleView : UIControl <NRESettingsObserver> {
    MTMaterialView *_highlightedBackgroundView;
}

// Added by me
- (void)settings:(NRESettings *)settings changedValueForKeyPath:(NSString *)keyPath;

@end