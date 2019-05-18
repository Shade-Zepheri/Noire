#import <UIKit/UIKit.h>
#import <SpringBoard/SBDockView+Private.h>
#import <SpringBoard/SBWallpaperEffectView+Private.h>

#pragma mark - Dock

%hook SBDockView

- (instancetype)initWithDockListView:(UIView *)dockListView forSnapshot:(BOOL)snapshot {
	self = %orig;
	if (self) {
		SBWallpaperEffectView *effectView = [self valueForKey:@"_backgroundView"];
		[effectView setStyle:14];
	}

	return self;
}

%end

#pragma mark - Notifications

%hook NCNotificationOptions

- (BOOL)prefersDarkAppearance {
	return YES;
}

%end