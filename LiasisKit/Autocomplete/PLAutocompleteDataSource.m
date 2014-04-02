/**
 * \file PLAutocompleteDataSource.m
 * \brief Liasis Python IDE autocomplete table view data source implementation
 *        file.
 *
 * \details This is the autocomplete table view's data source object, conforming
 *          to the NSTableViewDataSource protocol. It provides the list of
 *          possible autocomplete words.
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

#import "PLAutocompleteDataSource.h"

@implementation PLAutocompleteDataSource

/**
 * \brief Return the number of rows in the table view.
 *
 * \details Return the number of items in the completions array.
 *
 * \param tableView The table view that sent the message.
 *
 * \return The number of items in the completion array.
 */
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
        return [_completions count];
}

/**
 * \brief Return the object in the table view for a given column/row.
 *
 * \details The autocomplete table view only has a single column, so this method
 *          simply accesses the element in completions at the row index. Return
 *          nil if the row is outside the number of completions.
 *
 * \param tableView The table view being sent this message.
 *
 * \param tableColumn The column in the table view. Disregarded in this
 *                    implementation.
 *
 * \param row The row in the table view.
 *
 * \return The object in the completions array at the row index.
 */
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
        if (row >= [_completions count] || row < 0)
                return nil;
        return [_completions objectAtIndex:row];
}

@end
