#import <Foundation/Foundation.h>

@interface FTSWAbstractSingleton : NSObject {
}
+ (id)singleton;
+ (id)singletonWithZone:(NSZone*)zone;

//designated initializer, subclasses must implement and call supers implementation
- (id)initSingleton; 
@end