//
//  PhotoBoothController.m
//  ImageManipulation
//
//  Created by Roger Chapman on 10/06/2011.
//  Copyright 2011 Storm ID Ltd. All rights reserved.
//

#import "PhotoBoothController.h"


@implementation PhotoBoothController{
    CGRect initImageRect;
    BOOL isinit;
    
    
}


@synthesize canvas;
@synthesize photoImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isinit=NO;
    }
    return self;
}

- (void)dealloc
{
  [photoImage release];
  [canvas release];
  [_marque release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!isinit) {
        initImageRect= self.photoImage.frame ;
        self.imageBound=[UIBezierPath bezierPathWithRect:initImageRect];
        isinit=YES;
    }
    
}

#pragma mark - Private Methods
-(UIBezierPath* )getImageBoundsWithFrame:(CGRect)frame andAngle:(CGFloat)angle{
    CGFloat h=initImageRect.size.height;
    CGFloat w=initImageRect.size.width;
    CGPoint pointLeftTop=CGPointMake(frame.origin.x, frame.origin.y);
    CGPoint pointRightTop=CGPointMake(frame.origin.x+frame.size.width, frame.origin.y);
    CGPoint pointLeftBottom=CGPointMake(frame.origin.x, frame.origin.y+frame.size.height);
    CGPoint pointRightBottom=CGPointMake(frame.origin.x+frame.size.width, frame.origin.y+frame.size.height);
    
    CGFloat deltaH=h*sinf(angle);
    CGFloat deltaW=w*sinf(angle);
    NSLog(@"sin: %2.3f  h:%2.2f  w:%2.2f",sinf(angle),h,w);
    UIBezierPath* bezier=[UIBezierPath bezierPathWithRect:initImageRect];
    if (angle>0) {
        [bezier moveToPoint:CGPointMake(pointLeftTop.x+deltaH,pointLeftTop.y)];
        [bezier addLineToPoint:CGPointMake(pointRightTop.x, pointRightTop.y+deltaW)];
        [bezier addLineToPoint:CGPointMake(pointRightBottom.x-deltaH, pointRightBottom.y)];
        [bezier addLineToPoint:CGPointMake(pointLeftBottom.x, pointLeftBottom.y-deltaW)];
        [bezier closePath];
    }else{
        [bezier moveToPoint:CGPointMake(pointLeftTop.x,pointLeftTop.y+deltaW)];
        [bezier addLineToPoint:CGPointMake(pointRightTop.x-deltaH, pointRightTop.y)];
        [bezier addLineToPoint:CGPointMake(pointRightBottom.x, pointRightBottom.y-deltaW)];
        [bezier addLineToPoint:CGPointMake(pointLeftBottom.x+deltaH, pointLeftBottom.y)];
        [bezier closePath];
    }
    
    
    return bezier;
}


-(CGRect)setCenterOfRect:(CGRect)rect withAnotherRect:(CGRect)another{
    CGPoint center=CGPointMake(CGRectGetMidX(another), CGRectGetMidY(another));
    CGRect a={CGPointMake(center.x-rect.size.width/2, center.y-rect.size.height/2),rect.size};
    return a;
}

-(UIBezierPath*)getPathWithInitFrame:(CGRect)initFrame andTransform:(CGAffineTransform)trans andNowCenter:(CGPoint)center{
    CGPoint points[]={
        CGPointMake(CGRectGetMinX(initFrame), CGRectGetMinY(initFrame)),
        CGPointMake(CGRectGetMaxX(initFrame), CGRectGetMinY(initFrame)),
        CGPointMake(CGRectGetMaxX(initFrame), CGRectGetMaxY(initFrame)),
        CGPointMake(CGRectGetMinX(initFrame), CGRectGetMaxY(initFrame)),
    };
    
    CGPoint pointsAfter[]={
        CGPointZero,CGPointZero,CGPointZero,CGPointZero,
    };
    
    int i;
    CGFloat x=0,y=0;
    
    for (i=0; i<4; i++) {
        pointsAfter[i]=CGPointApplyAffineTransform(points[i], trans);
        x+=pointsAfter[i].x/4.0;
        y+=pointsAfter[i].y/4.0;
    }
    
    CGFloat deltaX=center.x-x,deltaY=center.y-y;
    
    for (i=0; i<4; i++) {
        pointsAfter[i].x+=deltaX;
        pointsAfter[i].y+=deltaY;
    }
    
    UIBezierPath* bezier=[[UIBezierPath alloc] init];
    
    for (i=0; i<4; i++) {
        if (i==0) {
            [bezier moveToPoint:pointsAfter[i]];
        }else{
            [bezier addLineToPoint:pointsAfter[i]];
        }
    }
    
    [bezier closePath];
    return bezier;
    
}

-(void)showOverlayWithFrame:(CGRect)frame withTransform:(CGAffineTransform )transform {
  
  if (![_marque actionForKey:@"linePhase"]) {
    CABasicAnimation *dashAnimation;
    dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
    [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
    [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
    [dashAnimation setDuration:0.5f];
    [dashAnimation setRepeatCount:HUGE_VALF];
    [_marque addAnimation:dashAnimation forKey:@"linePhase"];
  }
    
    UIBezierPath *be = [self getPathWithInitFrame:initImageRect andTransform:transform andNowCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    
    [be appendPath:[UIBezierPath bezierPathWithRect:frame]];
    
    //[be applyTransform:transform];
    //[be ]
    //NSLog(@"Bezier: %@",be);
//    CGFloat angle=atan2f(transform.b, transform.a);
//    NSLog(@"angle: %2.2f",atan2f(transform.b, transform.a));
//    NSLog (@"%f %f %f", acos (transform.a), asin (transform.b), atan2(transform.b, transform.a) );
//    NSLog(@"frame: %@",NSStringFromCGRect(frame));
    
    //self.imageBound= [self getImageBoundsWithFrame:frame andAngle:angle];
    self.imageBound=be;
    
    
    
  
  //_marque.frame = CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
  //_marque.position = CGPointMake(frame.origin.x + canvas.frame.origin.x, frame.origin.y + canvas.frame.origin.y);
    
  
  CGPathRef path = CGPathCreateCopy(self.imageBound.CGPath) ;
  //CGPathAddRect(path, NULL, frame);
  [_marque setPath:path];
  //CGPathRelease(path);
  
  _marque.hidden = NO;
  
}

//-(void)scale:(id)sender {
//      
//    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
//      _lastScale = 1.0;
//    }
//    
//    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
//    
//    CGAffineTransform currentTransform = photoImage.transform;
//    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
//    
//    [photoImage setTransform:newTransform];
//    
//    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
//    [self showOverlayWithFrame:photoImage.frame];
//}


- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer {
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.photoImage.transform = CGAffineTransformRotate([self.photoImage transform], [gestureRecognizer rotation]);
        
        [self.imageBound applyTransform:CGAffineTransformMakeRotation([gestureRecognizer rotation])];
        [gestureRecognizer setRotation:0];
        
        [self showOverlayWithFrame:self.photoImage.frame withTransform:self.photoImage.transform];
    }
}


- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer {
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        self.photoImage.transform = CGAffineTransformScale([self.photoImage transform], [gestureRecognizer scale], [gestureRecognizer scale]);
        
        [self.imageBound applyTransform:CGAffineTransformMakeScale([gestureRecognizer scale], [gestureRecognizer scale])];
        [gestureRecognizer setScale:1];
        
        [self showOverlayWithFrame:self.photoImage.frame withTransform:self.photoImage.transform];
    }
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        UIView *piece = gestureRecognizer.view;
//        CGPoint locationInView = [gestureRecognizer locationInView:piece];
//        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
//        
//        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
//        piece.center = locationInSuperview;
    }
}


//
//
//-(void)rotate:(id)sender {
//    
//    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
//      
//      _lastRotation = 0.0;
//      return;
//    }
//    
//    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
//    
//    CGAffineTransform currentTransform = self.photoImage.transform;
//    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
//    
//    [self.photoImage setTransform:newTransform];
//    
//    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
//    [self showOverlayWithFrame:self.photoImage.frame];
//}


-(void)move:(id)sender {
    UIPanGestureRecognizer* panner= (UIPanGestureRecognizer*)sender;
    CGPoint translatedPoint = [panner translationInView:canvas];
//    CGAffineTransform transform = CGAffineTransformTranslate( self.photoImage.transform, translatedPoint.x, translatedPoint.y);
//    self.photoImage.transform=transform;
//    [panner setTranslation:CGPointZero inView:canvas];
    
  
    
  if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
    _firstX = [self.photoImage center].x;
    _firstY = [self.photoImage center].y;
  }
    
  translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
  [self.photoImage setCenter:translatedPoint];
  [self showOverlayWithFrame:self.photoImage.frame withTransform:self.photoImage.transform];
}

-(void)tapped:(id)sender {
  _marque.hidden = YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (!_marque) {
    _marque = [[CAShapeLayer layer] retain];
    _marque.fillColor = [[UIColor clearColor] CGColor];
    _marque.strokeColor = [[UIColor grayColor] CGColor];
    _marque.lineWidth = 1.0f;
    _marque.lineJoin = kCALineJoinRound;
    _marque.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:5], nil];
    _marque.bounds = CGRectMake(self.photoImage.frame.origin.x, self.photoImage.frame.origin.y, 0, 0);
    _marque.position = CGPointMake(self.photoImage.frame.origin.x + canvas.frame.origin.x, self.photoImage.frame.origin.y + canvas.frame.origin.y);
  }
  [[self.view layer] addSublayer:_marque];
    
//  UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)] autorelease];
//  [pinchRecognizer setDelegate:self];
//  [self.view addGestureRecognizer:pinchRecognizer];
//  
//  UIRotationGestureRecognizer *rotationRecognizer = [[[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)] autorelease];
//  [rotationRecognizer setDelegate:self];
//  [self.view addGestureRecognizer:rotationRecognizer];
    
    
    
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [self.view addGestureRecognizer:rotationGesture];
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [self.view addGestureRecognizer:pinchGesture];
    
    
    
  
  UIPanGestureRecognizer *panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)] autorelease];
  [panRecognizer setMinimumNumberOfTouches:1];
  [panRecognizer setMaximumNumberOfTouches:1];
  [panRecognizer setDelegate:self];
  [canvas addGestureRecognizer:panRecognizer];
  
  UITapGestureRecognizer *tapProfileImageRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)] autorelease];
  [tapProfileImageRecognizer setNumberOfTapsRequired:1];
  [tapProfileImageRecognizer setDelegate:self];
  [canvas addGestureRecognizer:tapProfileImageRecognizer];
  
}

- (void)viewDidUnload
{
  [self setPhotoImage:nil];
  [self setCanvas:nil];
  [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

#pragma mark UIGestureRegognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
    return NO;
    
    // if either of the gesture recognizers is the long press, don't allow simultaneous recognition
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    return NO;
    
    return YES;
}


@end
