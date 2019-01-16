//
//  FirstViewController.m
//  dtv
//
//  Created by Jay Colson on 1/3/09.
//  Copyright Jay Colson 2009. All rights reserved.
//

#import "FirstViewController.h"
#import "DirecTVConnector.h"
#import "ByDescriptionDetailTableViewController.h"

@implementation FirstViewController

/**
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	// CANT GET THIS TO F'IN WORK
	//return nil;
	NSLog(@"initWithNibName called");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		detailController = [[ByDescriptionDetailTableViewController alloc] initWithNibName:@"ByDescriptionDetailView" bundle:nil];
		//DirecTVConnector *dtvCon = [DirecTVConnector initWithUsername:@"username" Password:@"pass"];
		// Custom initialization
	}
	return self;
}
*/

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	NSLog(@"************************************Got memory warning!");
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
	// should dealloc dtv singleton?
	[searchResults dealloc];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)incomingSearchBar {
	NSLog(@"Search Button Clicked");
	if (searchBar == incomingSearchBar) {
		DirecTVConnector *dtvCon = [DirecTVConnector sharedDirecTVConnector];
		if ( dtvCon != nil) {
			if ( [dtvCon isLoggedIn] == NO ) {
				NSLog(@"isn't logged in");
				NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
				NSString *userName = [userDefaults valueForKey:@"userName"];
				NSString *password = [userDefaults valueForKey:@"password"];
				if ( userName == nil || password == nil) {
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" 
																	message:@"Make sure to set your username and password first"
																   delegate:nil 
														  cancelButtonTitle:@"OK" 
														  otherButtonTitles: nil];
					[alert show];
					[alert release];
				} else {
					NSString *loginMessage = [dtvCon loginWithUsername:userName Password:password];
					if ( loginMessage != nil ) {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Logged In" 
																		message:loginMessage
																	   delegate:nil 
															  cancelButtonTitle:@"OK" 
															  otherButtonTitles: nil];
						[alert show];
						[alert release];
					}
				}
			} 
			// check again -- hopefully is logged in now
			if ( [dtvCon isLoggedIn] == YES) {
				NSLog(@"is already logged in");
				if (searchResults != nil) {
					[searchResults release];
				}
				searchResults = [dtvCon searchContent:[searchBar text]];
			}
			
		}
		[tableView reloadData];
		[searchBar resignFirstResponder];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)incomingSearchBar {
	[incomingSearchBar resignFirstResponder];
}

- (UITableViewCell *)tableView:(UITableView *)incomingTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *uiCell = [[[UITableViewCell alloc] init] autorelease];
	NSLog(@"table cellforrowatindexpath got called");
	if (incomingTableView == tableView) {		
//		uiCell = [[[UITableViewCell alloc] init] autorelease];
		//	UILabel *uiLabel = [[[UILabel alloc] init] autorelease];
		NSNumber *nsNumRow = [NSNumber numberWithInt:[indexPath row]];
		//[[[NSNumber alloc] initWithInt:[indexPath row]] autorelease];
		NSString *title = [[searchResults objectForKey:nsNumRow] objectForKey:@"title"];
		NSString *time = [[searchResults objectForKey:nsNumRow] objectForKey:@"time"];
		NSString *textForCell = [title stringByAppendingString:time];
		//	[uiLabel setText:textForCell];
		//	[uiCell addSubview:uiLabel];
		[uiCell setText:textForCell];	
	}
	return uiCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (searchResults) {
		NSLog(@"table view got called %d", [searchResults count]);
		return [searchResults count];
	} else {
		return 0;
	}
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)incomingViewController animated:(BOOL)animated {
	if (navigationController == navController) {
		if (self == incomingViewController) {
			[navController setNavigationBarHidden:YES animated:NO];
			[searchBar setHidden:NO];
		} else if ([ByDescriptionDetailTableViewController class] == [incomingViewController class]) {
			[navController setNavigationBarHidden:NO animated:NO];
			[searchBar setHidden:YES];
		}
	}
	/*
	 if (incomingViewController == self) {
	 // hide the nav controller again
	 [navController setNavigationBarHidden:YES animated:YES];
	 // unselect the previous selected row
	 [[tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]] setSelected:NO];
	 }
	 }
	 */
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)incomingViewController animated:(BOOL)animated {
	NSLog(@"didShowViewController");
	if (navigationController == navController) {
		if (incomingViewController == self) {
			// hide the nav controller again
			//			[navController setNavigationBarHidden:YES animated:YES];
			//			[searchBar setHidden:NO];
			// unselect the previous selected row
			[[tableView cellForRowAtIndexPath:[tableView indexPathForSelectedRow]] setSelected:NO];
		}
	}
}

- (void)tableView:(UITableView *)incomingTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ByDescriptionDetailTableViewController *detailController = [[ByDescriptionDetailTableViewController alloc] initWithNibName:@"ByDescriptionDetailView" bundle:nil];

	//	[searchBar setHidden:YES];
	//	[navController setNavigationBarHidden:NO animated:NO];
	// tell controller to get data
	NSNumber *nsNumRow = [[[NSNumber alloc] initWithInt:[indexPath row]] autorelease];
	NSString *url = [[searchResults objectForKey:nsNumRow] objectForKey:@"url"];
    [detailController populateDetailFromUrl:url];
	//[detailController setTitle:@"THIS IS A TEST"];
	//[navController pushViewController:[[TestTableViewController alloc]init] animated:NO];
	[navController pushViewController:detailController animated:NO];
	[detailController release];
}

@end
