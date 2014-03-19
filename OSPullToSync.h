//
//  OSPullToSync.h
//  Omron
//
//  Created by Os Arzola on 3/19/14.
//  Copyright (c) 2014 Oscar Arzola
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	OsPullRefreshPulling = 0,
	OsPullRefreshNormal,
	OsPullRefreshLoading,
} OsPullRefreshState;

@protocol OsRefreshControlDelegate;
@interface OSPullToSync : UIView{
    id _delegate;
	OsPullRefreshState _state;
	UILabel *_statusLabel;
	CALayer *_displayedImage;
    UIImageView *_animation;
}
@property(nonatomic,strong) id <OsRefreshControlDelegate> delegate;
- (void)osRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)osRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)osRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
@end
@protocol OsRefreshControlDelegate
- (void)osRefreshHeaderDidTriggerRefresh:(OSPullToSync*)view;
- (BOOL)osRefreshHeaderDataSourceIsLoading:(OSPullToSync*)view;
@end