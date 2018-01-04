#import <Foundation/Foundation.h>

typedef BOOL** BOARD;

//Game of Life Pattern
@interface GLPattern: NSObject
@property NSString* name;
@property NSString* creator;
@property NSString* rule;
@property int width;
@property int height;
@property BOARD* board;

- (instancetype) initWithWidth: (int)width andHeight: (int)height andBoard: (BOARD*)board;

- (NSString*) description;
- (void) free;

@end