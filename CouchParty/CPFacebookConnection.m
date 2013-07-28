//
//  CPFacebookConnection.m
//  CouchParty
//
//  Created by 呆呆 on 13-6-19.
//  Copyright (c) 2013年 LuckilyRu. All rights reserved.
//

#import "CPFacebookConnection.h"

#define FACEBOOK_APP_ID @"467818589967287"

@interface CPFacebookConnection ()

@property (nonatomic, strong, readwrite) XMPPStream *xmppStream;
@property (nonatomic, strong, readwrite) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readwrite) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readwrite) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readwrite) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readwrite) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readwrite) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readwrite) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readwrite) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;

- (void)setupStream;

@end

@implementation CPFacebookConnection

+ (CPFacebookConnection*)sharedConnection
{
    static CPFacebookConnection* connection;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connection = [[self alloc] init];
    });
    return connection;
}

- (id)init
{
    self = [super init];
    if (self) {
        connected = NO;
        [self setupStream];
    }
    return self;
}

- (void)addDelegate:(id)delegate to:(XMPPOjbectIdentifier)objectIdentifier delegateQueue:(dispatch_queue_t)queue
{
    switch (objectIdentifier) {
        case XMPPOjbectIdentifierStream:
            [self.xmppStream addDelegate:delegate delegateQueue:queue];
            break;
            
        case XMPPOjbectIdentifierRoster:
            [self.xmppRoster addDelegate:delegate delegateQueue:queue];
            break;
            
        default:
            NSAssert(NO, @"Unknown identifier");
            break;
    }
}

- (void)addDelegate:(id)delegate to:(XMPPOjbectIdentifier)objectIdentifier
{
    [self addDelegate:delegate to:objectIdentifier delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id)delegate from:(XMPPOjbectIdentifier)objectIdentifier
{
    switch (objectIdentifier) {
        case XMPPOjbectIdentifierStream:
            [self.xmppStream removeDelegate:delegate];
            break;
            
        case XMPPOjbectIdentifierRoster:
            [self.xmppRoster removeDelegate:delegate];
            break;
            [self.xmppRoster removeDelegate:delegate delegateQueue:nil];
            
        default:
            NSAssert(NO, @"Unknown identifier");
            break;
    }
}

@synthesize myAvatar = _myAvatar;
- (UIImage*)myAvatar
{
    if (!_myAvatar) {
        _myAvatar = [self avatarForJID:self.xmppStream.myJID];
    }
    return _myAvatar;
}

- (void)setupStream
{
	NSAssert(self.xmppStream == nil, @"Method setupStream invoked multiple times");
	
	// Setup xmpp stream
	//
	// The XMPPStream is the base class for all activity.
	// Everything else plugs into the xmppStream, such as modules/extensions and delegates.
    
	// xmppStream = [[XMPPStream alloc] init];
	self.xmppStream = [[XMPPStream alloc] initWithFacebookAppId:FACEBOOK_APP_ID];
    
#if !TARGET_IPHONE_SIMULATOR
	{
		// Want xmpp to run in the background?
		//
		// P.S. - The simulator doesn't support backgrounding yet.
		//        When you try to set the associated property on the simulator, it simply fails.
		//        And when you background an app on the simulator,
		//        it just queues network traffic til the app is foregrounded again.
		//        We are patiently waiting for a fix from Apple.
		//        If you do enableBackgroundingOnSocket on the simulator,
		//        you will simply see an error message from the xmpp stack when it fails to set the property.
		
		self.xmppStream.enableBackgroundingOnSocket = YES;
	}
#endif
	
	// Setup reconnect
	//
	// The XMPPReconnect module monitors for "accidental disconnections" and
	// automatically reconnects the stream for you.
	// There's a bunch more information in the XMPPReconnect header file.
	
	self.xmppReconnect = [[XMPPReconnect alloc] init];
	
	// Setup roster
	//
	// The XMPPRoster handles the xmpp protocol stuff related to the roster.
	// The storage for the roster is abstracted.
	// So you can use any storage mechanism you want.
	// You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
	// or setup your own using raw SQLite, or create your own storage mechanism.
	// You can do it however you like! It's your application.
	// But you do need to provide the roster with some storage facility.
	
	self.xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    //	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];
	
	self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:self.xmppRosterStorage];
	
	self.xmppRoster.autoFetchRoster = YES;
	self.xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
	
	// Setup vCard support
	//
	// The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
	// The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
	
	self.xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
	self.xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:self.xmppvCardStorage];
	
	self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:self.xmppvCardTempModule];
	
	// Setup capabilities
	//
	// The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
	// Basically, when other clients broadcast their presence on the network
	// they include information about what capabilities their client supports (audio, video, file transfer, etc).
	// But as you can imagine, this list starts to get pretty big.
	// This is where the hashing stuff comes into play.
	// Most people running the same version of the same client are going to have the same list of capabilities.
	// So the protocol defines a standardized way to hash the list of capabilities.
	// Clients then broadcast the tiny hash instead of the big list.
	// The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
	// and also persistently storing the hashes so lookups aren't needed in the future.
	//
	// Similarly to the roster, the storage of the module is abstracted.
	// You are strongly encouraged to persist caps information across sessions.
	//
	// The XMPPCapabilitiesCoreDataStorage is an ideal solution.
	// It can also be shared amongst multiple streams to further reduce hash lookups.
	
	self.xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    self.xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:self.xmppCapabilitiesStorage];
    
    self.xmppCapabilities.autoFetchHashedCapabilities = YES;
    self.xmppCapabilities.autoFetchNonHashedCapabilities = NO;
    
	// Activate xmpp modules
    
	[self.xmppReconnect         activate:self.xmppStream];
	[self.xmppRoster            activate:self.xmppStream];
	[self.xmppvCardTempModule   activate:self.xmppStream];
	[self.xmppvCardAvatarModule activate:self.xmppStream];
	[self.xmppCapabilities      activate:self.xmppStream];
}

- (void)connect
{
    ACAccountStore* accountStore = [[ACAccountStore alloc] init];
    ACAccountType* fbAccountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    NSDictionary* infoDict = @{ACFacebookAppIdKey: FACEBOOK_APP_ID, ACFacebookPermissionsKey: @[@"email", @"xmpp_login"], ACFacebookAudienceKey: ACFacebookAudienceFriends};
    [accountStore requestAccessToAccountsWithType:fbAccountType options:infoDict completion:^(BOOL granted, NSError* error) {
        if (granted) {
            NSArray* accounts = [accountStore accountsWithAccountType:fbAccountType];
            fbAccount = [accounts lastObject];
            [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
            
            NSError* error;
            if (![self.xmppStream connectWithTimeout:5 error:&error])
            {
                NSLog(@"Connection error: %@", [error localizedDescription]);
            }
            NSLog(@"Account token: %@", [[fbAccount credential] oauthToken]);
        } else {
            NSLog(@"!!! %@", [error localizedDescription]);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"You have to login to your Facebook account in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)goOnline
{
	XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit
	
	[self.xmppStream sendElement:presence];
}

- (void)goOffline
{
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	
	[self.xmppStream sendElement:presence];
}

- (UIImage*)avatarForJID:(XMPPJID *)jid
{
    NSData *photoData = [self.xmppvCardAvatarModule photoDataForJID:jid];
    
    if (photoData != nil)
        return [UIImage imageWithData:photoData];
    else {
        return [UIImage imageNamed:@"defaultAvatar.jpg"];
    }
}

#pragma mark - XMPP stream delegate

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    
    if (![sender isSecure]) {
        NSLog(@"Try again with TLS");
        NSError* error;
        BOOL result = [sender secureConnection:&error];
        
        if (!result) {
            NSLog(@"Cannot start TLS...");
        }
    } else {
        NSError* error;
        BOOL result = [self.xmppStream authenticateWithFacebookAccessToken:[[fbAccount credential] oauthToken] error:&error];
        
        if (!result) {
            NSLog(@"Auth error: %@", [error localizedDescription]);
        }
        connected = YES;
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    connected = NO;
}

@end
