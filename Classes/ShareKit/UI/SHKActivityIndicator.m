//
//  SHKActivityIndicator.m
//  ShareKit
//
//  Created by Nathan Weiner on 6/16/10.

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>

#define SHKdegreesToRadians(x) (M_PI * x / 180.0)

@implementation SHKActivityIndicator

@synthesize centerMessageLabel, subMessageLabel;
@synthesize spinner;

static SHKActivityIndicator *currentIndicator = nil;


+ (SHKActivityIndicator *)currentIndicator
{
	if (currentIndicator == nil)
	{
		UIView *rootView = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
		
		CGFloat width = 160;
		CGFloat height = 160;
		CGRect centeredFrame = CGRectIntegral(CGRectMake(rootView.bounds.size.width/2 - width/2, rootView.bounds.size.height/2 - height/2, width, height));
		
		currentIndicator = [[SHKActivityIndicator alloc] initWithFrame:centeredFrame];
		
		currentIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		currentIndicator.opaque = NO;
		currentIndicator.alpha = 0;
		
		currentIndicator.layer.cornerRadius = 10;
		
		currentIndicator.userInteractionEnabled = NO;
		currentIndicator.autoresizesSubviews = YES;
		currentIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;
    }
	
	return currentIndicator;
}

#pragma mark -

- (void)dealloc
{
    if (currentIndicator) {
        if ([currentIndicator superview]) {
            [currentIndicator removeFromSuperview];
        }
        [currentIndicator release];
        currentIndicator = nil;
    }
	[centerMessageLabel release];
	[subMessageLabel release];
	[spinner release];
	
	[super dealloc];
}

#pragma mark Creating Message

- (void)show
{	
	if ([self superview] != [[UIApplication sharedApplication] keyWindow].rootViewController.view) 
        [self removeFromSuperview];
		[[[UIApplication sharedApplication] keyWindow].rootViewController.view addSubview:self];
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hideAfterDelay
{
	[self performSelector:@selector(hide) withObject:nil afterDelay:0.6];
}

- (void)hide
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hidden)];
	
	self.alpha = 0;
	
	[UIView commitAnimations];
}

- (void)persist
{	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.1];
	
	self.alpha = 1;
	
	[UIView commitAnimations];
}

- (void)hidden
{
	if (currentIndicator.alpha > 0)
		return;
	
	[currentIndicator removeFromSuperview];
}

- (void)displayActivity:(NSString *)m
{		
	[self setSubMessage:m];
	[self showSpinner];	
	
	[centerMessageLabel removeFromSuperview];
	self.centerMessageLabel = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
}

- (void)displayCompleted:(NSString *)m
{	
	[self setCenterMessage:@"✓"];
	[self setSubMessage:m];
	
	[spinner removeFromSuperview];
	self.spinner = nil;
	
	if ([self superview] == nil)
		[self show];
	else
		[self persist];
		
	[self hideAfterDelay];
}

- (void)setCenterMessage:(NSString *)message
{	
	if (message == nil && centerMessageLabel != nil)
		self.centerMessageLabel = nil;

	else if (message != nil)
	{
		if (centerMessageLabel == nil)
		{
			self.centerMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,round(self.bounds.size.height/2-50/2),self.bounds.size.width-24,50)] autorelease];
			centerMessageLabel.backgroundColor = [UIColor clearColor];
			centerMessageLabel.opaque = NO;
			centerMessageLabel.textColor = [UIColor whiteColor];
			centerMessageLabel.font = [UIFont boldSystemFontOfSize:40];
			centerMessageLabel.textAlignment = UITextAlignmentCenter;
			centerMessageLabel.shadowColor = [UIColor darkGrayColor];
			centerMessageLabel.shadowOffset = CGSizeMake(1,1);
			centerMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:centerMessageLabel];
		}
		
		centerMessageLabel.text = message;
	}
}

- (void)setSubMessage:(NSString *)message
{	
	if (message == nil && subMessageLabel != nil)
		self.subMessageLabel = nil;
	
	else if (message != nil)
	{
		if (subMessageLabel == nil)
		{
			self.subMessageLabel = [[[UILabel alloc] initWithFrame:CGRectMake(12,self.bounds.size.height-45,self.bounds.size.width-24,30)] autorelease];
			subMessageLabel.backgroundColor = [UIColor clearColor];
			subMessageLabel.opaque = NO;
			subMessageLabel.textColor = [UIColor whiteColor];
			subMessageLabel.font = [UIFont boldSystemFontOfSize:17];
			subMessageLabel.textAlignment = UITextAlignmentCenter;
			subMessageLabel.shadowColor = [UIColor darkGrayColor];
			subMessageLabel.shadowOffset = CGSizeMake(1,1);
			subMessageLabel.adjustsFontSizeToFitWidth = YES;
			
			[self addSubview:subMessageLabel];
		}
		
		subMessageLabel.text = message;
	}
}
	 
- (void)showSpinner
{	
	if (spinner == nil)
	{
		self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

		spinner.frame = CGRectMake(round(self.bounds.size.width/2 - spinner.frame.size.width/2),
								round(self.bounds.size.height/2 - spinner.frame.size.height/2),
								spinner.frame.size.width,
								spinner.frame.size.height);		
		[spinner release];	
	}
	
	[self addSubview:spinner];
	[spinner startAnimating];
}
@end
