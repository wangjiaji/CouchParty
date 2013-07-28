//
//  CPFacebookConnection.h
//  CouchParty
//
//  Created by 呆呆 on 13-6-19.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import <Accounts/Accounts.h>

typedef NS_ENUM(NSUInteger, XMPPOjbectIdentifier) {
    XMPPOjbectIdentifierStream,
    XMPPOjbectIdentifierRoster
};

@interface CPFacebookConnection : NSObject <XMPPStreamDelegate>
{
    ACAccount* fbAccount;
    BOOL connected;
}

@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;


@property (nonatomic, strong, readonly) UIImage* myAvatar;

- (void)connect;
- (void)addDelegate:(id)delegate to:(XMPPOjbectIdentifier)objectIdentifier delegateQueue:(dispatch_queue_t)queue;
- (void)addDelegate:(id)delegate to:(XMPPOjbectIdentifier)objectIdentifier;
- (void)removeDelegate:(id)delegate from:(XMPPOjbectIdentifier)objectIdentifier;
- (void)goOnline;
- (void)goOffline;
- (UIImage*)avatarForJID:(XMPPJID*)jid;

+ (CPFacebookConnection*)sharedConnection;

@end
