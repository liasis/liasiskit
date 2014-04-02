/**
 * \file PLAutocompleteTextView.h
 * \brief Liasis Python IDE autocomplete text view interface file.
 *
 * \details This is a NSTextView subclass that provides posts a notification
 *          when a user clicks inside.
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
#import "PLAutocompleteDelegate.h"

/**
 * \class PLAutocompleteTextView \headerfile \headerfile
 *
 * \brief Subclass of NSTextView to interact with its delegate on mouseDown
 *        events.
 *
 * \details This class implements the mouseDown: method in order to query its
 *          delegate before processing the event.
 */
@interface PLAutocompleteTextView : NSTextView

/**
 * \brief Delegate property conforming to the PLAutocompleteTextViewDelegate
 *        protocol.
 *
 * \details This property serves to further specify the NSTextViewDelegate
 *          delegate. The superclass is responsible for retaining it and
 *          synthesizing the accessor methods. Therefore, the subclass only
 *          assigns its value and uses the @dynamic directive in its
 *          implementation.
 *
 * \see PLAutocompleteTextViewDelegate
 */
@property(assign) id <PLAutocompleteTextViewDelegate> delegate;

@end
