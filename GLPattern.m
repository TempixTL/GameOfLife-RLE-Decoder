#import "GLPattern.h"

@implementation GLPattern

- (instancetype) initWithWidth: (int)width andHeight: (int)height andBoard: (BOARD*)board {
	self = [super init];
	self.width = width;
	self.height = height;
	self.board = board;
	return self;
}

//Cool formatting for debug
- (NSString*) description {
	NSMutableString* str = [NSMutableString stringWithFormat: @"GLPattern: Name = %@\nCreator = %@\nRule = %@\nWidth = %d\nHeight = %d\n", self.name, self.creator, self.rule, self.width, self.height];
	for (int y = 0; y < self.height; y++) {
		NSMutableString* line = [NSMutableString stringWithCapacity: self.width];
		for (int x = 0; x < self.width; x++) {
			[line appendString: ((*self.board)[x][y]) ? @"1 " : @"0 "];
		}
		[line appendString: @"\n"];
		[str appendString: line];
	}
	return str;
}

//Enter the void. Empty, and become wind.
- (void) free {
	for (int x = 0; x < self.width; x++) {
		free((*self.board)[x]);
	}
	free((*self.board));
	free(self.board);
}

@end