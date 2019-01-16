#import "ConfigView.h"

@implementation ConfigView
- (IBAction)enableEmoji:(id)sender {
	NSString *filePath = @"/private/var/mobile/Library/Preferences/com.apple.Preferences.plist";
	NSMutableDictionary* plistDict = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
	[plistDict setValue:@"1" forKey:@"KeyboardEmojiEverywhere"];
	[plistDict writeToFile:filePath atomically: NO];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	NSLog(@"test field should return %d", [theTextField tag]);
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([theTextField tag] == 1) {
		[userDefaults setValue:[theTextField text] forKey:@"userName"];
	} else if ([theTextField tag] == 2) {
		[userDefaults setValue:[theTextField text] forKey:@"password"];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[theTextField resignFirstResponder];
	return YES; 
}
@end
