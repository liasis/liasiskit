/**
 * \file PLFormatter.m
 * \brief Liasis Python IDE text formatting manager.
 *
 * \details
 *
 * \copyright Copyright (C) 2012-2014 Jason Lomnitz and Danny Nicklas.
 *
 * This file is part of the Python Liasis IDE.
 *
 * The Python Liasis IDE is free software: you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The Python Liasis IDE is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with the Python Liasis IDE. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import "PLFormatter.h"

#pragma mark Formatter Strings and Patterns

/**
 * \details A string constant defining the string that is used during tab auto-
 *          indentation to determine the level of indentation.
 */
NSString * const PLFormatterIndentationString = @"    ";

/**
 * \details A string constant defining the string that is used to comment out a
 *          section of code without the block flag.
 */
NSString * const PLFormatterCommentString = @"# ";

/**
 * \details A string constant defining the string that is used to comment out a
 *          block of code.
 */
NSString * const PLFormatterCommentBlockString = @"## ";

/**
 * \details A string constant defining the pattern for a line ending in a colon.
 *          The colon character must not be within an enclosing string, or within an
 *          open string.
 */
NSString * const PLFormatterPatternEndingColon = @"(\"[^\"]*\"|'[^']*'|[^\"'])*:\\s*";


/**
 * \details A string constant defining the pattern for a line containing an return
 *          or yield statement.
 */
NSString * const PLFormatterPatternReturnYield = @"\\s+(return|yield)(\\([^\\)]*\\)|[^\\(]*)\\s*";

/**
 * \details A string constant defining the pattern for a line ending in a comma,
 *          'or', 'and', '|' or '&'. The ending pattern must not be within an
 *          enclosing string, or within an open string.
 */
NSString * const PLFormatterPatternLineContinuation = @".*(,|or|and|\\||\\&)\\s*";

/**
 * \details A string constant defining the pattern for a line ending in a ending
 *          bracket - includes ')', ']' and '}'. The pattern excludes brackets
 *          that have a matching opening bracket within the same line.
 */
NSString * const PLFormatterPatternEndingBracket = @"[^\\(\\[\\{]*([^\\(]*\\)|[^\\[]*\\]|[^\\{]*\\})\\s*";

/**
 * \details A string constant defining the pattern for a line containing and
 *          opening bracket - includes '(', '[' and '{'. The pattern excludes
 *          brackets that have a matching closing bracket within the same line.
 */
NSString * const PLFormatterPatternOpenBracket = @".*[\\(\\[\\{]\\s*";


#pragma mark - Utility Functions (Prototypes)

/**
 * \brief Function to identify the outermost closing bracket, and search for its
 *        corresponding opening bracket.
 *
 * \details Function searches the previous line for the outermost closing bracket
 *          not opened on the same line. Then, searches the preceeding lines for 
 *          its matching opening bracket.
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSUInteger lineWithBracket The index of a character in the line for 
 *                                   which the proper indentation is being
 *                                   identified.
 *
 * \return NSUInteger If a opening bracket was found for a closing bracket, 
 *                    returns the index of the opening bracket. Otherwise,
 *                    returns NSNotFound.
 */
static NSUInteger characterIndexForMatchingBracket(NSString * text, NSUInteger lineWithBracket);

/**
 * \brief Function to find the outermost closing bracket.
 *
 * \details Function searches the current line for the outermost closing
 *          bracket that does not have a corresponding opening bracket.
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSUInteger startingCharacter  The index of a character in the line for
 *                                      which the proper indentation is being 
 *                                      identified.
 *
 * \return NSUInteger If a opening bracket was found without it's corresponding
 *                    closing bracket, returns the index of the opening bracket.
 *                    Otherwise, returns NSNotFound.
 */
static NSUInteger characterIndexForOutermostClosingBracket(NSString * text, NSUInteger startingCharacter);

/**
 * \brief Function to check if line in text matches a pattern exactly.
 *
 * \details Function checks if a line matches exactly a pattern described
 *          using a string with regular expressions.
 *
 * \param NSString pattern An instance of a NSString object that contains a 
 *                         regular expression describing the pattern that is 
 *                         being queried.
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSRange lineRange The range of characters that define the line that 
 *                          will be checked for the designated pattern.
 *
 * \return BOOL If the characters in the text within the line range match the
 *              pattern, function returns YES. Otherwise, function returns NO.
 */
static BOOL lineInTextMatchesPattern(NSString * pattern, NSString * text, NSRange lineRange);

/**
 * \brief Function to check if line contains only whitespace characters.
 *
 * \details Function finds the range of non-whitespace characters on the line
 *          containing the specified index using the inverted NSCharacterSet
 *          whitespaceAndNewlineCharacterSet. It returns YES if the location
 *          of the resulting range is NSNotFound.
 *
 * \param text The string to check if a particular line is only whitespace.
 *
 * \param index The index of the line to test.
 *
 * \return If the line contains only whitespace characters, return YES.
 *         Otherwise, return NO.
 */
static BOOL isLineOnlyWhitespace(NSString * text, NSUInteger index);

#pragma mark Utility Functions (Implementation)

static NSUInteger characterIndexForMatchingBracket(NSString * text, NSUInteger lineWithBracket)
{
        NSInteger index = NSNotFound, position;
        char character, closingBracket;
        position = characterIndexForOutermostClosingBracket(text, lineWithBracket);
        if (position == NSNotFound)
                goto exit;
        closingBracket = [text characterAtIndex:position];
        index = [PLFormatter characterIndexForNextOpenBracket:text fromIndex:position];
        if (index != NSNotFound) {
                character = [text characterAtIndex:index];
                switch (closingBracket) {
                        case ')':
                                if (character != '(')
                                        index = NSNotFound;
                                break;
                        case ']':
                                if (character != '[')
                                        index = NSNotFound;
                                break;
                        case '}':
                                if (character != '{')
                                        index = NSNotFound;
                                break;
                        default:
                                index = NSNotFound;
                                break;
                }
        }
exit:
        return index;
}

static NSUInteger characterIndexForOutermostClosingBracket(NSString * text, NSUInteger startingCharacter)
{
        NSInteger index = NSNotFound, position;
        NSInteger parenLevel = 0, curlyLevel = 0, squareLevel = 0, qLevel = 0, qdLevel = 0;
        char character;
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(startingCharacter, 0)];
        position = lineRange.location-1;
        while (position < NSMaxRange(lineRange)-1) {
                position++;
                character = [text characterAtIndex:position];
                /* Check for characters within quotes or within doc strings */
                switch (character) {
                        case '\'':
                                if (qdLevel == 0)
                                        qLevel = (qLevel + 1) % 2;
                                break;
                        case '"':
                                if (qLevel == 0)
                                        qdLevel = (qdLevel + 1) % 2;
                                break;
                        default:
                                break;
                }
                if (qLevel != 0 || qdLevel != 0)
                        continue;
                switch (character) {
                        case '(':
                                parenLevel--;
                                break;
                        case '[':
                                squareLevel--;
                                break;
                        case '{':
                                curlyLevel--;
                                break;
                        case ')':
                                parenLevel++;
                                if (parenLevel >= 1)
                                        index = position;
                                break;
                        case ']':
                                squareLevel++;
                                if (squareLevel >= 1)
                                        index = position;
                                break;
                        case '}':
                                curlyLevel++;
                                if (curlyLevel >= 1)
                                        index = position;
                                break;
                        default:
                                break;
                }
        }
exit:
        return index;
}

static BOOL lineInTextMatchesPattern(NSString * pattern, NSString * text, NSRange lineRange)
{
        BOOL lineMatches = NO;
        NSRegularExpression * patternRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                       options:0
                                                                                         error:nil];

        lineMatches = NSEqualRanges([patternRegex rangeOfFirstMatchInString:text
                                                                    options:NSMatchingReportCompletion
                                                                      range:lineRange],
                                    lineRange);
        return lineMatches;
}

static BOOL isLineOnlyWhitespace(NSString * text, NSUInteger index)
{
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
        NSRange nonWhitespaceRange = [text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]
                                                           options:0
                                                             range:lineRange];
        return nonWhitespaceRange.location == NSNotFound;
}

#pragma mark -

@implementation PLFormatter

@synthesize previousEntry;
@synthesize previousEntryLocation;

-(BOOL)didFormatTextView:(NSTextView *)textView withReplacementString:(NSString *)replacementString inRange:(NSRange)affectedRange
{
        if ([replacementString isEqualToString:@"\t"])
                return [self didFormatAfterTab:textView withReplacementString:replacementString inRange:affectedRange];
        else if ([replacementString isEqualToString:@"\n"] && [[textView string] length] > 1)
                return [PLFormatter didFormatAfterNewline:textView withReplacementString:replacementString inRange:affectedRange];
        return NO;
}

+(NSString *)indentationStringOfText:(NSString *)text atIndex:(NSUInteger)index
{
        return [PLFormatter indentationStringWithLength:[PLFormatter indentationLocationOfString:text atIndex:index]];
}

+(NSUInteger)characterIndexForNextOpenBracket:(NSString *)text fromIndex:(NSUInteger)startingCharacter
{
        NSUInteger index = NSNotFound, position;
        NSInteger parenLevel = 0, curlyLevel = 0, squareLevel = 0, qLevel = 0, qdLevel = 0;
        BOOL foundOpenBracket = NO;
        char character;
        position = startingCharacter;
        while (position > 0) {
                position--;
                character = [text characterAtIndex:position];
                /* Check for characters within quotes or within doc strings */
                switch (character) {
                        case '\'':
                                if (qdLevel == 0)
                                        qLevel = (qLevel + 1) % 2;
                                break;
                        case '"':
                                if (qLevel == 0)
                                        qdLevel = (qdLevel + 1) % 2;
                                break;
                        default:
                                break;
                }
                if (qLevel != 0 || qdLevel != 0)
                        continue;
                switch (character) {
                        case ')':
                                parenLevel++;
                                break;
                        case ']':
                                squareLevel++;
                                break;
                        case '}':
                                curlyLevel++;
                                break;
                        case '(':
                                parenLevel--;
                                if (parenLevel == -1) {
                                        foundOpenBracket = YES;
                                        break;
                                }
                                break;
                        case '[':
                                squareLevel--;
                                if (squareLevel == -1) {
                                        foundOpenBracket = YES;
                                        break;
                                }
                                break;
                        case '{':
                                curlyLevel--;
                                if (curlyLevel == -1) {
                                        foundOpenBracket = YES;
                                        break;
                                }
                                break;
                        default:
                                break;
                }
                if (foundOpenBracket) {
                        index = position;
                        break;
                }
        }
        return index;
}

#pragma mark Indenting

+(void)increaseIndentationInSelection:(NSTextView *)textView
{
        NSRange selectedRange, firstLineRange;
        NSUInteger firstIndentationPosition;
        __block NSUInteger modifiedPosition;
        NSArray * indentationPositions;
        
        selectedRange = [textView selectedRange];
        indentationPositions = [PLFormatter indentationLocationOfLines:[textView string] inRange:selectedRange];
        firstIndentationPosition = [[indentationPositions objectAtIndex:0] unsignedIntegerValue];
        firstLineRange = [[textView string] lineRangeForRange:NSMakeRange(firstIndentationPosition, 0)];
        
        /* Increase indentation level of each line. */
        [[textView textStorage] beginEditing];
        [indentationPositions enumerateObjectsUsingBlock:^(NSNumber * indentationPosition, NSUInteger index, BOOL * stop) {
                modifiedPosition = [indentationPosition unsignedIntegerValue] + [PLFormatterIndentationString length] * index;
                [[textView textStorage] replaceCharactersInRange:NSMakeRange(modifiedPosition, 0)
                                                      withString:PLFormatterIndentationString];
        }];
        [[textView textStorage] endEditing];
        
        /* Modify selection after indentation shift. */
        if (selectedRange.location == firstLineRange.location && selectedRange.length > 0)
                selectedRange.length += [PLFormatterIndentationString length];
        else if (selectedRange.location < firstIndentationPosition) {
                if (selectedRange.location + selectedRange.length <= firstIndentationPosition)
                        selectedRange.length = 0;
                else
                        selectedRange.length -= (firstIndentationPosition - selectedRange.location);
                selectedRange.location = firstIndentationPosition + [PLFormatterIndentationString length];
        } else
                selectedRange.location += [PLFormatterIndentationString length];
        selectedRange.length += ([PLFormatterIndentationString length] * ([indentationPositions count] - 1));
        
        [textView setSelectedRange:selectedRange];
}

+(void)decreaseIndentationInSelection:(NSTextView *)textView
{
        NSRange selectedRange, lineRange, firstLineRange;
        NSUInteger totalDeletionLength = 0, firstLineDeletionLength = 0, firstIndentationPosition = 0, deletionLength = 0, modifiedPosition = 0;
        NSArray * indentationPositions = nil;
        
        selectedRange = [textView selectedRange];
        indentationPositions = [PLFormatter indentationLocationOfLines:[textView string] inRange:selectedRange];
        firstIndentationPosition = [[indentationPositions objectAtIndex:0] unsignedIntegerValue];
        firstLineRange = [[textView string] lineRangeForRange:NSMakeRange(firstIndentationPosition, 0)];
        totalDeletionLength = 0;
        firstLineDeletionLength = 0;
        
        /* Decrease indentation level of each line. */
        [[textView textStorage] beginEditing];
        for (NSNumber * indentationPosition in indentationPositions) {
                modifiedPosition = [indentationPosition unsignedIntegerValue] - totalDeletionLength;
                lineRange = [[textView string] lineRangeForRange:NSMakeRange(modifiedPosition, 0)];
                
                if (modifiedPosition - lineRange.location >= [PLFormatterIndentationString length])
                        deletionLength = [PLFormatterIndentationString length];
                else if ([indentationPosition unsignedIntegerValue] > 0)
                        deletionLength = modifiedPosition - lineRange.location;
                
                [[textView textStorage] deleteCharactersInRange:NSMakeRange(lineRange.location, deletionLength)];
                if (firstLineDeletionLength == 0)
                        firstLineDeletionLength = deletionLength;
                totalDeletionLength += deletionLength;
        }
        [[textView textStorage] endEditing];
        
        /* Modify selection after indentation shift. */
        if (selectedRange.location == firstLineRange.location && selectedRange.length > 0)
                selectedRange.length -= firstLineDeletionLength;
        else if (selectedRange.location < firstIndentationPosition) {
                if (selectedRange.location + selectedRange.length <= firstIndentationPosition)
                        selectedRange.length = 0;
                else
                        selectedRange.length -= (firstIndentationPosition - selectedRange.location);
                selectedRange.location = firstIndentationPosition - firstLineDeletionLength;
        } else
                selectedRange.location -= firstLineDeletionLength;
        selectedRange.length -= (totalDeletionLength - firstLineDeletionLength);
        
        [textView setSelectedRange:selectedRange];
}

#pragma mark Commenting

+(void)toggleCommentSelection:(NSTextView *)textView asBlock:(BOOL)commentBlock
{
        NSMutableArray * commentedPositions, * uncommentedPositions;
        NSArray * indentationPositions, * insertionPositions;
        NSUInteger minIndentationLevel, indentationLevel, lineStartIndex, bufferLength;
        NSString * text, * commentString, * lineString;
        NSTextStorage * textStorage;
        __block NSUInteger modifiedPosition;
        __block NSRange selectedRange, lineRange;
        
        if (commentBlock)
                commentString = PLFormatterCommentBlockString;
        else
                commentString = PLFormatterCommentString;
        
        text = [textView string];
        textStorage = [textView textStorage];
        commentedPositions = [NSMutableArray new];
        uncommentedPositions = [NSMutableArray new];
        selectedRange = [textView selectedRange];
        indentationPositions = [PLFormatter indentationLocationOfLines:text inRange:selectedRange];
        minIndentationLevel = NSNotFound;
        [textStorage beginEditing];
        
        /* Find minimum indentation level */
        for (NSNumber * indentationPosition in indentationPositions) {
                lineRange = [text lineRangeForRange:NSMakeRange([indentationPosition unsignedIntegerValue], 0)];
                indentationLevel = [indentationPosition unsignedIntegerValue] - lineRange.location;
                
                if (isLineOnlyWhitespace(text, lineRange.location) == NO &&
                    (minIndentationLevel == NSNotFound || indentationLevel < minIndentationLevel))
                        minIndentationLevel = indentationLevel;
        }
        if (minIndentationLevel == NSNotFound)
                minIndentationLevel = 0;
        
        /* Determine which lines are commented and save the starting position to add/remove comment string */
        for (NSNumber * indentationPosition in indentationPositions) {
                lineRange = [text lineRangeForRange:NSMakeRange([indentationPosition unsignedIntegerValue], 0)];
                lineString = [text substringWithRange:lineRange];
                lineStartIndex = lineRange.location + minIndentationLevel;
                
                if ([lineString length] < [commentString length] ||
                    minIndentationLevel + [commentString length] > [lineString length] ||
                    [[lineString substringWithRange:NSMakeRange(minIndentationLevel, [commentString length])] isEqualToString:commentString] == NO) {
                        [uncommentedPositions addObject:[NSNumber numberWithLong:lineStartIndex]];
                        
                        /* Buffer short whitespace-only lines to length minIndentationLevel.
                         * Note: this results in added whitespace after toggling comments off. */
                        if (lineRange.length - 1 < minIndentationLevel && isLineOnlyWhitespace(text, lineRange.location)) {
                                bufferLength = minIndentationLevel - (lineRange.length - 1);
                                [textStorage replaceCharactersInRange:NSMakeRange(lineRange.location, 0)
                                                           withString:[PLFormatter indentationStringWithLength:bufferLength]];
                                selectedRange.length += bufferLength;
                        }
                }
                
                else
                        [commentedPositions addObject:[NSNumber numberWithLong:lineStartIndex]];
        }
        
        /* Add or remove comment strings */
        if ([uncommentedPositions count] == 0) {
                [commentedPositions enumerateObjectsUsingBlock:^(NSNumber * position, NSUInteger index, BOOL * stop) {
                        modifiedPosition = [position unsignedIntegerValue] - ([commentString length] * index);
                        [textStorage deleteCharactersInRange:NSMakeRange(modifiedPosition, [commentString length])];
                        
                        if (selectedRange.location <= modifiedPosition && selectedRange.location + selectedRange.length > modifiedPosition) {
                                if (selectedRange.length < [commentString length])
                                        selectedRange.length = 0;
                                else
                                        selectedRange.length -= [commentString length];
                        }
                        else if (selectedRange.location >= [commentString length] && selectedRange.location >= modifiedPosition)
                                selectedRange.location -= [commentString length];
                }];
        } else {
                if (commentBlock) {
                        insertionPositions = [commentedPositions arrayByAddingObjectsFromArray:uncommentedPositions];
                        insertionPositions = [insertionPositions sortedArrayUsingComparator: ^(NSNumber * a, NSNumber * b) {
                                return [a compare:b];
                        }];
                } else
                        insertionPositions = uncommentedPositions;
                [insertionPositions enumerateObjectsUsingBlock:^(NSNumber * position, NSUInteger index, BOOL * stop) {
                        lineRange = [text lineRangeForRange:NSMakeRange([position unsignedIntegerValue], 0)];
                        modifiedPosition = [position unsignedIntegerValue] + ([commentString length] * index);
                        [textStorage replaceCharactersInRange:NSMakeRange(modifiedPosition, 0) withString:commentString];
                        
                        if (selectedRange.location <= modifiedPosition && selectedRange.location + selectedRange.length > modifiedPosition)
                                selectedRange.length += [commentString length];
                        else if (selectedRange.location >= modifiedPosition)
                                selectedRange.location += [commentString length];
                }];
        }
        
        [textStorage endEditing];
        [textView setSelectedRange:selectedRange];
        [commentedPositions release];
        [uncommentedPositions release];
}

#pragma mark - Private Methods -

#pragma mark Input handling

/**
 * \brief Automatically indent the next line after a newline character input.
 *
 * \details After a user enters a newline character, the next line is indented
 *          to the proper location as determiend by the PLFormatter method
 *          indentationLocationInText:atIndex. If no indentation is required,
 *          return NO, allowing the newline to be entered as normal.
 *
 * \param textView The NSTextView to format.
 *
 * \param replacementString The string that was entered by the user into the
 *                          text view.
 *
 * \param affectedRange The range of the replacement string.
 *
 * \return A boolean specifying if formatting was performed.
 */
+(BOOL)didFormatAfterNewline:(NSTextView *)textView withReplacementString:(NSString *)replacementString inRange:(NSRange)affectedRange
{
        NSUInteger indentationLocation = NSNotFound;
        NSMutableString * searchString = [NSMutableString stringWithString:[textView string]];
        [searchString insertString:@"\n" atIndex:affectedRange.location];
        NSUInteger index = affectedRange.location;
        indentationLocation = [PLFormatter indentationLocationInText:searchString atIndex:index+1];
exit:
        if (indentationLocation == NSNotFound || indentationLocation == 0)
                return NO;
        else {
                [textView insertText:[replacementString stringByAppendingString:[PLFormatter indentationStringWithLength:indentationLocation]]
                    replacementRange:[textView selectedRange]];
                return YES;
        }
}

/**
 * \brief Use the tab character to indent to proper indentation level.
 *
 * \details The tab character is never entered literally. Pressing tab does one
 *          of the following, depending on the situation:
 *
 *          1) If inside a nested function/class definition, indent to proper
 *             location (i.e. four spaces inside the definition declaration).
 *          2) If past the proper indentation location, delete whitespace until
 *             at the proper indentation location.
 *          3) If at the proper indentation location, delete one level
 *             backwards.
 *          4) If at or inside the proper indentation location and the previous
 *             character entered was a tab on the same line, cycle backwards by
 *             one level until reaching zero on the line, then jump to the
 *             proper indentation location. If at a non-integer multiple of the
 *             proper indentation level, delete until reaching the first
 *             multiple (e.g. if at location 7 on the line, delete to 4).
 *          5) If on first line or any of the current line contains
 *             non-whitespace characters, insert four spaces.
 *
 * \param textView The NSTextView to format.
 *
 * \param replacementString The string that was entered by the user into the
 *                          text view.
 *
 * \param affectedRange The range of the replacement string.
 *
 * \return A boolean specifying if formatting was performed.
 */
-(BOOL)didFormatAfterTab:(NSTextView *)textView withReplacementString:(NSString *)replacementString inRange:(NSRange)affectedRange
{
        NSRange lineRange = [[textView string] lineRangeForRange:affectedRange];
        NSUInteger properIndentationLocation;
        properIndentationLocation = [PLFormatter indentationLocationInText:[textView string] atIndex:affectedRange.location];
        
        NSUInteger deleteLength, indentationToProperLocation;
        NSString * currentLineString = [[textView string] substringWithRange:lineRange];
        NSUInteger currentLocationInLine = affectedRange.location - lineRange.location;
        NSUInteger nonWhiteSpaceLocation = [currentLineString rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]].location;
        if (nonWhiteSpaceLocation != NSNotFound)
                currentLocationInLine = nonWhiteSpaceLocation;

        NSRange previousEntryRange;
        if (previousEntryLocation >= [[textView string] length])
                previousEntryRange = NSMakeRange([[textView string] length], 0);
        else
                previousEntryRange = NSMakeRange(previousEntryLocation, 0);
        NSRange previousEntryLine = [[textView string] lineRangeForRange:previousEntryRange];
        NSRange affectedLine = [[textView string] lineRangeForRange:affectedRange];
        
        if ([previousEntry isEqualToString:@"\t"] &&
            affectedLine.location == previousEntryLine.location &&
            currentLocationInLine > 0) {
                deleteLength = currentLocationInLine % [PLFormatterIndentationString length];
                if (deleteLength == 0)
                        deleteLength = [PLFormatterIndentationString length];
                [textView insertText:@""
                    replacementRange:NSMakeRange(lineRange.location + currentLocationInLine - deleteLength,
                                                 deleteLength)];
        } else {
                if (currentLocationInLine > properIndentationLocation) {
                        deleteLength = currentLocationInLine - properIndentationLocation;
                        [textView insertText:@""
                            replacementRange:NSMakeRange(lineRange.location + currentLocationInLine - deleteLength,
                                                         deleteLength)];
                } else if (currentLocationInLine == properIndentationLocation) {
                        deleteLength = currentLocationInLine % [PLFormatterIndentationString length];
                        if (deleteLength == 0 && currentLocationInLine > 0)
                                deleteLength = [PLFormatterIndentationString length];
                        [textView insertText:@""
                            replacementRange:NSMakeRange(lineRange.location + currentLocationInLine - deleteLength,
                                                         deleteLength)];
                        
                } else if (currentLocationInLine == 0) {
                        [textView insertText:[PLFormatter indentationStringWithLength:properIndentationLocation]
                            replacementRange:NSMakeRange(lineRange.location, 0)];
                } else {
                        indentationToProperLocation = properIndentationLocation - currentLocationInLine;
                        [textView insertText:[PLFormatter indentationStringWithLength:indentationToProperLocation] replacementRange:NSMakeRange(lineRange.location + currentLocationInLine,0)];
                }
        }
        
exit:
        return YES;
}


#pragma mark Identifying Proper Indentation Location

/**
 * \brief Method that determines the proper indentation location for the line(s)
 *        following an opening bracket with line continuation until its
 *        corresponding closing bracket is identified.
 *
 * \details The method identifies the indentation level for a given
 *          openning bracket and depends on the length of the string following
 *          the open bracket. If the length is 0, then the indentation level will
 *          be the same of the first whitespace or bracket that is found. If the
 *          length is greater than 1, the indentation level is set to the
 *          location of the opening bracket offset by one. The location of the
 *          opening bracket can be obtained using the characterIndexForNextOpenBracket().
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSUInteger openBracketIndex The index of the character corresponding to
 *                                    the opening bracket for which newlines within
 *                                    its bracket block are being formatted.
 *
 * \return An NSUInteger indicating the number of preceding whitespace characters
 *         necessary for the proper indentation location within the bracket block
 *         corresponding to the open bracket defined by the openingBracketIndex.
 *         If method fails, NSNotFound is returned.
 */
+(NSUInteger)indentationLevelForOpeningBracketInText:(NSString *)text atIndex:(NSUInteger)openingBracketIndex
{
        NSUInteger indentationLevel = 0;
        NSUInteger i, nextOpenBracket, nextWhiteSpace = 0;
        NSInteger qLevel = 0, qdLevel = 0;
        if (openingBracketIndex == NSNotFound)
                goto exit;
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(openingBracketIndex, 0)];
        NSRange rangeOfInterest = NSMakeRange(openingBracketIndex,
                                              lineRange.length-(openingBracketIndex-lineRange.location));
        
        NSString * stringOfInterest = [[text substringWithRange:rangeOfInterest] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        /** Check if any characters follow the innermost open bracket **/
        if ([stringOfInterest length] > 1) {
                indentationLevel = (openingBracketIndex+1)-lineRange.location;
        } else {
                /* finds the fist white space character or first opening bracket
                 * to match indentation */
                i = openingBracketIndex-1;
                nextOpenBracket = [PLFormatter characterIndexForNextOpenBracket:text fromIndex:i];
                while (i > 0) {
                        i--;
                        switch ([text characterAtIndex:i]) {
                                case '\'':
                                        if (qdLevel == 0)
                                                qLevel = (qLevel + 1) % 2;
                                        break;
                                case '"':
                                        if (qLevel == 0)
                                                qdLevel = (qdLevel + 1) % 2;
                                        break;
                                default:
                                        break;
                        }
                        if (qLevel != 0 || qdLevel != 0)
                                continue;
                        if ([[NSCharacterSet whitespaceCharacterSet] characterIsMember:[text characterAtIndex:i]]) {
                                nextWhiteSpace = i;
                                break;
                        }
                }
                if (nextOpenBracket == NSNotFound) {
                        indentationLevel = nextWhiteSpace - [text lineRangeForRange:NSMakeRange(nextWhiteSpace, 0)].location;
                        indentationLevel += 2;
                } else {
                        i = MAX(nextWhiteSpace, nextOpenBracket);
                        indentationLevel = i - [text lineRangeForRange:NSMakeRange(i, 0)].location;
                        indentationLevel += 2;
                }
        }
exit:
        return indentationLevel;
}

/**
 * \brief Method that determines the proper indentation location when the
 *        previous line contains a closing bracket.
 *
 * \details Method determines the proper indentation location for a line, given
 *          a character in that line, that contains a terminating bracket. This
 *          method can be called if a line ends in another pattern, such as a
 *          colon. The method identifies the outermost closing bracket, and
 *          matches its opening bracket within the preceeding block of code.
 *          Internal calculation is made by characterIndexForMatchingBracket().
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSUInteger index The index of a character in the line for which the
 *                         proper indentation is being identified.
 *
 * \return An NSUInteger indicating the number of preceding whitespace characters
 *         necessary for the proper indentation location.
 */
+(NSUInteger)indentationLevelForClosingBracketInText:(NSString *)text atIndex:(NSUInteger)lineWithBracket
{
        NSUInteger indentationLevel = 0;
        NSUInteger openingCharacter = characterIndexForMatchingBracket(text, lineWithBracket);
        if (openingCharacter == NSNotFound)
                goto exit;
        /* Matches the indentation level of the line with the corresponding 
         * opening bracket */
        indentationLevel = [self indentationLocationOfString:text atIndex:openingCharacter];
exit:
        return indentationLevel;
}

/**
 * \brief Finds the proper indentation location for a given line.
 *
 * \details The method finds the proper indentation of a line containing a character
 *          at the specified index. This method matches the previous indentation
 *          location unless specific patters are found.
 *
 * \param NSString text An instance of a NSString object that contains the text
 *                      of the python document.
 *
 * \param NSUInteger index The index of a character in the line for which the
 *                         proper indentation is being identified.
 *
 * \return An NSUInteger indicating the number of preceding whitespace characters
 *         necessary for the proper indentation location.
 */
+(NSUInteger)indentationLocationInText:(NSString *)text atIndex:(NSUInteger)index
{
        NSUInteger position = [text lineRangeForRange:NSMakeRange(index, 0)].location;
        NSUInteger indentationLevel = 0;
        NSRange lineRange;
        [text retain];
        /* If file is at first line, there is nothing to check */
        if (position == 0)
                goto exit;
        index = [text lineRangeForRange:NSMakeRange(position-1, 0)].location;
        lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
        if (lineInTextMatchesPattern(PLFormatterPatternEndingColon, text, lineRange)) {
                NSUInteger openingCharacter = characterIndexForMatchingBracket(text, position-1);
                if (openingCharacter != NSNotFound)
                        indentationLevel = [self indentationLocationInText:text atIndex:openingCharacter];
                else
                        indentationLevel = [self indentationLocationOfString:text atIndex:position-1];
                indentationLevel += 4;
        } else if (lineInTextMatchesPattern(PLFormatterPatternReturnYield, text, lineRange)) {
                indentationLevel = [self indentationLocationInText:text atIndex:position-1];
                if (indentationLevel < 4)
                        indentationLevel = 0;
                else
                        indentationLevel -= 4;
        } else if (lineInTextMatchesPattern(PLFormatterPatternLineContinuation, text, lineRange)) {
                position = [PLFormatter characterIndexForNextOpenBracket:text fromIndex:position-1];
                indentationLevel = [self indentationLevelForOpeningBracketInText:text atIndex:position];
        } else if (lineInTextMatchesPattern(PLFormatterPatternEndingBracket, text, lineRange)) {
                indentationLevel = [self indentationLevelForClosingBracketInText:text atIndex:position-1];
        } else if (lineInTextMatchesPattern(PLFormatterPatternOpenBracket, text, lineRange)) {
                indentationLevel = [self indentationLevelForOpeningBracketInText:text atIndex:position-1];
        } else {
                indentationLevel = [self indentationLocationOfString:text atIndex:position-1];
        }
exit:
        [text autorelease];
        return indentationLevel;
}

#pragma mark Current Indentation

/**
 * \brief Return the indentation location of the line at a given index of an NSString
 *
 * \details This method processes the current line of an NSString in two steps:
 *          1) Look for the first non-whitespace character. If present, this is
 *              the indentation location.
 *          2) If a line has only whitespace, the length of the line is the
 *             indentation location.
 */
+(NSUInteger)indentationLocationOfString:(NSString *)text atIndex:(NSUInteger)index
{
        NSRange lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
        NSRange indentationRange = [text rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet] options:0 range:lineRange];
        NSUInteger whitespaceLength = 0;
        if (indentationRange.location == NSNotFound)
                whitespaceLength = lineRange.length;  // if no non-whitespace characters, indentation range is range of line
        else
                whitespaceLength = indentationRange.location - lineRange.location;
        return whitespaceLength;
}

/**
 * \brief Return the indentation location of each line in a given range.
 *
 * \details This method iterates over each line in the range and determines its
 *          indentation location by calling indentationLocationOfString:atIndex.
 *          It offsets each indentation location by the starting location of the
 *          line.
 *
 * \param text The string to determine indentation locations from.
 *
 * \param range The range to determine indentation locations within.
 *
 * \return An NSArray of NSNumber objects containing a NSUInteger for each
 *         indentation location in the range.
 */
+(NSArray *)indentationLocationOfLines:(NSString *)text inRange:(NSRange)range
{
        NSMutableArray * locations = nil;
        NSRange lineRange;
        NSUInteger indentationLocation = 0, index = 0;
        
        locations = [NSMutableArray array];
        index = range.location;
        do {
                lineRange = [text lineRangeForRange:NSMakeRange(index, 0)];
                indentationLocation = [PLFormatter indentationLocationOfString:text atIndex:index];
                [locations addObject:[NSNumber numberWithUnsignedInteger:lineRange.location + indentationLocation]];
                index = lineRange.location + lineRange.length;
        } while (index < range.location + range.length);
        
exit:
        return [NSArray arrayWithArray:locations];
}

#pragma mark Indentation String Generation

/**
 * \brief Return an NSString of whitespace equal to the desired length.
 */
+(NSString *)indentationStringWithLength:(NSUInteger)length
{
        return [@"" stringByPaddingToLength:length
                                 withString:@" "
                            startingAtIndex:0];
}

@end
