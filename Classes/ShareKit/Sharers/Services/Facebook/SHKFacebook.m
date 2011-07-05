//
//  SHKFacebook.m
//  ShareKit
//
//  Created by 浦 力ヒ on 7/5/11.
//  Copyright 2011 Rakuraku Technologies, Inc. All rights reserved.
//

#import "SHKFacebook.h"


@implementation SHKFacebook

static Facebook *facebook;

+ (void)initialize {
    facebook = [[Facebook alloc] initWithAppId:SHKFacebookAppID];
}

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenURL:) name:@"kHandleOpenURL" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kHandleOpenURL" object:nil];
	[super dealloc];
}

#pragma mark - Configuration : Service Defination

+ (NSString *)sharerTitle {
	return @"Facebook";
}

+ (BOOL)canShareURL {
	return YES;
}

+ (BOOL)canShareText {
	return YES;
}

+ (BOOL)canShareImage {
	return NO;
}

+ (BOOL)canShareOffline {
	return NO;
}

- (NSArray *)shareFormFieldsForType:(SHKShareType)type {
    return nil;
}

#pragma mark - Authentication
- (BOOL)isAuthorized {	
	if (![[self class] requiresAuthentication])
		return YES;

	if ([facebook isSessionValid]) {
        return YES;
    }
	NSString *sharerId = [self sharerId];
    NSString *accessToken = [SHK getAuthValueForKey:@"accessToken" forSharer:sharerId];
    NSString *expirationDate = [SHK getAuthValueForKey:@"expirationDate" forSharer:sharerId];
    if (accessToken && expirationDate) {
        facebook.accessToken = accessToken;
        facebook.expirationDate = [NSDate dateWithTimeIntervalSince1970:[expirationDate doubleValue]];
        return [facebook isSessionValid];
    }
	return NO;
}

- (void)promptAuthorization {
    NSArray *permissions = [[SHKFacebookPermissions stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    [facebook authorize:permissions delegate:self];
}

+ (void)logout {
	NSString *sharerId = [self sharerId];
    [SHK removeAuthValueForKey:@"accessToken" forSharer:sharerId];
    [SHK removeAuthValueForKey:@"expirationDate" forSharer:sharerId];
}

#pragma mark - Send
- (BOOL)send {
    [self sendDidStart];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (item.URL) {
        [params setObject:[item.URL absoluteString] forKey:@"link"];
    }
    if (item.title) {
        [params setObject:item.title forKey:@"name"];
    }
    if ([item customValueForKey:@"caption"]) {
        [params setObject:[item customValueForKey:@"caption"] forKey:@"caption"];
    }
    if ([item customValueForKey:@"description"]) {
        [params setObject:[item customValueForKey:@"description"] forKey:@"description"];
    }
    if ([item customValueForKey:@"imageURL"]) {
        [params setObject:[item customValueForKey:@"imageURL"] forKey:@"picture"];
    }
    if (item.text) {
        [params setObject:[NSString stringWithFormat:item.text, item.title] forKey:@"message"];
    }
    [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
	return YES;
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    NSString *sharerId = [self sharerId];
    [SHK setAuthValue:facebook.accessToken forKey:@"accessToken" forSharer:sharerId];
    [SHK setAuthValue:[NSString stringWithFormat:@"%f", [facebook.expirationDate timeIntervalSince1970]] forKey:@"expirationDate" forSharer:sharerId];
    [self tryPendingAction];
}

#pragma mark - FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    [self sendDidFinish];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [self sendDidFailWithError:error];
}

#pragma mark - handleOpenURL
- (void)handleOpenURL:(NSNotification *)notif {
    NSURL *url = notif.object;
    if (url) {
        [facebook handleOpenURL:url];
    }
}

@end
