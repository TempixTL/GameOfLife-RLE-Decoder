#import <Foundation/Foundation.h>
#import "GLPattern.h"

//"Run Length Encoded" Decoder
@interface RLEDecoder: NSObject

+ (GLPattern*) readPatternInString: (NSString*)patternString;
+ (GLPattern*) readPatternInFileAtPath: (NSString*)path;

@end