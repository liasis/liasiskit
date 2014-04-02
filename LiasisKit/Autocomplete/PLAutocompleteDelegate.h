/**
 * \file PLAutocompleteDelegate.h
 * \brief Liasis Python IDE autocomplete delegate protocols.
 *
 * \details This file contains two protocols for the autocomplete system.
 *          PLAutocompleteTextViewDelegate adds a method to the NSTextView
 *          delegate protocol and PLAutocompleteTableViewDelegate does so for
 *          the NSTableViewDelegate protocol
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

#import <Foundation/Foundation.h>

/**
 * \protocol PLAutocompleteTextViewDelegate \headerfile \headerfile
 *
 * \brief Extend the NSTextViewDelegate with a mouseDown-related method.
 *
 * \details This protocol adds one required method to the NSTextViewDelegate for
 *          text view's to ask their delegate before receiving a mouseDown
 *          event.
 */
@protocol PLAutocompleteTextViewDelegate <NSTextViewDelegate>

/**
 * \brief Ask the delegate before a text view receives a mouseDown event.
 *
 * \details This method is used by text view's in their mouseDown implementation
 *          to query the delegate before handling the event. Delegates may then
 *          handle the event themselves and tell the text view to ignore it.
 *
 * \param textView The text view sending the message.
 */
-(BOOL)textViewShouldReceiveMouseDown:(NSTextView *)textView;

@end

/**
 * \protocol PLAutocompleteTableViewDelegate \headerfile \headerfile
 *
 * \brief Extend the NSTableViewDelegate with a mouseDown-related method.
 *
 * \details This protocol adds one required method to the NSTableViewDelegate
 *          for table view's to ask their delegate before receiving a mouseDown
 *          event in a row.
 */
@protocol PLAutocompleteTableViewDelegate <NSTableViewDelegate>

/**
 * \brief Ask the delegate before a table view receives a mouseDown event.
 *
 * \details This method is used by table view's in their mouseDown
 *          implementation to query the delegate before handling the event.
 *          Delegates may then handle the event themselves and tell the text
 *          view to ignore it.
 *
 * \param textView The table view sending the message.
 */
-(BOOL)tableView:(NSTableView *)tableView shouldReceiveMouseDownInRow:(NSInteger)row;

@end
