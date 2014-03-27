//
//  ViewController.m
//  CALayer
//
//  Created by Can EriK Lu on 3/28/14.
//  Copyright (c) 2014 Can EriK Lu. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"
@interface ViewController ()
{
	CALayer* subLayer, *wrapper;
	UIImage* sunset;
	float border;
}
@end

#define PSIZE 160    // size of the pattern cell
static void drawStar (void *info, CGContextRef myContext)
{
    int k;
    double r, theta;
	static double l = 5;
	r = 0.8 * PSIZE / 2;
	double a = (M_PI * (l - 2)) / l,
	b = (M_PI - 2 * (M_PI - a)) / 2,
	c = M_PI - b - M_PI / l;
	double r2 = sin(b) / sin(c) * r;
	NSLog(@"%g %g %g", a / M_PI * 180 , b / M_PI * 180,c / M_PI * 180);

    theta = 2 * M_PI / 10;
	CGContextAddRect(myContext, CGRectMake(0, 0, PSIZE, PSIZE));
    CGContextTranslateCTM (myContext, PSIZE/2, PSIZE/2);

    CGContextMoveToPoint(myContext, 0, r);
    for (k = 1; k <= 10; k++) {
		float x = k % 2 ? r : r2;
		CGPoint p = CGPointMake(x * sin(k * theta), x * cos(k * theta));
		if (k == 1) {
			CGContextMoveToPoint(myContext, p.x, p.y);
		}
		else {
        	CGContextAddLineToPoint(myContext, p.x, p.y);
		}
    }


    CGContextClosePath(myContext);
//	CGContextEOFillPath(myContext);
    CGContextFillPath(myContext);
}





void stencilPatternPainting (CGContextRef myContext,
							 const Rect *windowRect)
{
    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef patternSpace;
    static const CGFloat color[4] = { 0, 0.5, 0.1, 1 };// 1
    static const CGPatternCallbacks callbacks = {0, &drawStar, NULL};// 2

    baseSpace = CGColorSpaceCreateDeviceRGB ();// 3
    patternSpace = CGColorSpaceCreatePattern (baseSpace);// 4
    CGContextSetFillColorSpace (myContext, patternSpace);// 5
    CGColorSpaceRelease (patternSpace);
    CGColorSpaceRelease (baseSpace);
    pattern = CGPatternCreate(NULL, CGRectMake(0, 0, PSIZE, PSIZE),// 6
							  CGAffineTransformIdentity, PSIZE, PSIZE,
							  kCGPatternTilingConstantSpacing,
							  false, &callbacks);  //注意和上面不一样是false参数
    CGContextSetFillPattern (myContext, pattern, color);//
    CGPatternRelease (pattern);// 8
    CGContextFillRect (myContext,CGRectMake (0,0,PSIZE*20,PSIZE*20));// 9
}
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	border = 2;
	sunset = [UIImage imageNamed:@"sunset"];
	subLayer = [CALayer layer];

	subLayer.backgroundColor = [UIColor orangeColor].CGColor;
	subLayer.masksToBounds = YES;
//	subLayer.borderColor = [UIColor whiteColor].CGColor;
//	subLayer.borderWidth = 4;
	subLayer.contents = (id)sunset.CGImage;
	subLayer.cornerRadius = 10.0;
	subLayer.masksToBounds = YES;
	subLayer.frame = CGRectMake((self.view.width - sunset.size.width) / 2, (self.view.height - sunset.size.height) / 2, sunset.size.width, sunset.size.height);
	subLayer.shouldRasterize = YES;
	subLayer.allowsEdgeAntialiasing = YES;



	wrapper = [CALayer layer];
	wrapper.backgroundColor = [UIColor clearColor].CGColor;
	wrapper.delegate = self;
	wrapper.cornerRadius = subLayer.cornerRadius;
	wrapper.shadowRadius = 7;
	wrapper.shadowOffset = CGSizeZero;
	wrapper.shadowOpacity = 1;
//	wrapper.shadowColor = [UIColor whiteColor].CGColor;
	wrapper.frame = CGRectInset(subLayer.frame, -border, -border);
	wrapper.shouldRasterize = subLayer.shouldRasterize;

//	wrapper.frame = self.view.bounds;
//	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Beautiful.jpg"]];
	[self.view.layer addSublayer:wrapper];
//	[self.view.layer addSublayer:subLayer];
	[wrapper setNeedsDisplay];

}
- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	subLayer.frame = CGRectMake((self.view.bounds.size.width - sunset.size.width) / 2, (self.view.bounds.size.height - sunset.size.height) / 2, sunset.size.width, sunset.size.height);
	wrapper.frame = CGRectInset(subLayer.frame, -border, -border);

		wrapper.frame = self.view.bounds;
}

void MyDrawColoredPattern (void *info, CGContextRef context) {

    CGColorRef dotColor = [UIColor colorWithHue:0 saturation:0 brightness:0.07 alpha:1.0].CGColor;
    CGColorRef shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1].CGColor;

    CGContextSetFillColorWithColor(context, dotColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, shadowColor);

    CGContextAddArc(context, 3, 3, 4, 0, 2 * M_PI, 0);
    CGContextFillPath(context);

    CGContextAddArc(context, 16, 16, 4, 0, 2 * M_PI, 0);
    CGContextFillPath(context);

}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {

	Rect window = {0, 0, layer.bounds.size.width, layer.bounds.size.height};
	stencilPatternPainting(context, &window);
	return;
    CGColorRef bgColor = rgb(56, 56, 56).CGColor;
    CGContextSetFillColorWithColor(context, bgColor);
//    CGContextFillRect(context, layer.bounds);

    static const CGPatternCallbacks callbacks = { 0, &MyDrawColoredPattern, NULL };

    CGContextSaveGState(context);
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);

	//	CGContextClip 		Draw inside the path

    CGPatternRef pattern = CGPatternCreate(NULL,
                                           layer.bounds,
                                           CGAffineTransformIdentity,
                                           24,
                                           24,
                                           kCGPatternTilingConstantSpacing,
                                           true,
                                           &callbacks);
    CGFloat alpha = 1.0;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
    CGContextFillRect(context, layer.bounds);
    CGContextRestoreGState(context);
	UIImage* image = [UIImage imageNamed:@"instantly114.jpg"];
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 20, [UIColor blackColor].CGColor);
	CGRect imageRect = CGRectMake(240, 340, 300, 300);
	CGPathRef path = CGPathCreateWithRoundedRect(imageRect, 20, 20, nil);
	CGPathRef path2 = CGPathCreateWithRoundedRect(CGRectInset(imageRect, 60, 60) , 20, 20, nil);
	CGContextAddPath(context, path);

	CGContextAddPath(context, path2);
	CGContextClip(context);
	CGContextDrawImage(context, imageRect, image.CGImage);

	CGPathRelease(path);
	CGPathRelease(path2);

}


@end
