//
//  CPSingleChatViewController.h
//  CouchParty
//
//  Created by 呆呆 on 13-7-28.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPChatViewController.h"



@interface CPSingleChatViewController : CPChatViewController

@property (nonatomic, strong) UIImage* friendAvatar;
@property (nonatomic, strong) NSString* friendName;
@property (nonatomic, strong) XMPPJID* friendJID;

@end
