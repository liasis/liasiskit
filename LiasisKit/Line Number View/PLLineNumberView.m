/**
 * \file PLLineNumberView.m
 * \brief Liasis Python IDE line number ruler view for text editor.
 *
 * \details
 * This file contains the method implementation for a NSRulerView 
 * subclass that is used to dsiplay line numbers. This class controls a set of
 * views tha make up the text editor capabilities of the python IDE.
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
 * \todo Add properties of the ruler view that may be changed, such as text
 *       color, to work with themes (ADD a THEMES class that parses .
 *
 */

#import "PLLineNumberView.h"
#import "PLFormatter.h"
#import "NSTextView+characterRangeInRect.h"
#import "NSColor+hexToColor.h"

#define MARKER_MARGIN      5.0f
#define BREAKPOINT_STRING @"import pdb; pdb.set_trace()"

@implementation PLLineNumberView

#pragma mark - Public Methods

-(id)init
{
        self = [super init];
        if (self) {
                lineNumberIndex = [[NSMutableDictionary alloc] init];
                markers = [[NSMutableSet alloc] init];
                textColor = [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0] retain];
                backgroundColor = [[NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0] retain];
                selectedColor = [[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0] retain];
                lineNumberLabels = [[NSMutableDictionary alloc] init];
        }
        
        return self;
}

-(id)initWithScrollView:(NSScrollView *)scrollView orientation:(NSRulerOrientation)orientation
{
        self = [super initWithScrollView:scrollView orientation:orientation];
        if (self) {
                lineNumberIndex = [[NSMutableDictionary alloc] init];
                markers = [[NSMutableSet alloc] init];
                backgroundColor = [[NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0] retain];
                textColor = [[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:0.5 alpha:1.0] retain];
                selectedColor = [[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:1.0] retain];
                lineNumberLabels = [[NSMutableDictionary alloc] init];
        }
        [[scrollView contentView] setPostsBoundsChangedNotifications:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(boundsDidChange:)
                                                     name:NSViewBoundsDidChangeNotification
                                                   object:[scrollView contentView]];
        [scrollView setLineScroll:30.0f];
        return self;
}

-(void)dealloc
{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [markers release];
        [lineNumberIndex release];
        [lineNumberLabels release];
        [textColor release];
        [backgroundColor release];
        [selectedColor release];
        [super dealloc];
}

#if defined(__APPLE__) && defined (__MACH__)
#pragma mark Setter and Getter Methods
#endif

-(NSTextView *)clientView
{
        return (NSTextView *)[super clientView];
}

-(void)setClientView:(NSTextView *)client
{
        NSNotificationCenter *notificationCenter;
        if ([client isKindOfClass:[NSTextView class]] == NO) {
                NSLog(@"PLLineNumberView client must be a NSTextView or subclass.");
                /* Error Notification should go here */
                goto exit;
        }
        notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter removeObserver:self
                                   name:NSTextStorageDidProcessEditingNotification
                                 object:[[self clientView] textStorage]];
        [notificationCenter removeObserver:self
                                   name:NSTextViewDidChangeSelectionNotification
                                 object:[self clientView]];
        [notificationCenter removeObserver:self
                                      name:NSViewFrameDidChangeNotification
                                    object:[self clientView]];
        
        [super setClientView:client];
        [client setPostsFrameChangedNotifications:YES];
        [notificationCenter addObserver:self
                               selector:@selector(textDidEndEditing:)
                                   name:NSTextStorageDidProcessEditingNotification
                                 object:[client textStorage]];
        [notificationCenter addObserver:self
                               selector:@selector(textDidChangeSelection:)
                                   name:NSTextViewDidChangeSelectionNotification
                                 object:client];
        [notificationCenter addObserver:self
                               selector:@selector(removeAllLabels:)
                                   name:NSViewFrameDidChangeNotification
                                 object:client];
        [self setRuleThickness:[self requiredThickness]];
        [lineNumberIndex removeAllObjects];
        [lineNumberIndex setObject:[NSNumber numberWithInteger:0]
                            forKey:@"1"];
        [self updateLineNumbersForEditedRange:NSMakeRange(0, 0)
                        withReplacementString:[[self clientView] string]];
        [self setNeedsDisplay:YES];
exit:
        return;
}

@synthesize backgroundColor;

-(void)makeBackgroundColorFromColor:(NSColor *)textViewBackgroundColor
{
        NSColor * invertedColor = [NSColor colorWithInvertedRedGreenBlueComponents:textViewBackgroundColor];
        [textViewBackgroundColor retain];
        [backgroundColor release];
        backgroundColor = [textViewBackgroundColor blendedColorWithFraction:0.1f ofColor:invertedColor];
        [backgroundColor retain];
        [textViewBackgroundColor release];
        [self setNeedsDisplay:YES];
}

@synthesize textColor;

-(void)setTextColor:(NSColor *)aColor
{
        [aColor retain];
        [textColor release];
        textColor = aColor;
        [self setNeedsDisplay:YES];
}

@synthesize selectedColor;

-(void)setSelectedColor:(NSColor *)aColor
{
        [aColor retain];
        [selectedColor release];
        selectedColor = aColor;
        [self setNeedsDisplay:YES];
}

-(NSUInteger)numberOfLines
{
        return [lineNumberIndex count];
}

#if defined(__APPLE__) && defined (__MACH__)
#pragma mark Basic Ruler Properties
#endif

-(CGFloat)requiredThickness
{
        NSAttributedString *attrString;
        NSFont * font;
        CGFloat characterWidth, thickness;
        NSUInteger lines;
        font = [[NSFontManager sharedFontManager] selectedFont];
        attrString = [[NSAttributedString alloc] initWithString:@"8" attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
        characterWidth = [attrString size].width+1.0f;
        lines = [lineNumberIndex count];
        thickness = 2.0f+characterWidth*[[NSString stringWithFormat:@"%ld", lines] length];
        if (thickness < 3*characterWidth+2.0f)
                thickness = 3*characterWidth+2.0f;
        gutterThickness = characterWidth;
        [attrString release];
        return ceil(thickness)+gutterThickness+MARKER_MARGIN;
}

#if defined(__APPLE__) && defined (__MACH__)
#pragma mark Drawing Methods
#endif


- (void)drawMarkersInRect:(NSRect)dirtyRect
{
        NSBezierPath * path;
        NSPoint point;
        path = [[NSBezierPath alloc] init];
        point = dirtyRect.origin;
        [path moveToPoint:point];
        point.x += 5.0f*dirtyRect.size.width/6.0f;
        [path lineToPoint:point];
        point.y += dirtyRect.size.height/2.0f;
        point.x += dirtyRect.size.width/6.0f;
        [path lineToPoint:point];
        point.y += dirtyRect.size.height/2.0f;
        point.x -= dirtyRect.size.width/6.0f;
        [path lineToPoint:point];
        point.x -= 5.0f*dirtyRect.size.width/6.0f;
        [path lineToPoint:point];
        [path closePath];
        [[NSColor colorWithCalibratedRed:0.3f green:0.5f blue:1.0f alpha:1.0f] setFill];
        [path fill];
        [textColor setStroke];
        [path stroke];
        [path release];
}


-(NSTextField *)labelForLineNumber:(NSString *)labelKey withLineHeight:(CGFloat)lineHeight withFont:(NSFont *)font
{
        NSRange lineRange, selectedRange;
        NSRect *rects, labelRect, selectedRect;
        NSUInteger position, numberOfRects;
        NSString *text;
        NSTextView *textView;
        NSLayoutManager *layoutManager;
        NSTextContainer *textContainer;
        NSTextField * label;
        textView = [self clientView];
        text = [textView string];
        layoutManager = [textView layoutManager];
        textContainer = [textView textContainer];
        label = [[NSTextField alloc] init];
        [label setStringValue:labelKey];
        [label setTextColor:textColor];
        position = [(NSNumber *)[lineNumberIndex objectForKey:labelKey] integerValue];
        lineRange = [text lineRangeForRange:NSMakeRange(position, 0)];
        rects = [layoutManager rectArrayForCharacterRange:lineRange
                             withinSelectedCharacterRange:NSMakeRange(NSNotFound, 0)
                                          inTextContainer:textContainer 
                                                rectCount:&numberOfRects];
        if (numberOfRects == 0)
                goto exit;
        labelRect = rects[0];
        labelRect = NSMakeRect(MARKER_MARGIN, 
                               labelRect.origin.y,
                               [self ruleThickness]-gutterThickness-MARKER_MARGIN-2.0f,
                               lineHeight-1.0f);
        selectedRange = [textView selectedRange];
        [label setFrame:labelRect];
        [label setAlignment:NSRightTextAlignment];
        [label setFont:font];
        if (NSIntersectionRange(lineRange, selectedRange).length != 0 ||
            NSLocationInRange(selectedRange.location, lineRange) ||
            (NSMaxRange(lineRange) == selectedRange.location && [labelKey integerValue] == [lineNumberIndex count])) {
                selectedRect = labelRect;
                selectedRect.origin.x = 0.0f;
                selectedRect.size.width += MARKER_MARGIN+2.0f;
                [selectedColor setFill];
                NSRectFill(selectedRect);
        }
exit:
        return [label autorelease];
}


-(void)drawLabelsInRect:(NSRect)dirtyRect
{
        NSUInteger lineNumber = 0, lineNumbers;
        CGFloat lineHeight = 0, maxY;
        NSRange lineRange, selectedRange;
        NSUInteger position = 0;
        NSTextView *textView;
        NSString * text;
        NSMutableString * labelKey;
        NSTextField * label;
        NSFont *font = nil;
        NSAttributedString * attrString;
        NSRange characterRange;
        NSRect frame, rectForCharacters, modifierRect;
        NSGraphicsContext *gc = [NSGraphicsContext currentContext];
        [gc saveGraphicsState];
        textView = (NSTextView *)[self clientView];
        text = [textView string];
        font = [[NSFontManager sharedFontManager] selectedFont];
        if (font == nil) {
                font = [NSFont fontWithName:@"Helvetica" size:12.0];
        }
        attrString = [[NSAttributedString alloc] initWithString:@"7" attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
        lineHeight = [attrString size].height;
        labelKey = [[NSMutableString alloc] init];
        [attrString release];
        font = [NSFont fontWithName:[font fontName] size:[font pointSize]-2.0];
        [font retain];
        rectForCharacters = dirtyRect;
        rectForCharacters.size.width = [textView visibleRect].size.width;
        characterRange = [textView characterRangeInRect:rectForCharacters];
        position = characterRange.location;
        lineRange = [text lineRangeForRange:NSMakeRange(position, 0)];
        lineNumber = [self lineNumberForRange:lineRange usingBinarySearch:YES];
        lineNumbers = [lineNumberIndex count];
        maxY = NSMaxY(dirtyRect);//[self bounds].origin.y + [self bounds].size.height;
        selectedRange = [[self clientView] selectedRange];
        if (selectedRange.length == 0)
                selectedRange.length = 1;
        do {
                [labelKey setString:@""];
                [labelKey appendFormat:@"%li", lineNumber];
                lineRange = [text lineRangeForRange:NSMakeRange([[lineNumberIndex objectForKey:labelKey] integerValue], 0)];
                if (lineRange.length == 0) {
                        lineRange.length = 1;
                }
                label = [lineNumberLabels objectForKey:labelKey];
                if (label == nil) {
                        label = [self labelForLineNumber:labelKey
                                          withLineHeight:lineHeight
                                                withFont:font];
                        [lineNumberLabels setObject:label forKey:labelKey];
                }
                lineNumber++;
                frame = [label frame];
                if (NSEqualRects(NSIntersectionRect(frame, dirtyRect), NSZeroRect))
                        continue;
                if ((NSIntersectionRange(lineRange, selectedRange).length != 0) ||
                    (NSMaxRange(lineRange) == selectedRange.location && [labelKey integerValue] == [lineNumberIndex count])) {
                        modifierRect = frame;
                        modifierRect.origin.x = 0.0f;
                        modifierRect.size.width += MARKER_MARGIN+2.0f;
                        [selectedColor setFill];
                        NSRectFill(modifierRect);
                }
                if ([markers member:labelKey]) {
                        modifierRect = frame;
                        modifierRect.origin.y += modifierRect.size.height/8.0f;
                        modifierRect.size.height -= 2*modifierRect.size.height/8.0f;
                        modifierRect.size.width += gutterThickness+1.0f;
                        [self drawMarkersInRect:modifierRect];
                        [label setTextColor:[NSColor whiteColor]];
                } else {
                        [label setTextColor:textColor];
                }
                [[label attributedStringValue] drawInRect:frame];
        } while(frame.origin.y < maxY && lineNumber <= lineNumbers);
        [gc flushGraphics];
        [gc restoreGraphicsState];
        [font release];
        [labelKey release];
}

-(void)drawHashMarksAndLabelsInRect:(NSRect)dirtyRect
{
        NSGraphicsContext *gc = [NSGraphicsContext currentContext];
        NSRect line, rect;
        [gc saveGraphicsState];
        [self setRuleThickness:[self requiredThickness]];
        NSRect bounds = [self bounds];
        bounds.origin.y = [[[self scrollView] contentView] bounds].origin.y - [[self clientView] frame].origin.y;
        [self setBoundsOrigin:bounds.origin];
        rect = [self visibleRect];
        dirtyRect.origin.x = 0.0;
        dirtyRect.origin.y = dirtyRect.origin.y - [[self clientView] frame].origin.y;
        dirtyRect.size.width = [self bounds].size.width;
        [backgroundColor setFill];
        NSRectFill(rect);
        line = NSMakeRect(rect.size.width-gutterThickness,
                          rect.origin.y,
                          1.0f,
                          rect.size.height);
        [[NSColor grayColor] set];
        NSRectFill(line);//NSIntersectionRect(line, dirtyRect));
        [self drawLabelsInRect:rect];
        [gc restoreGraphicsState];
        return;
}

#pragma mark Line Number Updating

-(void)updateLineNumbersForEditedRange:(NSRange)editedRange withReplacementString:(NSString *)string
{
        const char INSERTION = 1;
        const char DELETION = 2;
        const char REPLACEMENT = 4;
        char flag = 0;
        NSUInteger firstEditedLine;
        if (editedRange.length == 0 && [string length] == 0)
                goto exit;
        if (string == nil)
                goto exit;
        if (editedRange.length == 0)
                flag = INSERTION;
        else if ([string length] == 0)
                flag = DELETION;
        else
                flag = REPLACEMENT;
        firstEditedLine = [self lineNumberForRange:[[[self clientView] string] lineRangeForRange:editedRange]
                                 usingBinarySearch:YES];
        [self removeLabelsFromLineNumber:firstEditedLine];
        switch (flag) {
                case DELETION:
                        [self updateAfterDeletetion:editedRange];
                        break;
                case INSERTION:
                        [self updateAfterInsertion:editedRange.location
                             withReplacementString:string];
                        break;
                case REPLACEMENT:
                        [self updateAfterDeletetion:editedRange];
                        [self updateAfterInsertion:editedRange.location
                             withReplacementString:string];
                        break;
        }
        [self updateMarkersInEditedRange:editedRange withReplacementString:string];
exit:
        return;
}

#pragma mark Event Handling

-(void)mouseDown:(NSEvent *)theEvent
{
        NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSRange characterRange, lineRange, selectedRange;
        NSTextView *textView = [self clientView];
        NSTextStorage * storage = [textView textStorage];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [[NSFontManager sharedFontManager] selectedFont], NSFontAttributeName, nil];
        NSString * lineString;
        NSAttributedString * string;
        NSUInteger lineNumber;
        characterRange = [self characterRangeForLineAtHeight:location.y];
        lineRange = [[textView string] lineRangeForRange:NSMakeRange(characterRange.location, 0)];
        selectedRange = [textView selectedRange];
        lineNumber = [self lineNumberForRange:lineRange usingBinarySearch:YES];
        if (characterRange.location == 0 && characterRange.length == 0 && [[textView string] length] != 0)
                goto exit;
        if (location.x > [self bounds].size.width-gutterThickness) {
                if (NSIntersectionRange(selectedRange, lineRange).length != 0)
                        lineRange = selectedRange;
                if ([[storage fontAttributesInRange:lineRange] objectForKey:NSBackgroundColorAttributeName]) {
                        [storage removeAttribute:NSBackgroundColorAttributeName range:lineRange];
                } else {
                        attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [[NSFontManager sharedFontManager] selectedFont], NSFontAttributeName,
                                      [NSColor redColor], NSBackgroundColorAttributeName,
                                      nil];
                        [storage setAttributes:attributes range:lineRange];
                }
        } else {
                if ([markers containsObject:[NSString stringWithFormat:@"%li", lineNumber]]) {
                        [textView setSelectedRange:lineRange];
                        [textView insertText:@"" replacementRange:lineRange];
                } else {
                        lineString = [NSString stringWithFormat:@"%@%@\n", [PLFormatter indentationStringOfText:[storage string] atIndex:lineRange.location], BREAKPOINT_STRING];
                        string = [[NSAttributedString alloc] initWithString:lineString
                                                                 attributes:attributes];
                        [textView setSelectedRange:NSMakeRange(lineRange.location, 0)];
                        [textView insertText:string
                            replacementRange:NSMakeRange(lineRange.location, 0)];
                        [textView setSelectedRange:NSMakeRange(lineRange.location,
                                                               [string length])];
                        [markers addObject:[NSString stringWithFormat:@"%li", lineNumber]];
                        [string release];
                }
                
        }
exit:
        return;

}


#pragma mark - Private Methods
#pragma mark Line Number Updating



-(NSUInteger)lineNumberForRange:(NSRange)characterRange
{
        NSUInteger i, count, lineNumber = 0;
        NSUInteger position;
        NSMutableString * key;
        count = [lineNumberIndex count];
        key = [[NSMutableString alloc] init];
        for (i = 0; i < count; i++) {
                [key setString:@""];
                [key appendFormat:@"%li", i+1];
                position = [[lineNumberIndex objectForKey:key] integerValue];
                if (position == characterRange.location) {
                        lineNumber = i;
                }
        }
        [key release];
        return lineNumber+1;
}

-(void)removeLabelsFromLineNumber:(NSUInteger)lineNumber
{
        NSUInteger i;
        NSMutableString *labelKey = [[NSMutableString alloc] init];
        for (i = lineNumber; i <= [self numberOfLines]; i++) {
                [labelKey setString:@""];
                [labelKey appendFormat:@"%li", i];
                [lineNumberLabels removeObjectForKey:labelKey];
        }
        [labelKey release];
}

-(void)removeAllLabels:(NSNotification *)aNotification
{
        [lineNumberLabels removeAllObjects];
}

-(NSUInteger)lineNumberForRange:(NSRange)characterRange usingBinarySearch:(BOOL)isBinary
{
        NSUInteger count, lineNumber = 0;
        NSUInteger position;
        NSMutableString * key = nil;
        NSRange searchRange;
        if (isBinary == NO) {
                lineNumber = [self lineNumberForRange:characterRange];
                goto exit;
        }
        count = [lineNumberIndex count];
        if (count == 0) {
                goto exit;
        }
        searchRange = NSMakeRange(1, count);
        key = [[NSMutableString alloc] init];
        
        while (searchRange.length > 0) {
                lineNumber = searchRange.location+searchRange.length/2;
                [key setString:@""];
                [key appendFormat:@"%li", lineNumber];
                position = [[lineNumberIndex objectForKey:key] integerValue];
                searchRange.length /= 2;
                if (position < characterRange.location) {
                        searchRange.location = lineNumber;
                } else if (position == characterRange.location) {
                        break;
                }
        }
        if (position != characterRange.location) {
                lineNumber = [self lineNumberForRange:characterRange];
        }
exit:
        [key release];
        return lineNumber;
}


-(IBAction)textDidEndEditing:(id)sender
{
        [self setNeedsDisplay:YES];
}


-(void)textDidChangeSelection:(NSNotification *)notification
{
        [self setNeedsDisplay:YES];
}

/**
 * \brief Update the bounds of the ruler view when the scroll view's content
 *        view bounds change.
 *
 * \details This method calculates and sets the new bound origin of the ruler
 *          view.
 */
-(void)boundsDidChange:(NSNotification *)notification
{
        NSRect bounds = [self bounds];
        bounds.origin.y = [[[self scrollView] contentView] bounds].origin.y - [[self clientView] frame].origin.y;
        [self setBoundsOrigin:bounds.origin];
}

-(void)updateAfterInsertion:(NSUInteger)insertionPoint withReplacementString:(NSString *)newString
{
        NSString *text;
        NSDictionary *newDict;
        NSUInteger i, positionDifference, count;
        NSRange lineRange;
        NSUInteger lineNumber;
        NSMutableString * key, * newKey;
        NSNumber * value;
        if ([newString length] == 0) {
                goto exit;
        }
        text = [[self clientView] string];
        lineRange = [text lineRangeForRange:NSMakeRange(insertionPoint, 0)];
        lineNumber = [self lineNumberForRange:lineRange usingBinarySearch:YES];
        newDict = [self calculateLineNumbersForString:newString];
        count = [newDict count];
        positionDifference = [newString length];
        key = [[NSMutableString alloc] init];
        newKey = [[NSMutableString alloc] init];
        for (i = [lineNumberIndex count]; i > lineNumber; i--) {
                [key setString:@""];
                [newKey setString:@""];
                [key appendFormat:@"%li", i];
                value = [lineNumberIndex objectForKey:key];
                [newKey appendFormat:@"%li", i+count-1];
                value = [NSNumber numberWithInteger:[value integerValue]+positionDifference];
                [lineNumberIndex setObject:value forKey:newKey];
                if ([markers containsObject:key]) {
                        [markers removeObject:key];
                        [markers addObject:newKey];
                }
        }
        
        for (i = 1; i < [newDict count]; i++) {
                [key setString:@""];
                [key appendFormat:@"%li", i];
                value = [newDict objectForKey:key];
                [key setString:@""];
                [key appendFormat:@"%li", i+lineNumber];
                value = [NSNumber numberWithInteger:[value integerValue]+insertionPoint];
                [lineNumberIndex setObject:value forKey:key];
        }
        [key release];
        [newKey release];
exit:
        return;
}

-(void)updateAfterDeletetion:(NSRange)editedRange
{
        NSString *oldString, *text;
        NSDictionary *oldDict;
        NSUInteger i, count;
        NSRange lineRange;
        NSUInteger lineNumber;
        NSString * key, *newKey;
        NSNumber * value;
        NSUInteger numberOfLines = 0, linesToRemove = 0;
        
        text = [[self clientView] string];
        lineRange = [text lineRangeForRange:editedRange];
        lineNumber = [self lineNumberForRange:lineRange usingBinarySearch:YES];
        oldString = [text substringWithRange:editedRange];
        oldDict = [self calculateLineNumbersForString:oldString];
        count = [oldDict count];
        numberOfLines = [lineNumberIndex count];
        linesToRemove = count-1;
        lineNumber++;
        for (i = lineNumber; i < 1+numberOfLines - linesToRemove; i++) {
                key = [NSString stringWithFormat:@"%li", i+linesToRemove];
                value = [lineNumberIndex objectForKey:key];
                value = [NSNumber numberWithInteger:[value integerValue]-editedRange.length];
                newKey = [NSString stringWithFormat:@"%li", i];
                if ([newKey isEqualToString:key] == NO) {
                        [markers removeObject:newKey];
                        if ([markers containsObject:key]) {
                                [markers removeObject:key];
                                [markers addObject:newKey];
                        }
                }
                [lineNumberIndex setObject:value forKey:newKey];
        }
        for (i = numberOfLines; i > numberOfLines-linesToRemove; i--) {
                key = [NSString stringWithFormat:@"%li", i];
                [lineNumberIndex removeObjectForKey:key];
                [markers removeObject:key];
        }
}

-(void)updateMarkersInEditedRange:(NSRange)editedRange withReplacementString:(NSString *)aString
{
        NSString * text, * key;
        NSString *originalString, * completeString;
        NSRange characterRange;
        NSUInteger i, lineNumber;
        NSArray * lines;
        text = [[self clientView] string];
        if (NSMaxRange(editedRange) != [text length]) {
                characterRange = [text lineRangeForRange:NSMakeRange(editedRange.location,
                                                                     editedRange.length+1)];
        } else {
                characterRange = [text lineRangeForRange:NSMakeRange(editedRange.location,
                                                                     editedRange.length)];
        }
        
        originalString = [text substringWithRange:characterRange];
        completeString = [originalString stringByReplacingCharactersInRange:
                          NSMakeRange(editedRange.location-characterRange.location,
                                      editedRange.length)
                                                                 withString:aString];
        lines = [completeString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        lineNumber = [self lineNumberForRange:characterRange usingBinarySearch:YES];
        for (i = 0; i < [lines count]-1; i++) {
                key = [NSString stringWithFormat:@"%li", lineNumber+i];
                [markers removeObject:key];
                if ([[[lines objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:BREAKPOINT_STRING]) {
                        [markers addObject:key];
                }
        }
        
        
}

/**
 * \brief Calculates the initial character for each of the line numbers for
 *        text in the NSTextView.
 *
 * \details This method retrieves the string content of the client NSTextView
 *          and finds the character position for each new line. This method
 *          stores linenumber character position pairs in an NSDictionary object
 *          where the key is the lineNumber, and the object is the index of the
 *          first character. This function only needs to run whenever the text
 *          within the client NSTextView changes.
 *
 */
-(NSDictionary *)calculateLineNumbersForString:(NSString *)aString
{
        NSUInteger lineNumber = 1, length;
        NSNumber * index;
        NSString *key;
        NSRange lineRange;
        NSUInteger position = 0;
        NSMutableDictionary * lineNumberDictionary = nil;
        length = [aString length];
        lineNumber = 0;
        lineNumberDictionary = [[NSMutableDictionary alloc] init];
        while (position < length) {
                index = [NSNumber numberWithInteger:position];
                key = [NSString stringWithFormat:@"%li", lineNumber];
                [lineNumberDictionary setObject:index forKey:key];
                lineRange = [aString lineRangeForRange:NSMakeRange(position, 0)];
                position = NSMaxRange(lineRange);
                lineNumber++;
        }
        lineRange = [aString lineRangeForRange:NSMakeRange(position, 0)];
        if (lineRange.length == 0) {
                index = [NSNumber numberWithInteger:position];
                key = [NSString stringWithFormat:@"%li", lineNumber];
                [lineNumberDictionary setObject:index forKey:key];
                lineNumber++;
        }
exit:
        return [lineNumberDictionary autorelease];
}

-(NSRange)characterRangeForLineAtHeight:(CGFloat)height
{
        NSTextView *textView;
        NSLayoutManager *layoutManager;
        NSTextContainer *textContainer;
        NSRect visibleRect;
        NSRange glyphRange, characterRange;
        NSPoint textContainerOrigin;
        textView = (NSTextView *)[[self clientView] retain];
        textContainer = [textView textContainer];
        layoutManager = [textView layoutManager];
        textContainerOrigin = [textView textContainerOrigin];
        visibleRect = NSMakeRect(0.0f,
                                 height+1.0f,
                                 [textView visibleRect].size.width,
                                 1.0f);
        [textView release];
        visibleRect.origin.x -= textContainerOrigin.x;
        visibleRect.origin.y -= textContainerOrigin.y;
        glyphRange = [layoutManager glyphRangeForBoundingRect:visibleRect
                                              inTextContainer:textContainer];
        characterRange = [layoutManager characterRangeForGlyphRange:glyphRange
                                                   actualGlyphRange:nil];
        return characterRange;
}

//
//-(BOOL)isOpaque
//{
//        return YES;
//}

@end
