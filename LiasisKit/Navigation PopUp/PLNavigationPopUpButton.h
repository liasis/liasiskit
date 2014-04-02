/**
 * \file PLNavigationPopUpButton.h
 * \brief Liasis Python IDE navigation NSPopUpButton subclass and protocols for
 *        its delegate and data source.
 *
 * \details This file contains the interface for a navigation popup button and
 *          the protocols for its delegate and data source. The navigation popup
 *          button is a NSPopUpButton subclass that primarily relates ranges in
 *          source code to titles, providing functionality for the user to
 *          navigate the source.
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
 */

#import <Cocoa/Cocoa.h>

@protocol PLNavigationDataSource;
@protocol PLNavigationDelegate;

/**
 * \class PLNavigationPopUpButton \headerfile \headerfile
 *
 * \brief A NSPopUpButton subclass that provides functionality for the user to
 *        navigate through the text. Additionally, it implements a delegate and
 *        data source system for the NSPopUpButton, similar to that of the
 *        NSTableView.
 *
 * \details This subclass relates ranges to menu items. The most common use case
 *          is to navigate source code, in which ranges are function definitions
 *          or other navigatable blocks. It does so by modifying the
 *          NSPopUpButton in two primary ways:
 *            1) Invalid menu item selections display a message in the button's
 *               cell. Therefore, the subclass provides four new methods that
 *               should be used for selections:
 *                 \see selectNavigationItemAtIndex:
 *                 \see selectNavigationItemWithLineNumber:
 *                 \see selectNavigationItem:
 *                 \see selectNavigationItemWithTitle:
 *               The most common method is to select an item using a line
 *               number, in which the subclass will find the menu item that
 *               contains the range and select it. The subclass then provides
 *               the reverse functionality: associating a menu item with a
 *               location that may be used to jump to a location.
 *
 *               Important: all other methods for selecting items are
 *               unsupported and will break this functionality.
 *
 *            2) Uses a delegate/data source paradigm. The delegate allows for a
 *               more convenient response to menu item clicks. The data source
 *               is used to provide the navigation ranges and the associated
 *               titles and (optionally) images. All items in the menu are
 *               lazily reloaded before displaying the menu.
 *
 *          Important note: It is not supported to add or remove from the menu
 *          directly. This class is designed to use the data source as the only
 *          means for setting its content. All other methods are unsupported and
 *          will likely disrupt the proper popup button title.
 *
 * \see PLNavigationDataSource
 * \see PLNavigationDelegate
 */
@interface PLNavigationPopUpButton : NSPopUpButton
{
        /**
        * \brief Menu item used for the popup button cell to notify the user of
        *        no navigation items.
        */
        NSMenuItem * noNavigationMenuItem;

        /**
         * \brief Menu item used for the popup button cell to notify the user
         *        that the no navigation item is selected.
         */
        NSMenuItem * noSelectionMenuItem;
}

/**
 * \brief The navigation popup button delegate.
 */
@property(nonatomic, assign) id <PLNavigationDelegate> delegate;

/**
 * \brief The navigation popup button data source.
 */
@property(nonatomic, assign) id <PLNavigationDataSource> dataSource;

/**
 * \brief Select an item by its index.
 *
 * \details This method provides a common filter for all selections. Do nothing
 *          if there are no menu items (in this case, a message is
 *          already displayed in the popup notifying the user that there are no
 *          navigation items). Otherwise, reenable the button if neccessary and
 *          do one of the following:
 *              1) Select the No Selection item if the new index is outside of
 *                 the item array bounds.
 *              2) Otherwise, select the item at the index.
 */
-(void)selectNavigationItemAtIndex:(NSInteger)index;

/**
 * \brief Select an item by its line number.
 *
 * \details Finds the item whose range has the greatest starting location and
 *          contains the line number. Selects the item by its index using the
 *          selectedNavigationItemAtIndex: method.
 *
 * \see selectNavigationItemAtIndex:
 */
-(void)selectNavigationItemWithLineNumber:(NSUInteger)lineNumber;

/**
 * \brief Select an item.
 *
 * \details Calls the selectNavigationItemAtIndex with the item's index in the
 *          popup button item array.
 *
 * \see selectNavigationItemAtIndex:
 */
-(void)selectNavigationItem:(NSMenuItem *)item;

/**
 * \brief Select an item by its title.
 *
 * \details Calls the selectNavigationItemAtIndex with the index of the item
 *          with this title.
 *
 * \see selectNavigationItemAtIndex:
 */
-(void)selectNavigationItemWithTitle:(NSString *)title;

/**
 * \brief Reload the data source and repopulate the popup menu.
 *
 * \details Retrieve the navigation ragnes from the dataSource. If there are no
 *          ranges, display a static message in the popup button indicating so.
 *          Otherwise, clear all menu items and create new menu items in
 *          ascending order of the range locations. The dataSource provides the
 *          title for each menu item and, if it implements the method, an image
 *          as well. Items are nested by counting the number of previous items
 *          whose range contains the item's location. Finally, select the item
 *          originally selected before this method call by its title.
 */
-(void)reloadData;

@end


/**
 * \protocol PLNavigationDelegate \headerfile \headerfile
 *
 * \brief Optional protocol for a navigation popup button delegate.
 *
 * \details This protocol simplifies the target/action behavior, relaying menu
 *          item clicks to the delegate if it implements the optional method.
 */
@protocol PLNavigationDelegate <NSObject>

@optional

/**
 * \brief Called when a user clicks on a menu item.
 *
 * \details This is a convenience method for the navigation popup button's
 *          delegate to inform it of a user action on a particular menu item.
 *          The delegate is called after the popup button receives an action
 *          message from the menu item.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \param range The navigation range for the clicked menu item.
 */
-(void)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton didClickMenuItemWithRange:(NSRange)range;

@end


/**
 * \protocol PLNavigationDataSource \headerfile \headerfile
 *
 * \brief Protocol for a navigation popup button data source.
 *
 * \details This protocol adds two required methods and one optional method. A
 *          navigation data source must implement a method providing the array
 *          of navigation ranges and a method returning the title for each
 *          range. The optional method allows the data source to provide an
 *          image for the range.
 */
@protocol PLNavigationDataSource <NSObject>

/**
 * \brief Method to return an array of navigation ranges.
 *
 * \details Navigation ranges define the range of a navigation item. For
 *          example, in source code, a navigation item could be function or
 *          class definitions in some language. This is a required method for
 *          the data source to implement in order for the navigation popup to
 *          define the items in its menu and provide convenience methods
 *          operating with these ranges.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \return An array of NSValue objects encapsulating navigation ranges.
 */
-(NSArray *)rangesForNavigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton;

/**
 * \brief Method to return the title of a navigation range.
 *
 * \details This is a required method for the data source to implement in order
 *          for the navigation popup to associate a title with the range. These
 *          titles will appear in the popup menu. While ranges must be unique in
 *          a given navigation popup button, multiple items may have the same
 *          title.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \param range The navigation range.
 *
 * \return A string representing the title of the navigation range.
 */
-(NSString *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton titleForRange:(NSRange)range;

@optional

/**
 * \brief Method to return the image of a navigation range.
 *
 * \details This is an optional method for the data source to implement in order
 *          for the navigation popup to associate an image with the range. These
 *          images will appear in the popup menu next to the associated title.
 *
 * \param navigationPopUpButton The navigation popup button sending the message.
 *
 * \param range The navigation range.
 *
 * \return An image for the navigation range.
 */
-(NSImage *)navigationPopUpButton:(PLNavigationPopUpButton *)navigationPopUpButton imageForRange:(NSRange)range;

@end
