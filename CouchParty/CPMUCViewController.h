//
//  CPMUCViewController.h
//  CouchParty
//
//  Created by 呆呆 on 13-7-28.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPChatViewController.h"
#import "XMPPRoom.h"


@interface CPMUCViewController : CPChatViewController <XMPPRoomDelegate>

@property (nonatomic, strong) XMPPJID* roomJID;
@property (nonatomic, strong) XMPPStream* xmppStream;
@property (nonatomic, strong) NSString* roomName;
@property (nonatomic, strong) NSString* roomSubject;

@end
