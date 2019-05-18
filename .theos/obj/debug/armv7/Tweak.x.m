#line 1 "Tweak.x"
#import <UIKit/UIKit.h>

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

@class MTMaterialView; @class PLPlatterHeaderContentView; @class MTSystemModuleDarkPlatterMaterialSettings; 
static id (*_logos_orig$_ungrouped$MTMaterialView$materialSettings)(_LOGOS_SELF_TYPE_NORMAL MTMaterialView* _LOGOS_SELF_CONST, SEL); static id _logos_method$_ungrouped$MTMaterialView$materialSettings(_LOGOS_SELF_TYPE_NORMAL MTMaterialView* _LOGOS_SELF_CONST, SEL); static MTVibrantStylingProvider * (*_logos_orig$_ungrouped$PLPlatterHeaderContentView$vibrantStylingProvider)(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST, SEL); static MTVibrantStylingProvider * _logos_method$_ungrouped$PLPlatterHeaderContentView$vibrantStylingProvider(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$)(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST, SEL, MTVibrantStylingProvider *); static void _logos_method$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST, SEL, MTVibrantStylingProvider *); 
static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$MTSystemModuleDarkPlatterMaterialSettings(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("MTSystemModuleDarkPlatterMaterialSettings"); } return _klass; }
#line 50 "Tweak.x"


static id _logos_method$_ungrouped$MTMaterialView$materialSettings(_LOGOS_SELF_TYPE_NORMAL MTMaterialView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return [_logos_static_class_lookup$MTSystemModuleDarkPlatterMaterialSettings() sharedMaterialSettings];
}





static MTVibrantStylingProvider * _logos_method$_ungrouped$PLPlatterHeaderContentView$vibrantStylingProvider(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	return [[_logos_static_class_lookup$MTSystemModuleDarkPlatterMaterialSettings() sharedMaterialSettings] vibrantStylingProvider];
}

static void _logos_method$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$(_LOGOS_SELF_TYPE_NORMAL PLPlatterHeaderContentView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, MTVibrantStylingProvider * provider) {
	provider = [[_logos_static_class_lookup$MTSystemModuleDarkPlatterMaterialSettings() sharedMaterialSettings] vibrantStylingProvider];
	_logos_orig$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$(self, _cmd, provider);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$MTMaterialView = objc_getClass("MTMaterialView"); MSHookMessageEx(_logos_class$_ungrouped$MTMaterialView, @selector(materialSettings), (IMP)&_logos_method$_ungrouped$MTMaterialView$materialSettings, (IMP*)&_logos_orig$_ungrouped$MTMaterialView$materialSettings);Class _logos_class$_ungrouped$PLPlatterHeaderContentView = objc_getClass("PLPlatterHeaderContentView"); MSHookMessageEx(_logos_class$_ungrouped$PLPlatterHeaderContentView, @selector(vibrantStylingProvider), (IMP)&_logos_method$_ungrouped$PLPlatterHeaderContentView$vibrantStylingProvider, (IMP*)&_logos_orig$_ungrouped$PLPlatterHeaderContentView$vibrantStylingProvider);MSHookMessageEx(_logos_class$_ungrouped$PLPlatterHeaderContentView, @selector(setVibrantStylingProvider:), (IMP)&_logos_method$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$, (IMP*)&_logos_orig$_ungrouped$PLPlatterHeaderContentView$setVibrantStylingProvider$);} }
#line 70 "Tweak.x"
