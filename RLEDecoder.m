#import "RLEDecoder.h"

@implementation RLEDecoder

//Allocate memory for 2D array of booleans
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

//Parsing board data, actual RLE part
+ (BOARD*) parseBoardRLE: (NSString*)boardDataString
			WithBoardWidth: (int)width
			Height: (int)height {
	BOARD* board = [RLEDecoder mallocBoardOfWidth: width andHeight: height];
	
	int repeatCount = 0;
	int xPos = 0, yPos = 0;
	for (int i = 0; i < [boardDataString length]; i++) {
		unichar currentChar = [boardDataString characterAtIndex: i];
		
		if (currentChar >= '1' && currentChar <= '9') {
			repeatCount = (repeatCount * 10) + (currentChar - '0');
		} else if (currentChar == 'b' || currentChar == 'o') {
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
	
	return board;
}

//Parsing header line
//Format: "x = ???, y = ???, rule = B3/S23"
+ (void) parseHeaderLine: (NSString*)line
			ForWidth: (int*)width
			Height: (int*)height
			andRule: (NSString**)rule {
	NSArray* headerComps = [line componentsSeparatedByString: @","];
	
	*width = [[[headerComps objectAtIndex: 0] componentsSeparatedByString: @"="] lastObject].intValue;
	*height = [[[headerComps objectAtIndex: 1] componentsSeparatedByString: @"="] lastObject].intValue;
	if ([headerComps count] > 2) {
		*rule = [[[[headerComps objectAtIndex: 2] componentsSeparatedByString: @"="] lastObject] stringByTrimmingCharactersInSet: NSCharacterSet.whitespaceCharacterSet];
	}
}

//Heavy lifting function
+ (GLPattern*) readPatternInString: (NSString*)patternString {
	NSString* name, *creator, *rule;
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
			[RLEDecoder parseHeaderLine: line ForWidth: &width Height: &height andRule: &rule];
		} else { //Line is a part of the RLE pattern
			[boardDataString appendString: line];
		}
	}
	
	board = [RLEDecoder parseBoardRLE: boardDataString WithBoardWidth: width Height: height];
	
	//Build pattern and return
	GLPattern* pattern = [[GLPattern alloc] initWithWidth: width andHeight: height andBoard: board];
	pattern.name = name;
	pattern.creator = creator;
	pattern.rule = rule;
	return pattern;
}

+ (GLPattern*) readPatternInFileAtPath:(NSString *)path {
	NSString* patternString = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: nil];
	return [RLEDecoder readPatternInString: patternString];
}

@end
