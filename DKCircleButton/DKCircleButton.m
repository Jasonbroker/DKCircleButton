//
//  DKCircleButton.m
//  DKCircleButton
//
//  Created by Dmitry Klimkin on 23/4/14.
//  Copyright (c) 2014 Dmitry Klimkin. All rights reserved.
//

#import "DKCircleButton.h"

#define DKCircleButtonBorderWidth 3.0f

@interface DKCircleButton ()

@property (nonatomic, strong) UIView *highLightView;
@property (nonatomic, strong) CAGradientLayer *gradientLayerTop;
@property (nonatomic, strong) CAGradientLayer *gradientLayerBottom;

@end

@implementation DKCircleButton

@synthesize highLightView;
@synthesize displayShading;
@synthesize gradientLayerTop;
@synthesize gradientLayerBottom;
@synthesize borderSize;
@synthesize borderColor;
@synthesize animateTap;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

-(void)commonInit{
    highLightView = [[UIView alloc] initWithFrame:self.bounds];
    
    highLightView.userInteractionEnabled = YES;
    highLightView.alpha = 0;
    highLightView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    borderColor = [UIColor whiteColor];
    animateTap = YES;
    borderSize = DKCircleButtonBorderWidth;
    
    self.clipsToBounds = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    gradientLayerTop = [CAGradientLayer layer];
    gradientLayerTop.frame = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height / 4);
    gradientLayerTop.colors = @[(id)[UIColor blackColor].CGColor, (id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.01].CGColor];
    
    gradientLayerBottom = [CAGradientLayer layer];
    gradientLayerBottom.frame = CGRectMake(0.0, self.bounds.size.height * 3 / 4, self.bounds.size.width, self.bounds.size.height / 4);
    gradientLayerBottom.colors = @[(id)[[UIColor lightGrayColor] colorWithAlphaComponent:0.01].CGColor, (id)[UIColor blackColor].CGColor];
    
    [self addSubview:highLightView];
}

- (void)setDisplayShading:(BOOL)dS {
    displayShading = dS;
    
    if (displayShading) {
        [self.layer addSublayer:gradientLayerTop];
        [self.layer addSublayer:gradientLayerBottom];
    } else {
        [gradientLayerTop removeFromSuperlayer];
        [gradientLayerBottom removeFromSuperlayer];
    }
    [self layoutSubviews];
}

- (void)setBorderColor:(UIColor *)bC {
    borderColor = bC;
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateMaskToBounds:self.bounds];
}

- (void)setHighlighted:(BOOL)highlighted {
    
    if (highlighted) {
        self.layer.borderColor = [borderColor colorWithAlphaComponent:1.0].CGColor;
        
        [self triggerAnimateTap];
    }
    else {
        self.layer.borderColor = [borderColor colorWithAlphaComponent:0.7].CGColor;
    }
}

- (void)updateMaskToBounds:(CGRect)maskBounds {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    CGPathRef maskPath = CGPathCreateWithEllipseInRect(maskBounds, NULL);
    
    maskLayer.bounds = maskBounds;
    maskLayer.path = maskPath;
    
    CGPathRelease(maskPath);
    
    maskLayer.fillColor = [UIColor blackColor].CGColor;
    
    CGPoint point = CGPointMake(maskBounds.size.width/2, maskBounds.size.height/2);
    maskLayer.position = point;
    
    [self.layer setMask:maskLayer];
    
    self.layer.cornerRadius = CGRectGetHeight(maskBounds) / 2.0;
    self.layer.borderColor = [borderColor colorWithAlphaComponent:0.7].CGColor;
    self.layer.borderWidth = borderSize;
    
    highLightView.frame = self.bounds;
}

- (void)blink {
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];
    
    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = self.borderColor.CGColor;
    circleShape.lineWidth = 2.0;
    
    [self.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.0, 2.0, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.7f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    [circleShape addAnimation:animation forKey:nil];
}

- (void)triggerAnimateTap {
    
    if (animateTap == NO) {
        return;
    }
    
    highLightView.alpha = 1;
    
    __weak typeof(self) this = self;
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        this.highLightView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
    
    CGRect pathFrame = CGRectMake(-CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds), self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:pathFrame cornerRadius:self.layer.cornerRadius];
    
    // accounts for left/right offset and contentOffset of scroll view
    CGPoint shapePosition = [self.superview convertPoint:self.center fromView:self.superview];

    CAShapeLayer *circleShape = [CAShapeLayer layer];
    circleShape.path = path.CGPath;
    circleShape.position = shapePosition;
    circleShape.fillColor = [UIColor clearColor].CGColor;
    circleShape.opacity = 0;
    circleShape.strokeColor = borderColor.CGColor;
    circleShape.lineWidth = 2.0;
    
    [self.superview.layer addSublayer:circleShape];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2.5, 2.5, 1)];
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue = @0;
    
    CAAnimationGroup *animation = [CAAnimationGroup animation];
    animation.animations = @[scaleAnimation, alphaAnimation];
    animation.duration = 0.5f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [circleShape addAnimation:animation forKey:nil];
}

- (void)setImage:(UIImage *)image animated: (BOOL)animated {
    
    [super setImage:nil forState:UIControlStateNormal];
    [super setImage:image forState:UIControlStateSelected];
    [super setImage:image forState:UIControlStateHighlighted];
    
    if (animated) {
        UIImageView *tmpImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        
        tmpImageView.image = image;
        tmpImageView.alpha = 0;
        tmpImageView.backgroundColor = [UIColor clearColor];
        tmpImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:tmpImageView];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            tmpImageView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [super setImage:image forState:UIControlStateNormal];
            [tmpImageView removeFromSuperview];
        }];
    } else {
        [super setImage:image forState:UIControlStateNormal];
    }
}

@end
