//
//  ViewController.m
//  ShoppingCarAnimation
//
//  Created by xubojoy on 2017/11/28.
//  Copyright © 2017年 xubojoy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<CAAnimationDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *targetView;
@property (nonatomic, strong) CAShapeLayer *shaperLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30,300, 50, 50)];
    self.imageView.image = [UIImage imageNamed:@"logo.jpeg"];
    self.imageView.userInteractionEnabled = YES;
    [self.view addSubview:self.imageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImg)];
    [self.imageView addGestureRecognizer:tap];
    
    [self.view addSubview:self.targetView];
}

- (UIImageView *)targetView {
    if (!_targetView) {
        _targetView = [[UIImageView alloc] init];
        _targetView.frame = CGRectMake(self.view.bounds.size.width - 20 - 50, self.view.bounds.size.height - 50 - 5, 50, 50);
        _targetView.image = [UIImage imageNamed:@"logo.jpeg"];
    }
    return _targetView;
}

- (void)tapImg{
    NSLog(@">>>>>>>>>>>>>点击了图片");
    [self startAnimationandView:self.imageView endView:self.targetView];
}

- (void)startAnimationandView:(UIView *)animationView endView:(UIView *)endView{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    //设置开始位置
    CGPoint startCenter = [animationView convertPoint:CGPointMake(animationView.frame.size.width/2, animationView.frame.size.height/2) toView:window];
    //设置终点位置
    CGPoint endCenter = [endView convertPoint:CGPointMake(endView.frame.size.width/2, endView.frame.size.height/2) toView:window];
    //计算抛物线
    //贝塞尔曲线的两个经过控制点
    CGFloat controlPointEY = 200;
    CGFloat controlPointEX = (endCenter.x-startCenter.x)/4;
    CGFloat controlPointCX = (startCenter.x+endCenter.x)/2;
    CGFloat controlPointCY = (startCenter.y < endCenter.y) ? startCenter.y : endCenter.y;
    CGPoint controlPoint1 = CGPointMake(controlPointCX-controlPointEX, controlPointCY-controlPointEY);
    CGPoint controlPoint12 = CGPointMake(controlPointCX+controlPointEX, controlPointCY-controlPointEY);
    
    //绘制图形
    _shaperLayer = [[CAShapeLayer alloc] init];
    _shaperLayer.frame = CGRectMake(startCenter.x, startCenter.y, 50, 50);
    _shaperLayer.contents = (id)self.imageView.image.CGImage;
    
    [window.layer addSublayer:_shaperLayer];
    
    //绘制路径
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startCenter];
    [path addCurveToPoint:endCenter controlPoint1:controlPoint1 controlPoint2:controlPoint12];
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    
    //设置旋转
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotateAnimation.removedOnCompletion = YES;
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:4*M_PI];
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    //设置缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.2];
    
    //设置透明度
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.removedOnCompletion = NO;
    alphaAnimation.fromValue = [NSNumber numberWithFloat:1];
    alphaAnimation.toValue = [NSNumber numberWithFloat:0.1];

    //动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[pathAnimation,rotateAnimation,scaleAnimation,alphaAnimation];
    animationGroup.duration = 1.0;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.delegate = self;
    [_shaperLayer addAnimation:animationGroup forKey:@"group"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        [_shaperLayer removeFromSuperlayer];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
