/**
 * \file PLAutocompleteViewController.h
 * \brief Liasis Python IDE autocomplete view controller interface file.
 *
 * \details This file contains the interface for the autocomplete view
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
 */

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "PLThemeManager.h"
#import "PLThemeable.h"
#import "PLAutocompleteDelegate.h"
#import "PLAutocompleteDataSource.h"
#import "PLAutocompleteTableView.h"
#import "PLAutocompleteTextView.h"
#import "PLAutocompleteTextFieldCell.h"
#import "NSString+wordAtIndex.h"

/**
 * \class PLAutocompleteViewController \headerfile \headerfile
 *
 * \brief Control the autocomplete system, comprised of a table and text view.
 *
 * \details The PLAutocompleteViewController manages all components of the
 *          autocomplete system. Its view is a table view enclosed in a scroll
 *          view. When the user has typed a partial word, the table view
 *          appears with a list of possible completions. The completion is
 *          displayed in an overlayed text view. This allows the controller
 *          further control over how this remaining text is displayed,
 *          bypassing any syntax coloring in the main text view (or: super text
 *          view, as it is the superview of the autocomplete system) All text
 *          that appears in the autocomplete text view is also inserted into the
 *          super text view so that the following characters are adjusted
 *          accordingly.
 *
 *          This controller is initalized with a super text view. After which,
 *          there are only two ways to interact with the controller: (1) set a
 *          new super text view and (2) toggle the autocompletion system to
 *          display. Autocompletion occurs on a timer specified by the
 *          controller, such that as a user inputs text and pauses, the
 *          autocompletion system will display if there are any completions to
 *          show. Once visible, the user is able to use the arrow keys to
 *          traverse the table view, enter to insert the selection, and tab to
 *          advance the characters in the completion by groups matching other
 *          completions in the list.
 *
 *          Toggling the autocomplete system allows the owner of this
 *          controller to display the window at other events, such as providing
 *          the user a keystroke to hide and redisplay the list of
 *          autocompletions. If no completions are available, a "No Completions"
 *          popup is shown instead when toggling.
 */
@interface PLAutocompleteViewController : NSViewController <PLAutocompleteTableViewDelegate, PLAutocompleteTextViewDelegate, PLThemeable>
{
        /**
         * \brief The scroll view containing the autocomplete table view.
         */
        IBOutlet NSScrollView * autocompleteScrollView;
        
        /**
         * \brief The autocomplete table view.
         */
        IBOutlet PLAutocompleteTableView * autocompleteTableView;
        
        /**
         * \brief The one column of the autocomplete table view.
         */
        IBOutlet NSTableColumn * autocompleteTableColumn;
        
        /**
         * \brief The autocomplete table view data source, containing the list
         *        of possible completions.
         */
        IBOutlet PLAutocompleteDataSource * autocompleteTableDataSource;
        
        /**
         * \brief The view displayed when no completions are available. It is
         *        shown within the autocompleteScrollView.
         */
        IBOutlet NSView * noCompletionsView;
        
        /**
         * \brief The layer used for layer-hosting in the autocomplete view.
         *
         * \details The autocomplete view is the view property of this
         *          controller.
         */
        CALayer * autocompleteViewLayer;
        
        /**
         * \brief The layer used for layer-hosting in the
         *        autocompleteScrollView.
         */
        CALayer * autocompleteScrollViewLayer;
        
        /**
         * \brief The autocomplete text view. This contains the remainder of the
         *        completion that the user has not input.
         */
        PLAutocompleteTextView * autocompleteTextView;
        
        /**
         * \brief The text view containing the autocomplete table/text view.
         */
        NSTextView * superTextView;
        
        /**
         * \brief The tracking area of the autocomplete table view, used to
         *        switch the mouse cursor to an arrow.
         */
        NSTrackingArea * trackingArea;
        
        /**
         * \brief The timer used to trigger autocomplete display.
         */
        NSTimer * completionTimer;

        /**
         * \brief The original text inserted by the user.
         *
         * \details As the user cycles through completion options, the text
         *          inserted originally may change if the selected completion
         *          has a different case. This variable is used to restore the
         *          originally entered text if the user cancels autocompletion.
         */
        NSMutableString * originalInsertion;
}

/**
 * \brief Factory method to initialize the autocomplete view controller with a
 *        text view to display autocompletions within.
 *
 * \details Load the xib file call setTextView: with the textView argument. The
 *          autocomplete view is then set to be displayed within the text view
 *          on a timer and when explicitely toggled.
 *
 * \param textView The text view that will contain the autocomplete table and
 *                 text views.
 *
 * \return A PLAutocompleteViewController on the autorelease pool. As long as
 *         this controller is active, autocomplete will operate within the
 *         provided text view.
 */
+(id)viewControllerWithTextView:(NSTextView *)textView;

/**
 * \brief Set the text view where the autocomplete table/text view is shown.
 *
 * \details This method replaces the superTextView instance variable. The text
 *          view is used to determine the font in the autocomplete system and
 *          identify when text changes using the NSTextDidChangeNotification.
 *
 *          If a superTextView exists, remove the autocomplete view and text
 *          view as subviews, stop observing NSTextDidChangeNotification, and
 *          release it.
 *
 *          If the new textView is not nil, add the autocomplete view and text
 *          view as subviews. Set the autocomplete text view font and the
 *          table view's height based on this font size. Observe the
 *          NSTextDidChangeNotification of this textView.
 *
 * \param textView The text view to display the autocomplete within. This may be
 *                 nil to only remove the previous text view.
 */
-(void)setTextView:(NSTextView *)textView;

/**
 * \brief Toggle if the autocomplete view is displayed or not.
 *
 * \details If the autocomplete view is displayed, hide it with a fade out
 *          animation. Otherwise, display it with a bounce animation. Display a
 *          No Completions view if no completions are available. This event is
 *          commonly bound to a user pressing the escape key.
 */
-(void)toggleDisplayAutocompletions;

@end
