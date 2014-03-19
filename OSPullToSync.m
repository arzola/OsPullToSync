//
//  OSPullToSync.m
//  Omron
//
//  Created by Os Arzola on 3/19/14.
//  Copyright (c) 2014 Oscar Arzola
//


#import "OSPullToSync.h"
#import "Constants.h"


@interface OSPullToSync (Private)
- (void)setState:(OsPullRefreshState)aState;
@end

@implementation OSPullToSync
@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = UIColorFromRGB(0xba2e3a);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-20, 320,20)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[label setFont:[UIFont fontWithName:@"AvantGardeCE-Demi" size:11]];
		label.textColor = [UIColor whiteColor];
        label.alpha = 0.5;
		label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
        _statusLabel = label;
        CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(135, frame.size.height - 65, 42, 42);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"arrow.png"].CGImage;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
            layer.contentsScale = [[UIScreen mainScreen] scale];
        }
#endif
        [[self layer] addSublayer:layer];
		_displayedImage=layer;
        [self setState:OsPullRefreshNormal];
    }
    return self;
}

- (void)setState:(OsPullRefreshState)aState{
	
	switch (aState) {
		case OsPullRefreshPulling:
			
			_statusLabel.text = NSLocalizedString(@"RELEASE TO SYNC", @"RELEASE TO SYNC");
			[CATransaction begin];
			[CATransaction setAnimationDuration:0.18f];
			_displayedImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case OsPullRefreshNormal:
			
			if (_state == OsPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:0.18f];
				_displayedImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = NSLocalizedString(@"PULL TO SYNC", @"PULL TO SYNC");
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_displayedImage.hidden = NO;
			_displayedImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			break;
		case OsPullRefreshLoading:
			
			_statusLabel.text = NSLocalizedString(@"LOOKING FOR DEVICE...", @"LOOKING FOR DEVICE...");
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
			_displayedImage.hidden = YES;
			[CATransaction commit];
        {
            NSLog(@"Begin Animation");
            NSArray *imagesloader = [[NSBundle mainBundle] pathsForResourcesOfType:@"png" inDirectory:@"looks"];
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for(NSString *imagePath in imagesloader){
                [images addObject:[UIImage imageWithContentsOfFile:imagePath]];
            }
            UIImageView *look = [[UIImageView alloc] initWithFrame:CGRectMake(138, self.frame.size.height - 60,42,42)];
            look.animationImages = images;
            look.animationDuration = 1;
            [look startAnimating];
            [self addSubview:look];
        }
			break;
		default:
			break;
	}
	
	_state = aState;
}

#pragma mark ScrollView Methods

- (void)osRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (_state == OsPullRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, 60);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(osRefreshHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate osRefreshHeaderDataSourceIsLoading:self];
		}
		
		if (_state == OsPullRefreshPulling && scrollView.contentOffset.y > -65.0f && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:OsPullRefreshNormal];
		} else if (_state == OsPullRefreshNormal && scrollView.contentOffset.y < -65.0f && !_loading) {
			[self setState:OsPullRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)osRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(osRefreshHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate osRefreshHeaderDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= - 65.0f && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(osRefreshHeaderDidTriggerRefresh:)]) {
			[_delegate osRefreshHeaderDidTriggerRefresh:self];
		}
		
		[self setState:OsPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)osRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:OsPullRefreshNormal];
    
}

@end
