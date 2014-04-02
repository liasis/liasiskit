/**
 * \file PLLineNumberView.h
 * \brief Liasis Python IDE line number ruler view for text editor.
 *
 * \details
 * This file contains the function prototypes and interface for a NSRulerView 
 * subclass to display line numbers. This class controls a set of views tha make
 * up the text editor capabilities of the python IDE.
 *
 * \copyright
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

#import <AppKit/AppKit.h>

/**
 * \class PLLineNumberView \headerfile \headerfile
 * \brief A NSRulerView subclass that displays the line number for each line of text
 *        in a text view within a NSScrollView.
 *
 * \details The PLLineNumberView overrides the NSRulerView functionality, and uses 
 *          NSTextFields for line number labels, which are used during layout and 
 *          display calculations. Line number labels are attached to specific
 *          y-coordinates that match the line number in the NSTextView. The line 
 *          number view's bounds change to move the labels during scrolling.
 *          Important note: for this to work, the scroll view's contentView
 *          associated with this ruler must have postsBoundsChangedNotification
 *          set to YES. This is done here, but it must not be set to NO
 *          elsewhere.
 *
 *          The line number view uses several features to optimize line number
 *          calculation and display. Line numbers are calculated based on the 
 *          current state of the text with relation to the future state of the 
 *          text. Because of this, the line number view is designed to be 
 *          compatible only with a text view using a PLTextStorage object by
 *          calculating changes during a PLTextStorageWillReplaceStringNotification.
 *
 *          The frame for the line number NSTextField objects are cached in a 
 *          mutable dictionary to avoid excessive line rect calculations within
 *          the NSTextView by the NSLayoutManager object during scrolling.
 *          Editing at a line removes all cached line numbers text fields following
 *          the line number of the edited range. Resizing the width of the
 *          NSScrollView removes all the cached line number text fields.
 *
 *          Important note: the clientView associated with this ruler must have
 *          postsFrameChangedNotification set to YES. This is done here, but it
 *          must not be set to NO elsewhere.
 *
 * \see PLTextStorage
 * \see PLTextStorageWillReplaceStringNotification
 */
@interface PLLineNumberView : NSRulerView {
        /**
         * \brief Dictionary relating the line number and the NSTextField
         *        containing formatting and positional information for drawing
         *        line numbers.
         *
         * An NSMutableDictionary that stores the NSTextField's that have been
         * used, in order to optimize scrolling efficiency. The dictionary
         * is routinely cleared upon changing the text view frame size.
         * Text fields for lines that are downstream of an edited line are also 
         * removed, as this does not severely impact scrolling performance and 
         * serves as a routine purge of excess memory usage.
         */
        NSMutableDictionary * lineNumberLabels;
        /**
         * \brief Dictionary relating position in text with physical line number.
         *
         * An NSMutableDictionary relating a physical line in a string and the index 
         * of the first character of that line. The keys are NSString objects and 
         * the values are NSNumber objects.
         */
        NSMutableDictionary * lineNumberIndex;
        /**
         * \brief Set of line numbers with exact occurance of breakpoint string.
         *
         * An NSMutableSet object with NSString objects containing the line 
         * number at which a breakpoint string is found.
         */
        NSMutableSet * markers;     
        /**
         * \brief The background color of the client view.
         *
         * An NSColor object representing the background color of the target 
         * text view object. This color is blended with its inverted color to
         * generate a shaded ruler view.
         */
        NSColor * backgroundColor;
        /**
         * \brief The text color of the client view.
         */
        NSColor * textColor;
        /**
         * \brief The color used to highlight line numbers currently selected.
         */
        NSColor * selectedColor;
        /**
         * \brief The width of the gutter between text view and the line numbering.
         */
        CGFloat gutterThickness;
}

#pragma mark Setters and Getters
/**
 * \brief Creates the line number view background color that is consistent
 *        with a specified color.
 *
 * \details Sets the background color for the line number view by blending the
 *          color that is passed to it with its inverted color. This is done to
 *          make the line number view visible and consistent with different 
 *          themes.
 *
 * \param textViewBackgroundColor An NSColor instance with the color used for the
 *                                background of the client text view. The NSColor
 *                                must be defined with an RGB colorspace.
 *
 * \warning The NSColor textViewBackgroundColor must be defined using an RGB colorspace.
 */
-(void)makeBackgroundColorFromColor:(NSColor *)textViewBackgroundColor;

/**
 * \brief Class property specifying the getter method for the line number view 
 *        background color.
 *
 * \return Returns an NSColor with the background color used by the line number
 *         view.
 */
@property(readonly, retain) NSColor * backgroundColor;

/**
 * \brief Setter method for the for the line number view text color.
 *
 * \param aColor An NSColor object specifying the color that will be used to 
 *               display the line numbers.
 */
-(void)setTextColor:(NSColor *)aColor;

/**
 * \brief Class property specifying the getter method for the line number view
 *        text color.
 *
 * \return Returns an NSColor with the text color used by the line number
 *         view.
 */
@property(readonly, retain) NSColor * textColor;

/**
 * \brief Setter method for the for the line number view highlight color for
 *        selected lines.
 *
 * \param aColor An NSColor object specifying the color that will be used to
 *               highlight selected lines.
 */
-(void)setSelectedColor:(NSColor *)aColor;

/**
 * \brief Class property specifying the getter method for the line number view
 *        selected line highlight color.
 *
 * \return Returns an NSColor with the text color used by the line number
 *         view to highlight selected lines.
 */
@property(readonly, retain) NSColor * selectedColor;

/**
 * \brief Getter method to obtain the number of lines in the text document displayed
 *        in the clinet text view.
 *
 * \return Returns an NSUInteger representing the number of semantic lines stored
 *         in the NSTextStorage of the client text view.
 */
-(NSUInteger)numberOfLines;

#pragma Overriding superclass method prototypes

-(NSTextView *)clientView;

-(void)setClientView:(NSTextView *)client;

#pragma mark Event Handling

/**
 * \brief Intercepts mouseDown events, which can be used to add markers to the
 *        ruler view.
 *
 * \details This method is invoked whenever the ruler view receives a mouse down
 *          event, which can be used to add markers and to highlight a specific
 *          line. If the event is detected within the ruler view's gutter,
 *          the line number causes the text editor to highlight the entire line.
 *          If line number itself is clicked, the default breakpoint string is
 *          added. The line number view records the line numbers that contain
 *          markers and draw special symbols at thos lines.
 *
 * \param theEvent An NSEvent passed to the method. This method obtains the
 *                 location of the mouse down relative to its own frame.
 */
-(void)mouseDown:(NSEvent *)theEvent;

#pragma Line number calculation

/**
 * \brief Method that calculates the first character index for each new line.
 *
 * \details This method is an umbrella method that is used to calculate the
 *          changes in the character index for each physical line in the file
 *          based on comparing the old state of the corresponding text storage with
 *          what will be the new state. This method is designed to be called
 *          by an object responding to the PLTextStorageWillReplaceStringNotification.
 *          This method captures the effects of changes in length, and chenges 
 *          newline characters. Becuase the nine number calculation depends only
 *          on effective changes, the line number view is expected to calculate
 *          line numbers very efficiently.
 *
 * \param editedRange An NSRange value specifying the location and range of edited 
 *                    characters in the text storage object.
 *
 * \param string An NSString object with the replacement string.
 *
 * \see PLTextStorage
 */
-(void)updateLineNumbersForEditedRange:(NSRange)editedRange withReplacementString:(NSString *)string;



@end
