#import "NRENavigationTitleView.h"

@interface NRENavigationTitleView ()
@property (strong, nonatomic) NSLayoutConstraint *iconViewInset;

@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;

@end

@implementation NRENavigationTitleView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Image view
        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 29, 29)];
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.iconImageView];

        // Constraint up
        [self.iconImageView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:0.0].active = YES;
        self.iconViewInset = [self.iconImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor];
        self.iconViewInset.active = YES;

        // Create labels
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor whiteColor];

        self.subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.font = [UIFont systemFontOfSize:11];
        self.subtitleLabel.numberOfLines = 1;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.textColor = [UIColor colorWithRed:0.43 green:0.43 blue:0.43 alpha:1.0];

        // Create stackview
        self.stackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.titleLabel, self.subtitleLabel]];
        self.stackView.axis = UILayoutConstraintAxisVertical;
        self.stackView.alignment = UIStackViewAlignmentCenter;
        self.stackView.distribution = UIStackViewDistributionEqualSpacing;
        self.stackView.spacing = 2.0;
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.stackView];

        // Constraint up
        [self.stackView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
        [self.stackView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
        [self.stackView.topAnchor constraintEqualToAnchor:self.iconImageView.bottomAnchor].active = YES;
    }

    return self;
}

#pragma mark - Properties

- (void)setIcon:(UIImage *)icon {
    if (_icon == icon) {
        return;
    }

    _icon = icon;
    self.iconImageView.image = icon;
}

- (void)setTitle:(NSString *)title {
    if (_title == title) {
        return;
    }

    _title = title;
    self.titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    if (_subtitle == subtitle) {
        return;
    }

    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
}

- (void)setShowingIcon:(BOOL)showingIcon {
    if (_showingIcon == showingIcon) {
        return;
    }

    _showingIcon = showingIcon;

    // Animate changes
    [UIView animateWithDuration:0.15 animations:^{
        self.iconImageView.alpha = showingIcon ? 1.0 : 0.0;
        self.stackView.alpha = showingIcon ? 0.0 : 1.0;

        self.iconViewInset.constant = showingIcon ? 0.0 : -29.0;
        [self layoutIfNeeded];
    }];
}

@end