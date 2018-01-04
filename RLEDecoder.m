#import "RLEDecoder.h"

@implementation RLEDecoder

//Heavy lifting function
+ (GLPattern*) readPatternInString: (NSString*)patternString {
	NSString* name;
	NSString* creator;
	NSString* rule;
	int width, height;
	BOARD* board;
	
	NSMutableString* boardDataString =[NSMutableString string];
	//Parsing header and comment data
	NSArray* lines = [patternString componentsSeparatedByString: @"\n"];
	for (NSString* untrimmedLine in lines) {
		NSString* line = [untrimmedLine stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
		if ([line length] == 0) continue;
		unichar firstChar = [line characterAtIndex: 0];
		
		if (firstChar == '#') { //If line is a comment
			unichar secondChar = [line characterAtIndex: 1];
			
			if (secondChar == 'O') { //Creator line
				creator = [[line substringFromIndex: 2] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
			} else if (secondChar == 'N') { //Name line
				name = [[line substringFromIndex: 2] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
			}
		} else if (firstChar == 'x') { //If line is the header
			NSArray* headerComponents = [line componentsSeparatedByString: @","];
			for (NSString* untrimmedHeaderComponent in headerComponents) {
				NSString* headerComponent = [untrimmedHeaderComponent stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
				unichar firstComponentChar = [headerComponent characterAtIndex: 0];
				
				if (firstComponentChar == 'x') {
					width = [[headerComponent componentsSeparatedByString: @"="] lastObject].intValue;
				} else if (firstComponentChar == 'y') {
					height = [[headerComponent componentsSeparatedByString: @"="] lastObject].intValue;
				} else if ([[headerComponent lowercaseString] containsString: @"rule"]) {
					rule = [[[headerComponent componentsSeparatedByString: @"="] lastObject] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
				}
			}
		} else {
			[boardDataString appendString: line];
		}
	}
	
	//Allocate memory for board
	board = [RLEDecoder mallocBoardOfWidth: width andHeight: height];
	
	//Parsing board data
	int repeatCount = 0;
	int xPos = 0, yPos = 0;
	for (int i = 0; i < [boardDataString length]; i++) {
		unichar currentChar = [boardDataString characterAtIndex: i];
		
		if (currentChar >= '1' && currentChar <= '9') repeatCount = (repeatCount * 10) + (currentChar - '0');
		else if (currentChar == 'b' || currentChar == 'o') {
			BOOL alive = (currentChar == 'o');
			
			for (int j = 0; j < MAX(repeatCount, 1); j++) (*board)[xPos + j][yPos] = alive;
			xPos += MAX(repeatCount, 1);
			repeatCount = 0;
		} else if (currentChar == '$') {
			xPos = 0;
			yPos += MAX(repeatCount, 1);
			repeatCount = 0;
		} else if (currentChar == '!') break;
	}
	
	//Build pattern and return
	GLPattern* pattern = [[GLPattern alloc] initWithWidth: width andHeight: height andBoard: board];
	if (name) pattern.name = name;
	if (creator) pattern.creator = creator;
	if (rule) pattern.rule = rule;
	return pattern;
}

+ (GLPattern*) readPatternInFileAtPath:(NSString *)path {
	NSString* patternString = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: nil];
	return [RLEDecoder readPatternInString: patternString];
}

+ (BOARD*) mallocBoardOfWidth: (int)width andHeight: (int)height {
	BOARD* board = malloc(sizeof(BOARD*));
	*board = malloc(sizeof(BOARD) * width);
	for (int x = 0; x < width; x++) {
		(*board)[x] = malloc(sizeof(BOOL*) * height);
		for (int y = 0; y < height; y++) {
			(*board)[x][y] = false;
		}
	}
	
	return board;
}

@end