#import "ByDescriptionDetailTableViewController.h"

@implementation ByDescriptionDetailTableViewController
@synthesize detailDict;

- (void)populateDetailFromUrl:(NSString*)urlString {
	NSLog(@"populateDetailFromUrl");
	self.detailDict = [[DirecTVConnector sharedDirecTVConnector] getDetailForUrl:urlString];
	NSLog(@"got detailDict -- reloadingData");
	//	[byDescriptionTableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)incomingTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"BEGIN incomingTableView");
	UITableViewCell *uiCell;
	//if (incomingTableView == byDescriptionTableView) {	
	
	NSLog(@"tableView did equal");	
	uiCell = [[[UITableViewCell alloc] init] autorelease];
	//NSNumber *nsNumRow = [[[NSNumber alloc] initWithInt:[indexPath row]] autorelease];
	//		NSString *title = [[searchResults objectForKey:nsNumRow] objectForKey:@"title"];
	//		NSString *time = [[searchResults objectForKey:nsNumRow] objectForKey:@"time"];
	id value = [[self.detailDict allKeys] objectAtIndex:[indexPath row]];
	NSString *textForCell = @"DEBUG DATA";
	if ([[self.detailDict objectForKey:value] isKindOfClass:[NSString class]]) {
		textForCell = [self.detailDict objectForKey:value];
	}
	//	[uiLabel setText:textForCell];
	//	[uiCell addSubview:uiLabel];
	[uiCell setText:textForCell];	
	//	}
	
	NSLog(@"END incomingTableView");
	return uiCell;
}

- (NSInteger)tableView:(UITableView *)incomingTableView numberOfRowsInSection:(NSInteger)section {
	if (self.detailDict && [self.detailDict allKeys]) {
		NSLog(@"by desc detail table view got called");
		return [[self.detailDict allKeys] count];
	} else {
		NSLog(@"detailDict must be nil?");
		return 0;
	}
}
@end
