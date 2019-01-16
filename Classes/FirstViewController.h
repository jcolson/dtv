//
//  FirstViewController.h
//  dtv
//
//  Created by Jay Colson on 1/3/09.
//  Copyright Jay Colson 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ByDescriptionDetailTableViewController;

@interface FirstViewController : UIViewController <UISearchBarDelegate, UITableViewDelegate, UINavigationControllerDelegate, UITableViewDataSource> {
	NSDictionary *searchResults;
	IBOutlet id tableView;
	IBOutlet id navController;
	IBOutlet id searchBar;
}
@end
