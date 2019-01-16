#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DirecTVConnector.h"

@interface ByDescriptionDetailTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSDictionary *detailDict;
}

@property (nonatomic, retain) NSDictionary *detailDict;

- (void)populateDetailFromUrl:(NSString*)url;

@end
