/**
 * \file PLAutocompleteTableView.h
 * \brief Liasis Python IDE autocomplete table view interface file.
 *
 * \details This is a NSTableView subclass that provides gradient highlighting
 *          for its rows and posts a notification when a user clicks on a row.
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
#import "PLThemeManager.h"
#import "PLAutocompleteDelegate.h"

/**
 * \class PLAutocompleteTableView \headerfile \headerfile
 *
 * \brief Subclass of NSTableView to provide custom gradient cell highlighting
 *        and interact with its delegate on mouseDown events.
 *
 * \details This class implements the mouseDown: method in order to query its
 *          delegate before processing the event. It uses a gradient to
 *          highlight selected cells by implementing the
 *          highlightSelectionInClipRect: method.
 */
@interface PLAutocompleteTableView : NSTableView

/**
 * \brief Delegate property conforming to the PLAutocompleteTableViewDelegate
 *        protocol.
 *
 * \details This property serves to further specify the NSTableViewDelegate
 *          delegate. The superclass is responsible for retaining it and
 *          synthesizing the accessor methods. Therefore, the subclass only
 *          assigns its value and uses the @dynamic directive in its
 *          implementation.
 *
 * \see PLAutocompleteTableViewDelegate
 */
@property(assign) id <PLAutocompleteTableViewDelegate> delegate;

@end
