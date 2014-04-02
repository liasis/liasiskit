/**
 * \file PLAddOnManagerViewController.h
 * \brief Liasis Python IDE add on manager view controller.
 *
 * \details Specifies the view controller interface for the view that serves as
 *          the front-end for the add on manager.
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

#import <Cocoa/Cocoa.h>
#import <LiasisKit/LiasisKit.h>

/**
 * \class PLAddOnManagerViewController \headerfile \headerfile
 * \brief An NSViewController subclass that is designed to control a view that
 *        is a front end for loading and managing add ons.
 *
 * \details This class is a front end gui for the PLAddOnManager class. This 
 *          controller and its corresponding view are important for the Liasis 
 *          IDE, as most of the functionality of the IDE will be supplied by 
 *          add-ons in the form of view extensions and, in the forseable future,
 *          functional plug-ins. The view controlled by this class will eventuall
 *          be a view within the preference window of the app.
 */
@interface PLAddOnManagerViewController : NSViewController <NSTableViewDataSource> {
        /**
         * \brief An NSTableView instance that is used to list and load add ons.
         *
         * \details An NSTableView instance that will display the loaded, loaded
         *        but not PLAddOn compiant, and unloaded add ons. The table view
         *        uses an instance of this class as a data source.
         */
        IBOutlet NSTableView * addOnTableView;
}

/**
 * \brief Factory method for generating a functional instance of the 
 *        PLAddOnManagerViewController.
 *
 * \details This factory method allocates and initializes a new PLAddOnManagerViewController
 *          instance with the appropriate nib name in the defaukt main bundle.
 *
 * \return An PLAddOnManagerViewController instance loaded with its nib file.
 *         The returned object is autoreleased, consistent with fatcory method
 *         coding conventions.
 *         
 */
+(id)addOnViewController;

#pragma mark Table View Data Source Protocol Methods

/**
 * \brief A necessary table view data source method, used to determine the number
 *        of rows in the table.
 *
 * \details This method is used to determine the number of add ons in the plugins
 *          folder enclosed within the application bundle, and make this number
 *          available to the NSTableView used to show the available add ons, and
 *          loading them into memory.
 *
 * \param table An NSTableView object that will display the data.
 *
 * \return An NSUInteger number representing the number of add ons that are 
 *         available to the IDE.
 *
 */
-(NSUInteger)numberOfRowsInTableView:(NSTableView *)table;

/**
 * \brief A necessary table view data source method, used to determine the object 
 *        that is used by a cell in the table view.
 *
 * \details This method is used to determine the data represented in every row and
 *          column of the table view. The table columns are checked, and dependending
 *          on the column identifier different objects must be returned. The
 *          table columns are identified using their identifier method, which 
 *          should return one of the following strings:
 *            1) LoadStatus.
 *            2) AddOnImage.
 *            3) AddOnName.
 *            4) LoadButton.
 *          It may be nice to include the organization name for the developing
 *          party.
 *
 * \param tableView The NSTableView that will display the data.
 *
 * \param tableColumn The NSTableColumn object that is used to identify the 
 *                    data that is being requested.
 *
 * \param row An NSUInteger valued indicating the row for which data is being 
 *            requested. Each row is linked to a specific add on.
 *
 * \return An instance of an object that is used by the table view to display its
 *         data. If the table view column identifier is LoadStatus, returns 
 *         an NSImage with the semaphore indicating if a add on is unloaded,
 *         loaded or loaded but does not comply with the PLAddOn protocol. If
 *         the table column is AddOnImage, returns an instance of an NSImage
 *         with the bundle icon. If no bundle icon is found, it returns a default
 *         NSImage. If the table column identifier is AddOnName, returns the last
 *         path component of the add on. If the table column identifier is
 *         LoadButton, an NSNumber object is returned with a BOOl value, 0 for
 *         an unloaded bundle, 1 for a loaded bundle.
 *
 */
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

/**
 * \brief A necessary table view data source method, used to change the stored 
 *        object value that corresponds to a cell in the table view.
 *
 * \details This method is used to change the data represented in every row and
 *          column of the table view. The table columns are checked, and dependending
 *          on the column identifier different actions are taken. The
 *          table columns are identified using their identifier method (please
 *          see tableView: objectValueForTableColumn: row: for details)
 *          In the case of changing the value of the data in the table view,
 *          no action is taken unless the table column identifier is LoadButton
 *          and the anObject parameter is an NSNumber with a BOOL value of YES.
 *          In this case, the PLAddOnManagerViewController tells the default
 *          PLAddOnManager to load the add on corresponding to the specified row.
 *         
 *
 * \param tableView The NSTableView that will display the data.
 *
 * \param anObject An object with a new value that is to be set.
 *
 * \param tableColumn The NSTableColumn object that is used to identify the
 *                    data that is being requested.
 *
 * \param row An NSUInteger valued indicating the row for which data is being
 *            requested. Each row is linked to a specific add on.
 *
 */
-(void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end
