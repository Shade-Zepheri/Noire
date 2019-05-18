#line 1 "Tweak.x"
#import <UIKit/UIKit.h>
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>

@protocol MTMaterialSettingsObservable
@required
- (void)removeKeyObserver:(id)arg1;
- (void)addKeyObserver:(id)arg1;

@end

@interface MTVibrantStylingProvider : NSObject <MTMaterialSettingsObservable>

@end

@protocol MTMaterialSettings
@property (assign, nonatomic) BOOL usesLuminanceMap; 
@property (assign, nonatomic) CGFloat blurRadius; 
@property (assign, nonatomic) CGFloat luminanceAlpha; 
@property (assign, nonatomic) CGFloat saturation; 
@property (assign, nonatomic) CGFloat brightness; 
@property (assign, nonatomic) CGFloat tintAlpha; 
@property (weak, readonly, nonatomic) MTVibrantStylingProvider *vibrantStylingProvider; 
@required

+ (instancetype)sharedMaterialSettings;
- (CGFloat)tintAlpha;
- (void)updateWithSettingsFromArchive:(id)arg1;
- (void)setUsesLuminanceMap:(BOOL)arg1;
- (CGFloat)luminanceAlpha;
- (void)setLuminanceAlpha:(CGFloat)arg1;
- (void)setTintAlpha:(CGFloat)arg1;
- (CGFloat)saturation;
- (void)setSaturation:(CGFloat)arg1;
- (MTVibrantStylingProvider *)vibrantStylingProvider;
- (BOOL)usesLuminanceMap;
- (void)setBlurRadius:(CGFloat)arg1;
- (CGFloat)blurRadius;
- (void)setBrightness:(CGFloat)arg1;
- (CGFloat)brightness;

@end


@interface MTSystemModuleDarkPlatterMaterialSettings : NSObject <MTMaterialSettings, MTMaterialSettingsObservable>
@property (weak, readonly, nonatomic) MTVibrantStylingProvider *vibrantStylingProvider; 

+ (instancetype)sharedMaterialSettings;

@end

#pragma mark - Dock


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class NCNotificationOptions; @class SBDockView; 
static SBDockView* (*_logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$)(_LOGOS_SELF_TYPE_INIT SBDockView*, SEL, UIView *, BOOL) _LOGOS_RETURN_RETAINED; static SBDockView* _logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(_LOGOS_SELF_TYPE_INIT SBDockView*, SEL, UIView *, BOOL) _LOGOS_RETURN_RETAINED; static BOOL (*_logos_orig$_ungrouped$NCNotificationOptions$prefersDarkAppearance)(_LOGOS_SELF_TYPE_NORMAL NCNotificationOptions* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$_ungrouped$NCNotificationOptions$prefersDarkAppearance(_LOGOS_SELF_TYPE_NORMAL NCNotificationOptions* _LOGOS_SELF_CONST, SEL); 

#line 54 "Tweak.x"


static SBDockView* _logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(_LOGOS_SELF_TYPE_INIT SBDockView* __unused self, SEL __unused _cmd, UIView * dockListView, BOOL snapshot) _LOGOS_RETURN_RETAINED {
	self = _logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$(self, _cmd, dockListView, snapshot);
	if (self) {
		SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
		[effectView setStyle:14];
	}

	return self;
}



#pragma mark - Notifications



static BOOL _logos_method$_ungrouped$NCNotificationOptions$prefersDarkAppearance(_LOGOS_SELF_TYPE_NORMAL NCNotificationOptions* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return YES;
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBDockView = objc_getClass("SBDockView"); MSHookMessageEx(_logos_class$_ungrouped$SBDockView, @selector(initWithDockListView:forSnapshot:), (IMP)&_logos_method$_ungrouped$SBDockView$initWithDockListView$forSnapshot$, (IMP*)&_logos_orig$_ungrouped$SBDockView$initWithDockListView$forSnapshot$);Class _logos_class$_ungrouped$NCNotificationOptions = objc_getClass("NCNotificationOptions"); MSHookMessageEx(_logos_class$_ungrouped$NCNotificationOptions, @selector(prefersDarkAppearance), (IMP)&_logos_method$_ungrouped$NCNotificationOptions$prefersDarkAppearance, (IMP*)&_logos_orig$_ungrouped$NCNotificationOptions$prefersDarkAppearance);} }
#line 77 "Tweak.x"
