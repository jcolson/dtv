//
//  DirecTVConnector.h
//  dtv
//
//  Created by Jay Colson on 1/3/09.
//  Copyright 2009 Jay Colson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/HTMLparser.h>
#import <libxml/xpath.h>
#import "FTSWAbstractSingleton.h"

@interface DirecTVConnector : FTSWAbstractSingleton {
	NSString *currentSecureSession;
	BOOL isLoggedIn;
//	NSString *currentSessionId;
}
@property BOOL isLoggedIn;

+ (DirecTVConnector*)sharedDirecTVConnector;

- (NSData*)gleanInfoFromUrl:(NSString *)urlString ContentDict:(NSDictionary *)contentDict;
- (NSString*)loginWithUsername:(NSString *)username Password:(NSString *)password;
- (void) parseDynSessConfFromHtml:(NSString *)html;
- (NSString*) parseLoginMessageFromHtml:(NSString *)html;
- (NSDictionary*)searchContent:(NSString *)searchString;
- (NSDictionary*)parseSearchHtml:(NSString*) html startKeyNumber:(int)keyNumber;
- (NSDictionary*) getDetailForUrl:(NSString*) url;
- (NSMutableArray*) doXpath:(NSString*) xpath forHtml:(NSString*) html;
- (void) dumpXmlForHtml:(NSString*)html;

@end
