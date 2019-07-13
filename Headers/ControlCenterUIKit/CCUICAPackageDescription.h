@interface CCUICAPackageDescription : NSObject
@property (copy, readonly, nonatomic) NSURL *packageURL;

+ (instancetype)descriptionForPackageNamed:(NSString *)packageName inBundle:(NSBundle *)bundle;
- (instancetype)initWithPackageName:(NSString *)packageName inBundle:(NSBundle *)bundle;

@end