/**
 * \file PLAutocompleteViewController.m
 * \brief Liasis Python IDE autocomplete view controller implementation file.
 *
 * \details This file contains the implementation for the autocomplete view
 *          controller.
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
 * along with Liasis. If not, see <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 * \todo Update screen font setting whenever the superTextView layout manager
 *       changes this setting (could be checked when its layout completes).
 */

#import "PLAutocompleteViewController.h"

/**
 * \brief The key for the table view disappear animation.
 */
static NSString * PLAutocompleteViewControllerDisappearKey = @"animateDisappear";

/**
 * \brief The two types of selection movement in the table view: up or down.
 */
typedef enum {
        PLAutocompleteTableMovementUp = -1,
        PLAutocompleteTableMovementDown = 1
} PLAutocompleteTableMovement;

#pragma mark Utility Functions

/**
 * \brief Return the range of a word at the insertion point, truncated up to the
 *        insertion point.
 *
 * \details Find the word range of the string at the NSTextView selectedRange
 *          location and return the word range truncated at that location.
 *
 * \param textView The textView to get the word from.
 *
 * \return The partial range of a word at the insertion point.
 */
NSRange partialWordRangeAtInsertionPoint(NSTextView * textView)
{
        NSRange partialRange, wordRange;
        NSUInteger insertionPoint;
        
        insertionPoint = [textView selectedRange].location;
        wordRange = [[textView string] wordRangeAtIndex:insertionPoint];
        partialRange = NSMakeRange(wordRange.location, insertionPoint - wordRange.location);
        
        return partialRange;
}

/**
 * \brief Convenience method to call partialWordRangeAtInsertionPoint and return
 *        the substring of the textView with the partial word range.
 *
 * \param textView The textView to get the word from.
 *
 * \return The partial word at the insertion point.
 *
 * \see partialWordRangeAtInsertionPoint.
 */
NSString * partialWordAtInsertionPoint(NSTextView * textView)
{
        return [[textView string] substringWithRange:partialWordRangeAtInsertionPoint(textView)];
}

/**
 * \brief Return the bounding rect for a character range in a text view.
 *
 * \details This is a convenience function to first find the glyph range of the
 *          character range and then the bounding rect for that glyph range.
 *          Both methods use the text view's layout manager.
 *
 * \param textView The textView to find the bounding rect within.
 *
 * \param characterRange The range of characters to find the bounding rect of.
 *
 * \return The bounding rect of a character range.
 */
NSRect boundingRectForCharacterRange(NSTextView * textView, NSRange characterRange)
{
        NSRange textRange = [[textView layoutManager] glyphRangeForCharacterRange:characterRange actualCharacterRange:NULL];
        return [[textView layoutManager] boundingRectForGlyphRange:textRange
                                                   inTextContainer:[textView textContainer]];
}

@implementation PLAutocompleteViewController

/**
 * \brief Initialize the view controller from a xib file and bundle.
 *
 * \details Set up several components of the autocomplete system. The system is
 *          primarily composed of a scroll view/table view combination that
 *          contains the list of autocompletions and a text view with which
 *          to display the remaining characters of the completion.
 *
 *          Create the autocompleteViewLayer, which serves as the layer-hosting
 *          layer for the autocomplete view. Give it a shadow and set its
 *          z-position to 1.0 to ensure that it is always drawn above the
 *          autocompleteTextView. Even though the view hierarchy is always
 *          correct, if the layer heirarchy changes, the text view appears above
 *          and clips the autocompleteViewLayer's shadow. The z-position fixes
 *          this issue.
 *
 *          Create the autocompleteScrollViewLayer, the layer-hosting layer for
 *          the autocompleteScrollView. Give the layer a corner radius and set
 *          it to mask its subviews so that their corners are clipped to this
 *          radius. Set the scroll view's border and cursor, turn off horizontal
 *          scrolling, and add the No Completion view as its subview to appear
 *          when toggling autocomplete without any available completions. Assign
 *          the table view's only column the PLAutocompleteTextFieldCell as its
 *          text field cell.
 *
 *          Set up the autocomplete text view aesthetics and delegate. The
 *          autocompleteTextView is given a minor line fragment padding buffer
 *          to avoid clipping the insertion point.
 *
 *          Observe the NSTextDidEndEditingNotification of the
 *          autocompleteTextView.
 *
 * \param nibNameOrNil The name of the nib to load.
 *
 * \param nibBundleOrNil The nib bundle to load.
 *
 * \return The initialized autocomplete view controller.
 */
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
        self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self) {
                autocompleteViewLayer = [[CALayer layer] retain];
                [autocompleteViewLayer setShadowOpacity:0.5];
                [autocompleteViewLayer setShadowOffset:NSMakeSize(0, -2.5)];
                [autocompleteViewLayer setShadowRadius:4.0];
                [autocompleteViewLayer setZPosition:1.0];
                [[self view] setLayer:autocompleteViewLayer];
                [[self view] setWantsLayer:YES];
                
                autocompleteScrollViewLayer = [[CALayer layer] retain];
                [autocompleteScrollViewLayer setCornerRadius:5.0];
                [autocompleteScrollViewLayer setMasksToBounds:YES];
                [autocompleteScrollView setLayer:autocompleteScrollViewLayer];
                [autocompleteScrollView setWantsLayer:YES];
                [autocompleteScrollView setBorderType:NSNoBorder];
                [autocompleteScrollView setDocumentCursor:[NSCursor arrowCursor]];
                [autocompleteScrollView setHasHorizontalScroller:NO];
                [autocompleteScrollView addSubview:noCompletionsView];
                [noCompletionsView setHidden:YES];
                [autocompleteTableColumn setDataCell:[[[PLAutocompleteTextFieldCell alloc] init] autorelease]];

                autocompleteTextView = [[PLAutocompleteTextView alloc] init];
                [autocompleteTextView setHidden:YES];
                [autocompleteTextView setFocusRingType:NSFocusRingTypeNone];
                [autocompleteTextView setDelegate:self];
                [[autocompleteTextView textContainer] setLineFragmentPadding:0.5];
                
                superTextView = nil;
                trackingArea = nil;
                originalInsertion = nil;
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(textDidEndEditing:)
                                                             name:NSTextDidEndEditingNotification
                                                           object:autocompleteTextView];
        }
        return self;
}

/**
 * \brief Deallocate the view controller.
 *
 * \details Remove the tracking area, stop observing the three notifications,
 *          and remove all subviews from superviews.
 */
-(void)dealloc
{
        [self setTextView:nil];
        if (trackingArea) {
                [autocompleteTableView removeTrackingArea:trackingArea];
                [trackingArea release];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSTextDidEndEditingNotification
                                                      object:autocompleteTextView];
        [autocompleteTextView removeFromSuperview];
        [autocompleteTextView release];
        [noCompletionsView removeFromSuperview];
        [[self view] removeFromSuperview];
        [autocompleteViewLayer release];
        [autocompleteScrollViewLayer release];
        [originalInsertion release];
        [super dealloc];
}

+(id)viewControllerWithTextView:(NSTextView *)textView
{
        PLAutocompleteViewController * viewController = [[PLAutocompleteViewController alloc] initWithNibName:@"PLAutocompleteViewController"
                                                                                                       bundle:[NSBundle bundleForClass:self]];
        [viewController setTextView:textView];
        return [viewController autorelease];
}

-(void)setTextView:(NSTextView *)textView
{
        if (superTextView) {
                [[self view] removeFromSuperview];
                [autocompleteTextView removeFromSuperview];
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:NSTextDidChangeNotification
                                                              object:superTextView];
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:NSTextViewDidChangeSelectionNotification
                                                              object:superTextView];
                [superTextView release];
        }
                
        if (textView) {
                superTextView = [textView retain];
                [superTextView addSubview:[self view]];
                [superTextView addSubview:autocompleteTextView positioned:NSWindowBelow relativeTo:[self view]];
                [self setAutocompleteTableRowHeight];
                [self setDisplayAutocompletions:NO withAnimation:NO];

                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(textDidChange:)
                                                             name:NSTextDidChangeNotification
                                                           object:superTextView];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(selectionDidChange:)
                                                             name:NSTextViewDidChangeSelectionNotification
                                                           object:superTextView];
        }
}

/**
 * \brief Method called when the application theme manager changes.
 *
 * \details Update the background color of the autocomplete scroll view, table
 *          view, and text view. Set the text color of the autocomplete text
 *          view.
 */
-(void)updateThemeManager
{
        NSColor * backgroundColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerBackground
                                                                                 fromGroup:PLThemeManagerSettings];
        [autocompleteScrollView setBackgroundColor:backgroundColor];
        [autocompleteTableView setBackgroundColor:backgroundColor];
        [autocompleteTextView setBackgroundColor:backgroundColor];
        [autocompleteTextView setTextColor:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                                        fromGroup:PLThemeManagerSettings]];
}

/**
 * \brief Method called when the application font changes.
 *
 * \details The table view size and position methods all use the shared font
 *          manager for the application. This method updates the table view row
 *          height and, if visible, updates its size and position in addition to
 *          the autocompleteTextView font and size. The autocompleteTextView
 *          font is only set if the view is displayed since it is checked prior
 *          to being displayed.
 *
 *          There is no guarantee that the superTextView font is set before this
 *          method is called. Therefore, use the font sent with this message
 *          rather than that of the superTextView. If there is a discrepancy, it
 *          will be fixed when the autocomplete view is displayed again.
 */
-(void)updateFont:(NSFont *)font
{
        [self setAutocompleteTableRowHeight];
        if ([[self view] isHidden] == NO) {
                [autocompleteTextView setFont:font];
                [self setAutocompleteViewSize];
                [self setAutocompleteViewOrigin:[superTextView selectedRange].location];
                [self setAutocompleteTextViewFrame];
        }
}

#pragma mark Notifications

/**
 * \brief Respond to NSTextDidChange in the superTextView.
 *
 * \details If the autocomplete view is displayed, filter the results to update
 *          it from the change. If this results in no remaining completions,
 *          restore the original insertion and hide the autocomplete view.
 *
 *          The text change puts the system in one of three primary states: 
 *          (1) the insertion point is in a whitespace area (e.g. after a
 *          after newline or space), (2) the autocomplete view is displayed and
 *          completions should be filtered, or (3) the autocomplete view is
 *          hidden and the timer should be started.
 *
 *          1) Restore the original insertion and hide the autocomplete view.
 *
 *          2) Filter the completions. If there are no completions, restore the
 *             original insertion and hide the autocomplete view. Otherwise,
 *             update the autocomplete view size to account for changes in the
 *             available completions length and display the selected completion.
 *
 *          3) Start the completion timer if the insertion point is not within
 *             a word (i.e. it's at the end of the text view or the character
 *             after the insertion point is whitespace).
 *
 * \param aNotification The notification object containing the superTextView.
 */
-(void)textDidChange:(NSNotification *)aNotification
{
        NSString * partialWord = nil;
        NSUInteger insertionPoint = [superTextView selectedRange].location;
        
        partialWord = partialWordAtInsertionPoint(superTextView);
        if ([partialWord length] == 0) {
                [self restoreOriginalInsertion];
                [self setDisplayAutocompletions:NO withAnimation:NO];
        } else {
                if ([[self view] isHidden] == NO) {
                        [self filterCompletionsWithString:partialWord];
                        if ([[autocompleteTableDataSource completions] count] == 0) {
                                [self restoreOriginalInsertion];
                                [self setDisplayAutocompletions:NO withAnimation:NO];
                        } else {
                                [self setAutocompleteViewSize];
                                [self displaySelectedCompletion];
                        }
                } else if (insertionPoint == [[superTextView string] length] ||
                           [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[[superTextView string] characterAtIndex:insertionPoint]]) {
                        [self startCompletionTimer];
                }
        }

exit:
        return;
}

/**
 * \brief Respond to NSTextDidEndEditing in the autocompleteTextView.
 *
 * \details Ending editing hides the entire autocomplete system.
 *
 * \param aNotification The notification object containing the
 *        autocompleteTextView.
 */
-(void)textDidEndEditing:(NSNotification *)aNotification
{
        [self restoreOriginalInsertion];
        [self setDisplayAutocompletions:NO withAnimation:NO];
}

/**
 * \brief Respond to NSTableViewSelectionDidChange in the autocompleteTableView.
 *
 * \details Update the contents of the autocomplete text view. As the user
 *          cycles through the table view, the autocomplete text view changes
 *          to reflect the remaining characters in the completion.
 *
 * \param aNotification The notification object containing the
 *        autocompleteTableView.
 */
-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
        [self displaySelectedCompletion];
}

/**
 * \brief Respond to NSTextViewDidChangeSelection in the superTextView.
 *
 * \details Stop the completion timer if the user changes the selection in
 *          the super text view.
 *
 * \param aNotification The notification object containing the superTextView.
 */
-(void)selectionDidChange:(NSNotification *)notification
{
        [self stopCompletionTimer];
}

#pragma mark Delegate Methods

/**
 * \brief Delegate method before the table view receives a mouseDown event.
 *
 * \details Select the appropriate row in the table view, make sure it is
 *          displayed (see below), and make the autocomplete text view the
 *          first responder.
 *
 *          After receiving NSTextDidEndEditing, the autocomplete view is
 *          hidden. However, if text endes editing due to the user clicking on
 *          the table, display the table again here and select the appropriate
 *          row.
 *
 *          Always return NO so that the table view does not process the
 *          mouseDown event.
 *
 * \param tableView The table view sending the message.
 *
 * \param row The row that was clicked.
 */
-(BOOL)tableView:(NSTableView *)tableView shouldReceiveMouseDownInRow:(NSInteger)row
{
        [self setDisplayAutocompletions:YES withAnimation:NO];
        [autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [[[self view] window] makeFirstResponder:autocompleteTextView];
        return NO;
}

/**
 * \brief Delegate method before the autocomplete text view receives a mouseDown
 *        event.
 *
 * \details Clicking the text view hides the entire autocomplete system and
 *          restores the original insertion. Always return NO so that the table
 *          view does not process the mouseDown event.
 *
 * \param textView The text view sending the message.
 */
-(BOOL)textViewShouldReceiveMouseDown:(NSTextView *)textView
{
        [self restoreOriginalInsertion];
        [self setDisplayAutocompletions:NO withAnimation:NO];
        return NO;
}

/**
 * \brief Delegate method used to stylize cells before being displayed.
 *
 * \details If the cell is highlighted, turn off its highlight state (to prevent
 *          any system default highlighting styles) and set its text color to
 *          the inverted theme manager selection color. Otherwise, set its text
 *          color to the normal theme manager foreground color. Set the cell's
 *          font to that of the super text view. Set the cells background style
 *          to prevent it from changing on selection and specify if the cell
 *          will use screen fonts based on what the superTextView uses.
 *
 * \param tableView The table view sending the message.
 *
 * \param tableColumn The table column.
 *
 * \param row The row.
 */
-(void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
        /* Set cell text color based on if it's highlighted */
        NSColor * textColor;
        if ([cell isHighlighted]) {
                [cell setHighlighted:NO];
                textColor = [NSColor colorWithInvertedRedGreenBlueComponents:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerSelection
                                                                                                                          fromGroup:PLThemeManagerSettings]];
        } else {
                textColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                         fromGroup:PLThemeManagerSettings];
        }
        [cell setTextColor:textColor];
        [cell setFont:[[NSFontManager sharedFontManager] selectedFont]];
        [(PLAutocompleteTextFieldCell *)cell setUsesScreenFonts:[[superTextView layoutManager] usesScreenFonts]];
        
        /* Prevent cell text from changing on selection */
        [cell setBackgroundStyle:NSBackgroundStyleLight];
}

/**
 * \brief Delegate method to intercept commands in the autocomplete text view.
 *
 * \details This delegate method allows the autocomplete system to intercept
 *          commands that would otherwise be sent to the superTextView.
 *          The following commands are intercepted and result in the associated
 *          response:
 *              Insert newline or tab - insert the selected completion
 *              Up/down arrow - move the selection in the table view up/down
 *              Delete - Delete in the super text view, delete in the user's
 *                       original completion, and update the autocomplete text
 *                       field.
 *              Escape - Fade out the autocomplete view
 *              Any other - Hide the autocomplete view and send the command to
 *                          the superTextView.
 *              
 *
 * \param textView The text view sending the message (autocomplete text view).
 *
 * \param commandSelector The selector.
 *
 * \return A BOOL specifying if the command has been done in this method. Always
 *         YES as the command is either handled directly here or simply passed
 *         to the superTextView.
 */
-(BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
        NSString * selectorString = nil, * selectedCompletion = nil;
        BOOL didCommand = NO;
        
        selectorString = NSStringFromSelector(commandSelector);
        if ([selectorString isEqualToString:@"insertNewline:"]) {
                [self insertSelectedCompletion];
                didCommand = YES;
        } else if ([selectorString isEqualToString:@"insertTab:"]) {
                [self advanceCompletion];
                didCommand = YES;
        } else if ([selectorString isEqualToString:@"moveUp:"]) {
                [self moveSelection:PLAutocompleteTableMovementUp];
                didCommand = YES;
        } else if ([selectorString isEqualToString:@"moveDown:"]) {
                [self moveSelection:PLAutocompleteTableMovementDown];
                didCommand = YES;
        } else if ([selectorString isEqualToString:@"deleteBackward:"]) {
                if ([originalInsertion length] > 0)
                        [originalInsertion deleteCharactersInRange:NSMakeRange([originalInsertion length] - 1, 1)];
                selectedCompletion = [self selectedCompletion];
                [superTextView deleteBackward:self];
                [self updateCompletions];
                [self setAutocompleteViewSize];
                [self selectCompletion:selectedCompletion];
                [self displaySelectedCompletion];
                didCommand = YES;
        } else {
                [self restoreOriginalInsertion];
                if ([selectorString isEqualToString:@"cancelOperation:"])
                        [self setDisplayAutocompletions:NO withAnimation:YES];
                else {
                        [self setDisplayAutocompletions:NO withAnimation:NO];
                        [superTextView doCommandBySelector:commandSelector];
                }
                didCommand = YES;
        }
        return didCommand;
}

/**
 * \brief Delegate method to change text in the autocomplete text view.
 *
 * \details Text inserted into the autocomplete text view is passed through to
 *          the superTextView and the originalInsertion is updated with the
 *          input.
 *
 * \param textView The text view sending the message.
 *
 * \param affectedCharRange The range of characters to be replaced.
 *
 * \param replacementString The replacement string.
 *
 * \return A BOOL specifying if text should be changed. Always return NO.
 */
-(BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
        [originalInsertion appendString:replacementString];
        [superTextView insertText:replacementString];
        return NO;
}

/**
 * \brief Delegate method to change the selection in the autocomplete text view.
 *
 * \details This method is used as a workaround for handling select all. The
 *          selectAll: message is not sent through the doCommandBySelector
 *          method; however, all other selection commands are. Therefore, if
 *          this delegate method is ever called with a selection length greater
 *          than zero (i.e. not just due to text insertion/deletion), the user
 *          keyed select all in the autocomplete text view.
 *
 *          Select all triggers the autocomplete view to hide and the user's
 *          original insertion to be the only characters left in the current
 *          word. Pass the selectAll: message to the superTextView.
 *
 * \param textView The text view sending the message.
 *
 * \param oldSelectedCharRange The old selected character range.
 *
 * \param newSelectedCharRange The proposed new selected character range.
 *
 * \return The new selected character range. As long as newSelectedCharRange has
 *         this is always the empty range. Otherwise (from text insertion or
 *         deletion), return the newSelectedCharRange.
 */
-(NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange
{
        NSRange newSelectedRange = newSelectedCharRange;
        if (newSelectedRange.length > 0) {
                [self restoreOriginalInsertion];
                [superTextView selectAll:self];
                [self setDisplayAutocompletions:NO withAnimation:NO];
                newSelectedRange = NSMakeRange(0, 0);
        }
        return newSelectedRange;
}

/**
 * \brief Delegate method called when an animation stops.
 *
 * \details If this is the disappear animation for the autocomplete view and it
 *          is finished, hide the autocomplete view and remove the animation.
 *
 * \param anim The animation.
 *
 * \param flag Flag specifying if the animation is finished.
 */
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
        if (flag && anim == [[[self view] layer] animationForKey:PLAutocompleteViewControllerDisappearKey]) {
                [[self view] setHidden:YES];
                [[[self view] layer] removeAnimationForKey:PLAutocompleteViewControllerDisappearKey];
        }
}

/**
 * \brief Called when the mouse moves within the autocomplete tracking area.
 *
 * \details When the mouse is inside the autocomplete view tracking area (stored
 *          in the instance variable trackingArea) that fills the autocomplete
 *          table, set the cursor to the arrow cursor. Without this, the cursor
 *          would be the I-beam normally displayed in text views.
 *
 * \param theEvent Object encapsulating the mouse movement event.
 */
-(void)mouseMoved:(NSEvent *)theEvent
{
        [[NSCursor arrowCursor] set];
}

#pragma mark Completions

/**
 * \brief Update the list of completion strings.
 *
 * \details This method retrieves an array of possible completions from the
 *          superTextView delegate and updates the autocompleteTableView's data
 *          source.
 *
 *          First, obtain the partially entered word in superTextView. Then
 *          query the superTextView delegate for a list of completions within
 *          the partial word range. If the only returned completion is entirely
 *          entered, clear all comletions in the autocompleteTableView data
 *          source. Otherwise, update it with the list of returned completions.
 */
-(void)updateCompletions
{
        NSRange partialRange;
        NSString * partialWord = nil;
        NSArray * completions = nil;

        partialRange = partialWordRangeAtInsertionPoint(superTextView);
        partialWord = [[superTextView string] substringWithRange:partialRange];
        if ([[superTextView delegate] respondsToSelector:@selector(textView:completions:forPartialWordRange:indexOfSelectedItem:)]) {
                completions = [[superTextView delegate] textView:superTextView
                                                     completions:nil
                                             forPartialWordRange:partialRange
                                             indexOfSelectedItem:nil];
                
                /* check if the only completion is already completed in the superTextView */
                if ([completions count] == 1 && [[completions lastObject] isEqualToString:partialWord])
                        completions = @[];
                
                [autocompleteTableDataSource setCompletions:completions];
                [autocompleteTableView reloadData];
        }
}

/**
 * \brief Filter the array of completion strings
 *
 * \details This method filters the list of completion string to those that
 *          begin with filterString. Use a NSPredicate to filter the array of
 *          completions in the autocompleteTableDataSource. Filtering is done
 *          with a case-insensitive comparison. If the only completion remaining
 *          after filtering has already been inserted completely in the
 *          superTextView, set the completions to the empty array.
 *
 *          Set the data source's completions property to the filtered array and
 *          reload the data. The entry in the selected row in the table view
 *          remains selected after filtering.
 *
 * \param filterString The string with which to filter the array. All entries in
 *                     the new completions array will begin with this string.
 */
-(void)filterCompletionsWithString:(NSString *)filterString
{
        NSString * selectedCompletion = nil, * partialWord = nil;
        NSPredicate * predicate = nil;
        NSArray * completions = nil;
               
        predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject]
                                                       rightExpression:[NSExpression expressionForConstantValue:filterString]
                                                              modifier:NSDirectPredicateModifier
                                                                  type:NSBeginsWithPredicateOperatorType
                                                               options:NSCaseInsensitivePredicateOption];
        completions = [[autocompleteTableDataSource completions] filteredArrayUsingPredicate:predicate];
        
        /* check if the only completion is already completed in the superTextView */
        partialWord = partialWordAtInsertionPoint(superTextView);
        if ([completions count] == 1 && [[completions lastObject] isEqualToString:partialWord])
                completions = @[];
        
        selectedCompletion = [self selectedCompletion];
        [autocompleteTableDataSource setCompletions:completions];
        [autocompleteTableView reloadData];
        [self selectCompletion:selectedCompletion];
}

/**
 * \brief Advance the completion by the minimal amount to still match the
 *        beginning of other completion string in the array, inserting the
 *        completion if its remaining characters are unique.
 *
 * \details This method advances the user input of the selected completion by
 *          entering the minimum number of characters of that completion such
 *          that it shares its starting characters with others in the completion
 *          array. If the remaining characters in the selected completion are
 *          unique in the list, it will be inserted in its entirety. Otherwise,
 *          insert the advanced characters into the superTextView and display
 *          the remaining characters in the completion in the
 *          autocompleteTextView.
 *
 *          If no completion is selected, do nothing. If the selected completion
 *          is already inserted in its entirety, call insertSelectedCompletion
 *          and return. Otherwise, iterate over all completions in the array to
 *          determine the minimum amount to advance the selected completion.
 *
 *          The minimum that will be inserted is one character of the selected
 *          completion. This method begins there and iterates over the
 *          characters in the array of possible completions to find the minimum
 *          match length. Then filter the array of completions using the string
 *          up to this match length. If only one completion remains, inserted
 *          it; otherwise, insert the advanced match string into the
 *          superTextView and update the autocompleteTextView.
 */
-(void)advanceCompletion
{
        NSString * selectedCompletion = nil;
        NSUInteger matchLength = 0, matchCounter = 0, partialWordLength = 0;
        NSString * advancedMatch = nil;
        
        /* Exit if no completion is selected */
        selectedCompletion = [self selectedCompletion];
        if (selectedCompletion == nil)
                goto exit;
        
        /* Exit if the selected completion is already entirely inserted */
        partialWordLength = [selectedCompletion length] - [[autocompleteTextView string] length];
        if (partialWordLength == [selectedCompletion length]) {
                [self insertSelectedCompletion];
                goto exit;
        }
        
        /* Determine the minimum match length beginning one character after the inserted word */
        matchLength = [selectedCompletion length];
        for (NSString * completion in [autocompleteTableDataSource completions]) {
                matchCounter = partialWordLength + 1;
                while (matchCounter < [completion length] && matchCounter < [selectedCompletion length]) {
                        if ([completion characterAtIndex:matchCounter] == [selectedCompletion characterAtIndex:matchCounter])
                                matchCounter++;
                        else
                                break;
                }
                if (matchCounter < matchLength)
                        matchLength = matchCounter;
        }
        advancedMatch = [selectedCompletion substringToIndex:matchLength];
        [self filterCompletionsWithString:advancedMatch];
        if ([[autocompleteTableDataSource completions] count] == 1)
                [self insertSelectedCompletion];
        else {
                [superTextView insertText:[advancedMatch substringFromIndex:partialWordLength]];
                [self displaySelectedCompletion];
        }

exit:
        return;
}

#pragma mark Selection

/**
 * \brief Move the selection in the autocomplete table view.
 *
 * \details Move the selection up or down. If trying to move beyond the bounds
 *          of the table view, do nothing. Finally, scroll the table view to
 *          the visible row.
 *
 * \param movement A movement direction, up or down.
 */
-(void)moveSelection:(PLAutocompleteTableMovement)movement
{
        NSInteger newSelectedRow = [autocompleteTableView selectedRow] + movement;
        if (newSelectedRow >= 0 && newSelectedRow < [[autocompleteTableDataSource completions] count]) {
                [autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newSelectedRow] byExtendingSelection:NO];
                [autocompleteTableView scrollRowToVisible:newSelectedRow];
        }
}

/**
 * \brief Return the selected completion in the autocomplete table view.
 *
 * \details Retrieve the string in the autocomplete data source at the index
 *          specified by the table view. If there is no selection, return nil.
 *
 * \return The string of the selected completion.
 */
-(NSString *)selectedCompletion
{
        NSString * selectedCompletion = nil;
        NSInteger selectedRow = [autocompleteTableView selectedRow];
        if (selectedRow >= 0)
                selectedCompletion = [[autocompleteTableDataSource completions] objectAtIndex:selectedRow];
        return selectedCompletion;
}

/**
 * \brief Select a completion in the autocomplete table view.
 *
 * \details Find the index of the string in the array of completions. If it is
 *          present, select the row and scroll the table view such that this row
 *          is visible.
 */
-(void)selectCompletion:(NSString *)completion
{
        NSUInteger selectionIndex = 0;
        
        selectionIndex = [[autocompleteTableDataSource completions] indexOfObject:completion];
        if (selectionIndex != NSNotFound) {
                [autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectionIndex]
                                   byExtendingSelection:NO];
                [autocompleteTableView scrollRowToVisible:selectionIndex];
        }
}

/**
 * \brief Insert the selected completion in the superTextView.
 *
 * \details This method simply updates the insertion point in the superTextView
 *          and hides the autocomplete view since every selection in the table
 *          view is inserted into the superTextView. Release the
 *          originalInsertion and set it to nil as it is no longer valid.
 */
-(void)insertSelectedCompletion
{
        NSUInteger newInsertionPoint = [superTextView selectedRange].location + [[autocompleteTextView string] length];
        [superTextView setSelectedRange:NSMakeRange(newInsertionPoint, 0)];
        [originalInsertion release];
        originalInsertion = nil;
        [self setDisplayAutocompletions:NO withAnimation:NO];
}

/**
 * \brief Delete the displayed autocompletion.
 *
 * \details Delete the characters in the superTextView beginning at the current
 *          insertion point for the length of the autocompleteTextView string.
 *          Delete all characters in the autocompleteTextView.
 */
-(void)deleteCompletion
{
        NSUInteger completionLength = [[autocompleteTextView string] length];
        if (completionLength > 0) {
                [[superTextView textStorage] deleteCharactersInRange:NSMakeRange([superTextView selectedRange].location, completionLength)];
                [[autocompleteTextView textStorage] deleteCharactersInRange:NSMakeRange(0, completionLength)];
        }
}

/**
 * \brief Restore the text inserted by the user behind the autocompleteTextView.
 *
 * \details If originalInsertion is set (not nil), delete the inserted
 *          completion and insert the originalInsertion string into the
 *          superTextView.
 */
-(void)restoreOriginalInsertion
{
        NSRange insertionRange;
        if (originalInsertion) {
                insertionRange = NSMakeRange([superTextView selectedRange].location - [originalInsertion length], [originalInsertion length]);
                [self deleteCompletion];
                [[superTextView textStorage] replaceCharactersInRange:insertionRange
                                                           withString:originalInsertion];
                [originalInsertion release];
                originalInsertion = nil;
        }
}

/**
 * \brief Display the remaining characters of the selected completion.
 *
 * \details The inserted completion consists of the characters in the selected
 *          completion following those already inserted in the superTextView by
 *          the user. This method first deletes any existing inserted
 *          completion. It then determines the partially entered string in the
 *          superTextView, strips its starting characters, and sets its font
 *          color to that specified by the theme manager with a decreased alpha.
 *          Finally, it inserts the string into both the autocompleteTextView
 *          and superTextView and updates the autocompleteTextView size and
 *          position. The string inserted into the superTextView uses the
 *          attributes of the superTextView textStorage, unless it is empty, in
 *          which the attributes are the theme manager font color and the shared
 *          font manager font.
 *
 *          The insertion point in the autocompleteTextView is always set to
 *          zero. In the superTextView, it is unchanged from before this method
 *          was called. Therefore, the insertion point always lies in between
 *          the partially entered word in the superTextView and the first
 *          character of the autocompleteTextView.
 *
 *          If the autocompleteTextView is hidden or there is no selected
 *          completion in the autocompleteTableView, do nothing.
 *
 *          This method also sets the screen font substitution property of the
 *          autocompleteTextView layout manager to that of the superTextView.
 *          This ensures that the spacing between characters matches in both
 *          text views.
 */
-(void)displaySelectedCompletion
{
        NSUInteger insertionPointLocation = 0;
        NSRange insertedWordRange;
        NSString * partialCompletion = nil;
        NSColor * textColor = nil;
        NSDictionary * attributes = nil;
        NSAttributedString * insertedCompletion = nil;
        NSMutableAttributedString * displayedCompletion = nil;
        CGFloat textAlpha = 0.4;
        BOOL usesScreenFonts = NO;
        
        if ([autocompleteTextView isHidden] || [self selectedCompletion] == nil)
                goto exit;

        /* set screen fonts */
        usesScreenFonts = [[superTextView layoutManager] usesScreenFonts];
        if ([[autocompleteTextView layoutManager] usesScreenFonts] != usesScreenFonts)
                [[autocompleteTextView layoutManager] setUsesScreenFonts:usesScreenFonts];

        /* delete old completion and insert new completion */
        [self deleteCompletion];
        insertionPointLocation = [superTextView selectedRange].location;
        insertedWordRange = partialWordRangeAtInsertionPoint(superTextView);
        partialCompletion = [[self selectedCompletion] substringFromIndex:insertionPointLocation - insertedWordRange.location];
        textColor = [[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                  fromGroup:PLThemeManagerSettings];
        if ([[superTextView string] length] == 0) {
                attributes = @{NSFontAttributeName: [[NSFontManager sharedFontManager] selectedFont],
                               NSForegroundColorAttributeName: textColor};
        } else {
                attributes = [[superTextView textStorage] attributesAtIndex:insertedWordRange.location
                                                             effectiveRange:NULL];
        }
        
        insertedCompletion = [[NSAttributedString alloc] initWithString:[self selectedCompletion]
                                                             attributes:attributes];
        [[superTextView textStorage] replaceCharactersInRange:insertedWordRange
                                         withAttributedString:insertedCompletion];
        
        displayedCompletion = [[NSMutableAttributedString alloc] initWithString:partialCompletion
                                                                     attributes:attributes];
        [displayedCompletion addAttribute:NSForegroundColorAttributeName
                                    value:[textColor colorWithAlphaComponent:textAlpha]
                                    range:NSMakeRange(0, [displayedCompletion length])];
        [[autocompleteTextView textStorage] appendAttributedString:displayedCompletion];
        
        /* update insertion points and text view frame */
        [autocompleteTextView setSelectedRange:NSMakeRange(0, 0)];
        [superTextView setSelectedRange:NSMakeRange(insertionPointLocation, 0)];
        [self setAutocompleteTextViewFrame];
        
exit:
        [insertedCompletion release];
        [displayedCompletion release];
        return;
}

#pragma mark Autocomplete Text View

/**
 * \brief Set the autocompleteTextView frame.
 *
 * \details This method first calculates the bounding rect beginning at the
 *          insertion point in the superTextView extending for the length of the
 *          autocompleteTextView string. Put simply, it is the rect of the
 *          autocompleteTextView characters in the superTextView.
 *
 *          The origin is the bounding rect offset by the superTextView
 *          textContainerOrigin. Its x position is decreased by the
 *          autocompleteTextView's line fragment padding, such that its first
 *          character will overlap the character inserted in the superTextView.
 *
 *          The size is the bounding rect with the width increased by twice the
 *          autocompleteTextView's line fragment padding to account for this
 *          space on both sides.
 */
-(void)setAutocompleteTextViewFrame
{
        NSRect frame = NSZeroRect, boundingRect = NSZeroRect;
        NSPoint containerOrigin = NSZeroPoint;
        CGFloat autocompleteTextViewPadding = 0.0;
        NSRange charRange;

        charRange = NSMakeRange([superTextView selectedRange].location, [[autocompleteTextView string] length]);
        boundingRect = boundingRectForCharacterRange(superTextView, charRange);
        autocompleteTextViewPadding = [[autocompleteTextView textContainer] lineFragmentPadding];

        /* Calculate origin */
        containerOrigin = [superTextView textContainerOrigin];
        frame.origin.x = boundingRect.origin.x + containerOrigin.x - autocompleteTextViewPadding;
        frame.origin.y = boundingRect.origin.y + containerOrigin.y;

        /* Calculate size */
        frame.size.width = boundingRect.size.width + 2 * autocompleteTextViewPadding;
        frame.size.height = boundingRect.size.height;

        [autocompleteTextView setFrame:frame];
}

/**
 * \brief Display or hide the autocompleteTextView.
 *
 * \details When displayed, the autocomplete text view is unhidden and made
 *          first responder. Initialize the originalInsertion to the text that
 *          the user has already inserted of the partial word and update the
 *          contents of the autocompleteTextView. When hiding, delete all
 *          characters in the autocompleteTextView and make the superTextView
 *          first responder.
 *
 *          This method only proceeds to hide or display the
 *          autocompleteTextView if it is already displayed or hidden,
 *          respectively.
 */
-(void)setDisplayAutocompleteTextView:(BOOL)displayTextField
{
        NSString * insertedString = nil;

        if (displayTextField && [autocompleteTextView isHidden]) {
                if ([[autocompleteTextView font] isEqual:[superTextView font]] == NO)
                        [autocompleteTextView setFont:[superTextView font]];

                insertedString = partialWordAtInsertionPoint(superTextView);
                originalInsertion = [[NSMutableString alloc] initWithString:insertedString];
                [autocompleteTextView setHidden:NO];
                [[[self view] window] makeFirstResponder:autocompleteTextView];
                [self displaySelectedCompletion];
        } else if (displayTextField == NO && [autocompleteTextView isHidden] == NO) {
                [[autocompleteTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[autocompleteTextView string] length])];
                [autocompleteTextView setHidden:YES];
                [[[self view] window] makeFirstResponder:superTextView];
        }
}

#pragma mark Autocomplete Table View

/**
 * \brief Set the row height of the autocomplete table view.
 *
 * \details This method sets the row height such that text is centered within
 *          each cell. The height is set to the font height plus the intercell
 *          height, such that the text in each cell has the same buffer on each
 *          side.
 */
-(void)setAutocompleteTableRowHeight
{
        CGFloat intercellHeight = 0.0;
        CGFloat lineHeight = [[[NSFontManager sharedFontManager] selectedFont] boundingRectForFont].size.height;
        [autocompleteTableView setIntercellSpacing:NSMakeSize([autocompleteTableView intercellSpacing].width, intercellHeight)];
        [autocompleteTableView setRowHeight:lineHeight + intercellHeight];
}

/**
 * \brief Set the autocomplete table view origin.
 *
 * \details The autocomplete table view is anchored to a character in the
 *          superTextView. This anchor position is to the bounding rect of the
 *          character, offset by the textContainerOrigin. The x position is
 *          decreased by the intercellSpacing width so that the characters in
 *          each cell vertically align with those in the text view. The y
 *          position is decreased by the height of the bounding rect so that it
 *          is placed below the text.
 *
 *          This method sets the origin of the controller's view, which contains
 *          the autocomplete table view within a scroll view.
 *
 * \param characterIndex The character to anchor the table view to.
 */
-(void)setAutocompleteViewOrigin:(NSUInteger)characterIndex
{
        NSUInteger anchorIndex = 0;
        NSRect boundingRect = NSZeroRect;
        NSPoint containerOrigin = NSZeroPoint;
        CGFloat xPosition = 0.0, yPosition = 0.0;
        
        anchorIndex = [[superTextView string] wordRangeAtIndex:characterIndex].location;
        boundingRect = boundingRectForCharacterRange(superTextView, NSMakeRange(anchorIndex, 0));
        containerOrigin = [superTextView textContainerOrigin];
        
        /* decrease x position by cell spacing to line with text */
        xPosition = boundingRect.origin.x + containerOrigin.x - [autocompleteTableView intercellSpacing].width;
        
        /* increase y position to place below text */
        yPosition = boundingRect.origin.y + containerOrigin.y + boundingRect.size.height;
        
        [[self view] setFrameOrigin:NSMakePoint(xPosition, yPosition)];
}

/**
 * \brief Set the autocomplete table view size.
 *
 * \details This method sets the size of the controller's view, which contains
 *          the autocomplete table view within a scroll view. If there are no
 *          rows in the table view, do nothing.
 *
 *          The height of the table view is calculated as the number of rows to
 *          display times the row height (the sum of the rowHeight and
 *          intercellSpacing height). The number of displayed rows is the
 *          minimum necessary to include all autocompletion options, up to 8.
 *          The vertical scroller is only shown if there are more than 8 rows.
 *
 *          The width of the table view calculated as the number of characters
 *          to display times the width of each character. The minimum width is
 *          bounded at 20 characters. The width will increase as necessary to
 *          include all characters of the longest entry in the table view.
 *          For aesthetics, a trailing buffer of four characters is added.
 */
-(void)setAutocompleteViewSize
{
        const NSUInteger widthBuffer = 4, minimumCharactersOnLine = 20, maximumTableEntries = 8;
        NSUInteger numCompletions = 0, height = 0, width = 0;
        NSArray * sortedCompletions = nil;
        CGFloat fontWidth = 0.0;
        
        numCompletions = [[autocompleteTableDataSource completions] count];
        if (numCompletions == 0)
                goto exit;
        
        /* calculate height of view */
        height = MIN(numCompletions, maximumTableEntries) * ([autocompleteTableView rowHeight] + [autocompleteTableView intercellSpacing].height);
        if (numCompletions <= maximumTableEntries)
                [autocompleteScrollView setHasVerticalScroller:NO];
        else
                [autocompleteScrollView setHasVerticalScroller:YES];
        
        /* calculate width of view */
        sortedCompletions = [[autocompleteTableDataSource completions] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 length] < [obj2 length];
        }];
        fontWidth = [[[NSFontManager sharedFontManager] selectedFont] maximumAdvancement].width;
        width = MAX(minimumCharactersOnLine * fontWidth, [[sortedCompletions objectAtIndex:0] length] * fontWidth) + widthBuffer * fontWidth;

        [autocompleteTableColumn setWidth:width];
        [[self view] setFrameSize:NSMakeSize(width, height)];
        
exit:
        return;
}

-(void)toggleDisplayAutocompletions
{
        [self updateCompletions];
        if ([[autocompleteTableDataSource completions] count] == 0) {
                [[self view] setFrameSize:[noCompletionsView frame].size];
                [noCompletionsView setHidden:NO];
        } else
                [noCompletionsView setHidden:YES];

        [self setDisplayAutocompletions:[[self view] isHidden]
                          withAnimation:YES];
        
        if ([[autocompleteTableDataSource completions] count] > 0) {
                [autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                                   byExtendingSelection:NO];
                [autocompleteTableView scrollRowToVisible:0];
        }
}

/**
 * \brief Display or hide the autocomplete view.
 *
 * \details This is the primary method used to hide or display the autocomplete
 *          system, including both the table and text views. It will do nothing
 *          if trying to hide when the autocomplete system is hidden and vice
 *          versa. The tracking area over the table view is cleared if hiding
 *          the view and restored if displaying the view.
 *
 *          When hiding the view, hide both the table view and text view and
 *          stop the autocompletion timer. If the No Completions view is not
 *          hidden, hide it here.
 *
 *          When displaying the view, anchor it to the insertion point, such
 *          that each entry in table view vertically aligns with the characters
 *          entered in the text view. If there are entries in the table view,
 *          display the autocompleteTextView and set the size of the table view.
 *          
 *          If displaying the completions, but there are no entries in the table
 *          view and the No Completions view is hidden, recall this method with
 *          displayAutocompletions and animate as NO.
 *
 * \param displayAutocompletions Display or hide the autocompletion view.
 *
 * \param animate If YES, animate the appearance or disappearance. Appearance
 *                animation bounces the view, disappearance fades out.
 */
-(void)setDisplayAutocompletions:(BOOL)displayAutocompletions withAnimation:(BOOL)animate
{
        if (displayAutocompletions == NO)
                [self stopCompletionTimer];
        
        if ((displayAutocompletions && [[self view] isHidden] == NO) || (displayAutocompletions == NO && [[self view] isHidden]))
            goto exit;
        
        if (displayAutocompletions && [[autocompleteTableDataSource completions] count] == 0 && [noCompletionsView isHidden]) {
                [self setDisplayAutocompletions:NO withAnimation:NO];
                goto exit;
        }

        /* remove tracking area */
        if (trackingArea) {
                [[self view] removeTrackingArea:trackingArea];
                [trackingArea release];
                trackingArea = nil;
        }

        if (displayAutocompletions == NO) {
                if (animate)
                        [[[self view] layer] addAnimation:[self disappearAnimation] forKey:PLAutocompleteViewControllerDisappearKey];
                else
                        [[self view] setHidden:YES];
                [self setDisplayAutocompleteTextView:NO];
                if ([noCompletionsView isHidden] == NO)
                        [noCompletionsView setHidden:YES];
        } else {
                [self setAutocompleteViewOrigin:[superTextView selectedRange].location];
                if ([[autocompleteTableDataSource completions] count] > 0) {
                        [self setDisplayAutocompleteTextView:YES];
                        [self setAutocompleteViewSize];
                }

                [[self view] setHidden:NO];
                if (animate)
                        [[[self view] layer] addAnimation:[self appearAnimation] forKey:@"animateAppear"];

                trackingArea = [[NSTrackingArea alloc] initWithRect:[autocompleteTableView frame]
                                                            options:(NSTrackingActiveInKeyWindow | NSTrackingMouseMoved | NSTrackingInVisibleRect)
                                                              owner:self
                                                           userInfo:nil];
                [[self view] addTrackingArea:trackingArea];
        }

exit:
        return;
}

#pragma mark Animations

/**
 * \brief Return the appearance animation for the autocomplete table view.
 *
 * \details The animation group contains two scaling animations. The first
 *          oversizes the view and second shrinks it back to its normal full
 *          size. The result is a bounce-like animation.
 *
 * \return The animation group.
 */
-(CAAnimationGroup *)appearAnimation
{
        CABasicAnimation * growAnimation, * bounceAnimation;
        CAAnimationGroup * animationGroup;
        float growTime = 0.1, growSize = 1.2;
        
        growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [growAnimation setFromValue:[NSNumber numberWithFloat:0.4]];
        [growAnimation setToValue:[NSNumber numberWithFloat:growSize]];
        [growAnimation setDuration:growTime];
        [growAnimation setAutoreverses:NO];
        
        bounceAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        [bounceAnimation setFromValue:[NSNumber numberWithFloat:growSize]];
        [bounceAnimation setToValue:[NSNumber numberWithFloat:1.0]];
        [bounceAnimation setDuration:0.1];
        [bounceAnimation setBeginTime:growTime];
        [bounceAnimation setAutoreverses:NO];
        
        animationGroup = [CAAnimationGroup animation];
        [animationGroup setAnimations:@[growAnimation, bounceAnimation]];
        
        return animationGroup;
}

/**
 * \brief Return the disappearance animation for the autocomplete table view.
 *
 * \details The animation fades out the view by decreasing its opacity to zero.
 *
 * \return The basic animation.
 */
-(CABasicAnimation *)disappearAnimation
{
        CABasicAnimation * disappearAnimation;
        float disappearTime = 0.075;
        
        disappearAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [disappearAnimation setDuration:disappearTime];
        [disappearAnimation setFromValue:[NSNumber numberWithFloat:1.0]];
        [disappearAnimation setToValue:[NSNumber numberWithFloat:0.0]];
        [disappearAnimation setRemovedOnCompletion:NO];
        [disappearAnimation setFillMode:kCAFillModeForwards];
        [disappearAnimation setDelegate:self];
        
        return disappearAnimation;
}

#pragma mark Timers

/**
 * \brief Trigger the autocompletion to display.
 *
 * \details This is the target of the autocompletion timer, used to display the
 *          autocompletion view without an animation.
 */
-(void)doCompletion:(NSTimer *)timer
{
        [self updateCompletions];
        [self setDisplayAutocompletions:YES withAnimation:NO];
        [autocompleteTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0]
                           byExtendingSelection:NO];
        [autocompleteTableView scrollRowToVisible:0];
}

/**
 * \brief Start the completion timer.
 *
 * \details Stop the active completion timer and restart it with a trigger
 *          interval of 1.0 seconds. Call the doCompletion method when triggers.
 */
-(void)startCompletionTimer {
        NSTimeInterval timeInterval = 1.0;
        [self stopCompletionTimer];
        completionTimer = [[NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                            target:self
                                                          selector:@selector(doCompletion:)
                                                          userInfo:nil
                                                           repeats:NO] retain];
}

/**
 * \brief Stop the completion timer.
 *
 * \details Invalidate and release the active timer.
 */
-(void)stopCompletionTimer {
        [completionTimer invalidate];
        [completionTimer release];
        completionTimer = nil;
}

@end
