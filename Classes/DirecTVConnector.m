//
//  DirecTVConnector.m
//  dtv
//
//  Created by Jay Colson on 1/3/09.
//  Copyright 2009 Jay Colson. All rights reserved.
//
#import "DirecTVConnector.h"

static NSString	*urlStartWith = @"https://www.directv.com";
static NSString	*userAgent = @"Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en)";
static NSString *initUrl = @"http://m.directv.com";
static NSString *loginPageUrl = @"https://www.directv.com/DTVAPP/mobile/firstLogon.jsp";
static NSString *xpathLoginPageFormParse = @"/html/body/form/input[@type!='image'][@value]/@name | /html/body/form/*/input[@type!='image'][@value]/@name";
static NSString *xpathLoginPageFormParseValues = @"/html/body/form/input[@type!='image']/@value | /html/body/form/*/input[@type!='image']/@value";
static NSString *xpathLoginPageFormParseImage = @"/html/body/form/input[@type='image'][@value]/@name | /html/body/form/*/input[@type='image'][@value]/@name";
static NSString *xpathLoginPageFormParseImageValues = @"/html/body/form/input[@type='image']/@value | /html/body/form/*/input[@type='image']/@value";
static NSString *loginPostToUrl = @"https://www.directv.com/DTVAPP/mobile/firstLogon.jsp?_DARGS=/DTVAPP/mobile/component/firstLogonBody.jsp.firstLogonForm";
static NSString *xpathForSessConf = @"/html/body/form/div/input[@name='_dynSessConf']/@value";
static NSString *xpathForLoginMessage = @"/html/body/form/span[@class='normal']";
//static NSString *xpathForGoodLogin = @"/html/body/span[@class='actionbutton']/a[@href='/DTVAPP/mobile/secured/searchMain.jsp']/@href";
static NSString *searchPageUrl = @"http://www.directv.com/DTVAPP/mobile/secured/searchMain.jsp";
static NSString *searchPostUrl = @"http://www.directv.com/DTVAPP/mobile/secured/searchMain.jsp?_DARGS=/DTVAPP/mobile/secured/component/searchMainBody.jsp.searchMainForm";
static NSString *xpathSearchTitles = @"/html/body/p/span/a[@class='blueemphasis']";
static NSString *xpathSearchTimes = @"/html/body/p/span/a[@class='blueemphasis']/..";
static NSString *xpathSearchUrls = @"/html/body/p/span/a[@class='blueemphasis']/@href";
static NSString *displayTitlesUrlPfx = @"http://www.directv.com";///DTVAPP/mobile/secured/displayTitles.jsp?page=";// ex. page=2
static NSString *xpathTitlesUri = @"/html/body/p/span[a='Next']/a/@href";

// detail
static NSString *xpathDetailTitle = @"(/html/body/span[@class='emphasis'])[1]";
static NSString *xpathDetailChannelAndRating = @"(/html/body/span[@class='normal'])[1]";
static NSString *xpathDetailAirTime = @"(/html/body/span[@class='normal'])[2]";
static NSString *xpathDetailSummary = @"(/html/body/span[@class='normal'])[3]";

static NSString *scheduleUrl = @"http://www.directv.com/DTVAPP/mobile/secured/titleInfo.jsp?_DARGS=/DTVAPP/mobile/secured/component/titleInfoBody.jsp.selectProgramForm1";

@implementation DirecTVConnector
@synthesize isLoggedIn;

+ (DirecTVConnector*) sharedDirecTVConnector {
	return [self singleton];
}

- (id) initSingleton {
    if (self = [super initSingleton]) {
        // do some cool initialization stuff (login in the background, etc)
    }
    return self;
}

- (NSData*) gleanInfoFromUrl:(NSString *)urlString ContentDict:(NSDictionary *)contentDict {
	NSLog(@"Going to url: %@", urlString);
	NSHTTPURLResponse   *response;
	NSError             *error;
	
	NSURL				*url = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url
																 cachePolicy:NSURLRequestReloadIgnoringCacheData 
															 timeoutInterval:60] autorelease];		
	[request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
	NSArray *availableCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:urlStartWith]];
	NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:availableCookies];
	// set the known cookies on the request
	[request setAllHTTPHeaderFields:headers];
	// if there is a contentDict, use it to populate a post
	if (contentDict != nil) {
		NSString *content = @"";
		for (NSString *key in [contentDict allKeys]) {
			NSString *keyEncoded = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			content = [content stringByAppendingString:keyEncoded];
			content = [content stringByAppendingString:@"="];
			NSString *valueEncoded = [[contentDict valueForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			content = [content stringByAppendingString:valueEncoded];
			content = [content stringByAppendingString:@"&"];
		}
		NSLog(@"post string: %@",content);
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[content dataUsingEncoding:NSASCIIStringEncoding]];
		
	}
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	//NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	NSLog(@"RESPONSE HEADERS: \n%@", [response allHeaderFields]);
	
	// If you want to get all of the cookies:
	if ([response allHeaderFields]) {
		NSArray *allNewCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:urlStartWith]];
		NSLog(@"How many Cookies: %d", allNewCookies.count);
		// Store the cookies:
		// NSHTTPCookieStorage is a Singleton.
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:allNewCookies forURL:[NSURL URLWithString:urlStartWith] mainDocumentURL:nil];
	} else {
		NSLog(@"No COOKIES --- ummmm  -- no HEADERS --- oie --- somethings wrong");
	}
	// need to store the sessionid cookie ...  sheesh this site suxors --- DOH, don't need this after all
	/**
	 for (NSHTTPCookie *cookie in allNewCookies) {
	 NSLog(@"Name: %@ : Value: %@, Expires: %@", cookie.name, cookie.value, cookie.expiresDate);
	 if ([cookie.name isEqualToString:@"JSESSIONID"]) {
	 currentSessionId = cookie.value;
	 }
	 }
	 */
	NSLog(@"The server response:\n%@", [[[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding] autorelease]);
	
	return data;
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
}



- (id)init {
	NSLog(@"init was called");
	if (self = [super init]) {
		NSLog(@"about to hit first time");
		[self gleanInfoFromUrl:initUrl ContentDict:nil];
	} else {
		NSLog(@"wtf");
	}
	return self;
}

- (NSMutableDictionary*) parseFormHtml: (NSString*) html forInputsByXpath: (NSString*) xpathForInputs andInputValuesByXpath: (NSString*) xpathForInputValues
				  andImageInputByXpath: (NSString*) xpathForImageInputs andImageInputValuesByXpath: (NSString*) xpathForImageInputValues {
	NSMutableArray *keys = [self doXpath:xpathLoginPageFormParse forHtml:html];
	NSMutableArray *keysImage = [self doXpath:xpathLoginPageFormParseImage forHtml:html];
	[keys addObjectsFromArray:keysImage];
	for (NSString *imageKey in keysImage) {
		[keys addObject:[imageKey stringByAppendingString:@".x"]];
		[keys addObject:[imageKey stringByAppendingString:@".y"]];
	}
	NSMutableArray *values = [self doXpath:xpathLoginPageFormParseValues forHtml:html];
	NSMutableArray *valuesImage = [self doXpath:xpathLoginPageFormParseImageValues forHtml:html];
	[values addObjectsFromArray:valuesImage];
	for (NSString *valueKey in valuesImage) {
		[values addObject:@"79"];
		[values addObject:@"12"];
	}
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:values forKeys:keys];
	return dictionary;
}

- (NSString*)loginWithUsername:(NSString *)username Password:(NSString *)password {
	NSString *returnVal = nil;
	// get the login page
	NSData *data = [self gleanInfoFromUrl:loginPageUrl ContentDict:nil];
	// parse the response and get the _dynSessConf
	NSString *html = [[[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding] autorelease];
	//todo can get rid of this once we have a 'real' isLoggedIn method
	[self parseDynSessConfFromHtml:html];
	if (currentSecureSession != nil) {
		// create the form to post
		NSMutableDictionary *dictionary = [self parseFormHtml:html forInputsByXpath:xpathLoginPageFormParse andInputValuesByXpath:xpathLoginPageFormParseImage
										 andImageInputByXpath:xpathLoginPageFormParseValues andImageInputValuesByXpath:xpathLoginPageFormParseImageValues];
		// replace login fields
		[dictionary setObject:username forKey:@"userName"];
		[dictionary setObject:password forKey:@"password"];
		[dictionary setObject:currentSecureSession forKey:@"_dynSessConf"];
		
		//actually login
		NSData *data2 = [self gleanInfoFromUrl:loginPostToUrl ContentDict:dictionary];
		NSString *htmlLogin = [[[NSString alloc] initWithData:data2 encoding: NSASCIIStringEncoding] autorelease];
		NSString *loginMessage = [self parseLoginMessageFromHtml:htmlLogin];
		
		if (loginMessage == nil) {
			[self setIsLoggedIn:YES];
		}
		returnVal = loginMessage;
	} else {
		returnVal = @"DirecTV is experiencing issues";
	}
	return returnVal;
}

- (NSString*) parseLoginMessageFromHtml:(NSString *)html {
	NSMutableArray *results = [self doXpath:xpathForLoginMessage forHtml:html];
	NSString *loginMessage = nil;	
	if (results != nil) {
		loginMessage = [results lastObject];
		if ([loginMessage isEqualToString:@"Remember Me"]) {
			loginMessage = @"Incorrect Username or Password";
		}
	}
	NSLog(@"returning this for login message: %@", loginMessage);
	return loginMessage;
}

- (void) parseDynSessConfFromHtml:(NSString *)html {
	NSMutableArray *parsedResults = [self doXpath:xpathForSessConf forHtml:html];
	currentSecureSession = [parsedResults lastObject];
}

- (NSDictionary*)searchContent:(NSString *)searchString {
	NSDictionary *returnDict = nil;
	// get the search page
	NSData *data = [self gleanInfoFromUrl:searchPageUrl ContentDict:nil];
	// parse the response and get the _dynSessConf
	NSString *html = [[[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding] autorelease];
	// need the new dynSessConf
	//[self parseDynSessConfFromHtml:html];
	
	if (currentSecureSession != nil) {
		// create the form to post
		NSMutableDictionary *dictionary = [self parseFormHtml:html forInputsByXpath:xpathLoginPageFormParse andInputValuesByXpath:xpathLoginPageFormParseImage
										 andImageInputByXpath:xpathLoginPageFormParseValues andImageInputValuesByXpath:xpathLoginPageFormParseImageValues];
		[dictionary setObject:searchString forKey:@"testInput"];
		
		//actually login
		// ;jsessionid=1Q1lJvJf2qnj5tjnYmqBK5RnWCHX121KGTMMhKCy9Fd0rJj0lPQG
		//		NSData *data2 = [self gleanInfoFromUrl:[[searchPostUrl stringByAppendingString:@";jsessionid="] stringByAppendingString:currentSessionId] ContentDict:dictionary];
		NSData *searchPostData = [self gleanInfoFromUrl:searchPostUrl ContentDict:dictionary];
		NSString *searchPostHtml = [[[NSString alloc] initWithData:searchPostData encoding: NSASCIIStringEncoding] autorelease];
		returnDict = [self parseSearchHtml:searchPostHtml startKeyNumber:0];
		//don't find all for now (testing)
		NSArray *checkForNextPage = [self doXpath:xpathTitlesUri forHtml:searchPostHtml];
		while (checkForNextPage && [checkForNextPage lastObject] != nil) {
			searchPostData = [self gleanInfoFromUrl:[displayTitlesUrlPfx stringByAppendingString:[checkForNextPage lastObject]] ContentDict:nil];
			searchPostHtml = [[[NSString alloc] initWithData:searchPostData encoding: NSASCIIStringEncoding] autorelease];
			[returnDict setValuesForKeysWithDictionary:[self parseSearchHtml:searchPostHtml startKeyNumber:[returnDict count]]];
			checkForNextPage = [self doXpath:xpathTitlesUri forHtml:searchPostHtml];
		};
	}
	
	return returnDict;
}

/*
 * returns a dictionary with all the values from the resultant search (title/time/url)
 */
- (NSDictionary*)parseSearchHtml:(NSString*) html startKeyNumber:(int)keyNumber{
	NSMutableDictionary *returnDict = nil;
	//debug
	//[self dumpXmlForHtml:html];
	NSMutableArray *titles = [self doXpath:xpathSearchTitles forHtml:html];
	NSMutableArray *urls = [self doXpath:xpathSearchUrls forHtml:html];
	NSMutableArray *times = [self doXpath:xpathSearchTimes forHtml:html];
	//	for (NSString *strDump in times) {
	//		NSLog(@"test: %@", strDump);
	//	}
	if ([titles count] > 0) {
		returnDict = [[NSMutableDictionary alloc] init]; //todo release?
		for (int i = 0; i < [titles count] ; i++) {
			//		for (NSString *title in titles) {
			NSMutableDictionary *titleDict = [[NSMutableDictionary alloc] init]; //todo release?
			[returnDict setObject:titleDict forKey:[[NSNumber alloc] initWithInt:i+keyNumber]];//todo release?
			[titleDict setObject:[titles objectAtIndex:i] forKey:@"title"];
			[titleDict setObject:[displayTitlesUrlPfx stringByAppendingString:[urls objectAtIndex:i]] forKey:@"url"];
			[titleDict setObject:[times objectAtIndex:i] forKey:@"time"];
		}
	}
	return returnDict;
}
/*
 * returns a dictionary with all the values from the resultant detail of a program 
 * title - has title of program
 * channel - has channel and rating
 * time - has time program airs
 * summary - has program summary text
 * inputs - contains form inputs needed to continue to scheduling
 * 
 */
- (NSDictionary*) getDetailForUrl:(NSString*) urlString {
	NSMutableDictionary *returnDict = nil;
	// get the search page
	NSData *data = [self gleanInfoFromUrl:urlString ContentDict:nil];
	// parse the response and get the _dynSessConf
	NSString *html = [[[NSString alloc] initWithData:data encoding: NSASCIIStringEncoding] autorelease];
	// need the new dynSessConf
	//[self parseDynSessConfFromHtml:html];
	if (currentSecureSession != nil) {
		[self dumpXmlForHtml:html];
		returnDict = [[[NSMutableDictionary alloc] init] autorelease];
		NSArray *titleArray = [self doXpath:xpathDetailTitle forHtml:html];
		if ([titleArray count] > 0) {		
			[returnDict setObject:[titleArray objectAtIndex:0] forKey:@"title"];
		}
		NSArray *channelAndRatingArray = [self doXpath:xpathDetailChannelAndRating forHtml:html];
		if ([channelAndRatingArray count] > 0) {
			[returnDict setObject:[channelAndRatingArray objectAtIndex:0] forKey:@"channel"];
		}			
		NSArray *airTimeArray = [self doXpath:xpathDetailAirTime forHtml:html];
		if ([airTimeArray count] > 0) {
			[returnDict setObject:[airTimeArray objectAtIndex:0] forKey:@"time"];
		}
		NSArray *summaryArray = [self doXpath:xpathDetailSummary forHtml:html];
		if ([summaryArray count] > 0) {
			[returnDict setObject:[summaryArray objectAtIndex:0] forKey:@"summary"];
		}
		NSMutableDictionary *dictionary = [self parseFormHtml:html forInputsByXpath:xpathLoginPageFormParse andInputValuesByXpath:xpathLoginPageFormParseImage
										 andImageInputByXpath:xpathLoginPageFormParseValues andImageInputValuesByXpath:xpathLoginPageFormParseImageValues];
		[returnDict setObject:dictionary forKey:@"inputs"];
	}
	return returnDict;
}

- (void) dumpXmlForHtml:(NSString*)html {
	htmlDocPtr htmlDoc = htmlParseDoc([html UTF8String], NULL);
	if (htmlDoc && htmlDoc->children) {
		// debugging the xml parse
		xmlChar *xmlCharMem;
		int sizeXml;
		xmlDocDumpFormatMemory(htmlDoc, &xmlCharMem, &sizeXml, 1);
		NSLog(@"full xml doc %@",[NSString stringWithCString:xmlCharMem]);
	}
	xmlFreeDoc(htmlDoc);
}

- (NSMutableArray*) doXpath:(NSString*) xpath forHtml:(NSString*) html {
	NSLog(@"doing an xpath!!!!  %@", xpath);
	NSMutableArray *resultStrings = [[[NSMutableArray alloc] init] autorelease];
	htmlDocPtr htmlDoc = htmlParseDoc([html UTF8String], NULL);
	if (htmlDoc && htmlDoc->children) {
		xmlInitParser();
		xmlXPathContextPtr xpathCtx = xmlXPathNewContext(htmlDoc);
		if(xpathCtx == NULL) {
			NSLog(@"could not initialize xpath context");
		} else {
			xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression([xpath UTF8String], xpathCtx);
			
			if(xpathObj == NULL) {
				NSLog(@"Error: unable to evaluate xpath expression \"%s\"", [xpath UTF8String]);
			} else {
				xmlNodeSetPtr nodeSet = xpathObj->nodesetval;
				int size = (nodeSet) ? nodeSet->nodeNr : 0;
				if (size > 0) {
					NSLog(@"got an xpath result ... size %d",size);
					//resultStrings = [[NSMutableArray alloc] init];// autorelease];
					for(int i = 0; i < size; ++i) {
						xmlNodePtr cur = nodeSet->nodeTab[i];
						if (cur->children->content) {
							[resultStrings addObject:[NSString stringWithCString:cur->children->content]];
							NSLog(@"found node %d %@", i,[NSString stringWithCString:cur->children->content]);
						} else if (cur->children) {
							NSString *lastOneMakesIt = nil;
							//NSLog(@"got children %@",[NSString stringWithCString:cur->children->name]);
							for (xmlNodePtr childNode = cur->children ; childNode ; childNode = childNode->next) {
								//NSLog(@"got child node %@", [NSString stringWithCString:childNode->name]);
								if (childNode->content) {
									NSLog(@"got child node %@",[NSString stringWithCString:childNode->content]);
									lastOneMakesIt = [NSString stringWithCString:childNode->content];
								}
							}
							if ([lastOneMakesIt hasPrefix:@"\n"] == YES) {
								lastOneMakesIt = [lastOneMakesIt substringFromIndex:3];
								NSLog(@"string starts with YES!");
							}
							[resultStrings addObject:lastOneMakesIt];
						} else if (cur->content) {
							NSLog(@"WTF found node %d %@", i,[NSString stringWithCString:cur->content]);
						} else {
							NSLog(@"WTF name of element: %@",[NSString stringWithCString:cur->name]);
						}
					}
				}
			}
			xmlXPathFreeContext(xpathCtx);
		}
	}
	xmlFreeDoc(htmlDoc);
	return resultStrings;
}

@end
