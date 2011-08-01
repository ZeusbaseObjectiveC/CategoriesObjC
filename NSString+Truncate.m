#import "NSString+Truncate.h"

@implementation NSString (Truncate)

- (NSAttributedString *)attributedStringWithTruncationStyle:(int)truncationStyle {
	NSMutableString* text = [self mutableCopy];
	NSAttributedString* s = [NSAttributedString alloc];
	NSMutableParagraphStyle *ps = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	if ([ps respondsToSelector:@selector(setLineBreakMode:)]) {  // 10.3 does not
		[ps setLineBreakMode:truncationStyle];
	}
	s = [s initWithString: text attributes:[NSDictionary dictionaryWithObjectsAndKeys:
											ps, NSParagraphStyleAttributeName, nil]];
	[text release];
	[ps release];
	return [s autorelease];
}

- (NSString*)stringByTruncatingMiddleToLength:(int)limit 
								   wholeWords:(BOOL)wholeWords {
	int length = [self length] ;
	NSString* answer ;
	if (length <= limit) {
		answer = self ;
	}
	else if (limit > 0) {
		NSInteger ellipsisAllowance = 3 ;
		NSInteger limitNotIncludingEllipsis = limit - ellipsisAllowance ;
		BOOL done = NO ;
		if (wholeWords) {
			NSMutableArray* words = [[self componentsSeparatedByString:@" "] mutableCopy] ;
			// Keep removing the word which is at approximately 2/3 of the way
			// through the string until we're under the limit
			NSInteger newLength = length ;
			while ([words count] > 1) {
				NSInteger targetIndex = [words count]*2/3 ;
				NSString* removedWord = [words objectAtIndex:targetIndex] ;
				[words removeObjectAtIndex:targetIndex] ;
				newLength -= ([removedWord length] + 1) ;
				// In the above, the +1 is to remove the space between the
				// removed word and the next word
				if (newLength <= limitNotIncludingEllipsis) {
					done = YES ;
					NSInteger priorIndex = (targetIndex - 1) ;
					NSString* priorWord = [words objectAtIndex:priorIndex] ;
					NSString* ending ;
					BOOL ellipsisWillBeAtEnd = ([words count] >= targetIndex) ;
					if (ellipsisWillBeAtEnd) {
						ending = @"" ;
					}
					else {
						// There will be words after the ellipsis
						ending = [NSString stringWithFormat:
								  @" %@",
								  [words objectAtIndex:targetIndex]] ;
					}
					NSString* truncation = [NSString stringWithFormat:
											@"%@ \u2026%@",
											priorWord,
											ending] ;											
					[words replaceObjectAtIndex:priorIndex
									 withObject:truncation] ;
					if (!ellipsisWillBeAtEnd) {
						[words removeObjectAtIndex:targetIndex] ;
					}
					answer = [words componentsJoinedByString:@" "] ;
					break ;
				}
			}
			[words release] ;
		}
		
		if (!done) {
			int endLength = limitNotIncludingEllipsis/3 ;
			int beginLength = limit - endLength - 1 ;  // reserve 1 for the ellipsis
			int endLocation = length - endLength ;
			NSRange endRange = NSMakeRange(endLocation, endLength) ;
			answer = [NSString stringWithFormat:@"%@%C%@",
					  [self substringToIndex:beginLength],
					  0x2026,
					  [self substringWithRange:endRange]] ;
		}
	}
	else {
		answer = @"" ;
	}
	
	return answer ;
}

@end
