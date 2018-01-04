#import <Foundation/Foundation.h>
#import "GLPattern.h"
#import "RLEDecoder.h"

//Change this to whatever .rle file supported by Game of Life
//More files can be found at http://conwaylife.com/wiki/
NSString* path = @"./TestFiles/glider.rle";

int main(int argc, char *argv[]) {
	@autoreleasepool {
		GLPattern* pattern = [RLEDecoder readPatternInFileAtPath: path];
		NSLog(@"%@", pattern);
	}
	
	return 0;
}
