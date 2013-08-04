//
//  CPChatViewController.h
//  CouchParty
//
//  Created by 呆呆 on 13-7-16.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "PHFComposeBarView.h"

@class XMPPStream, XMPPJID;

@class XMPPJID, XMPPMessage;

@protocol CPChatMessageDelegate <NSObject>
@optional

- (void)chatViewDidReceiveMessage:(XMPPMessage*)message;

@end

@interface CPChatViewController : UIViewController <UIBubbleTableViewDataSource, PHFComposeBarViewDelegate, CPChatMessageDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage* myAvatar;
@property (nonatomic, strong) NSMutableArray* chatMessages;
@property (nonatomic, strong) XMPPStream* xmppStream;

- (void)addBubble:(NSBubbleData*)bubble;
- (void)sendMessage:(NSString*)messsage;
- (void)sendXMPPMessage:(NSString *)message withType:(NSString*)type to:(XMPPJID*)jid;
- (void)sendImage:(UIImage*)image;

@end
