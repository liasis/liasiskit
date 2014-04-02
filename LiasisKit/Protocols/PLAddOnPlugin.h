/**
 * \file PLAddOnPlugin.h
 * \brief Liasis Python IDE addon protocol file.
 *
 * \details This file contains protocols required by plugins.
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

#import <Foundation/Foundation.h>
#import "PLAddOn.h"

/**
 * \protocol PLAddOnExtension
 *
 * \brief Protocol used by plugins.
 *
 * \details This protocol inherits from `PLAddOn` and all plugins with more
 *          specific requirements will inherit from this.
 */
@protocol PLAddOnPlugin <PLAddOn>

@end

@protocol PLAddOnPluginIntrospection <PLAddOnPlugin>

@optional

/**
 * \brief Parse the source code.
 *
 * \details This method may be implemented if parsing the source code is an
 *          expensive operation or can fail. The former allows objects using the
 *          introspection plugin to decouple parsing and reading in order to
 *          read in multiple places, but parse once. The former allows for a
 *          backup of parse data in the case of a failure.
 *
 *          If not implementing this methods, all other methods should parse the
 *          source code when called.
 *
 * \param source The source code string.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while parsing the source code, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return YES if an error occurred.
 */
-(BOOL)parseSource:(NSString *)source error:(NSError **)error;

/**
 * \brief Return the defined variables in the source code, mapped to the index
 *        they were defined using an index in the source to define the scope.
 *
 * \details Use `index` to define the current scope. The returned variables
 *          should be those applicable at `index` in the source code.
 *
 * \param index The index in the source string defining the scope in the source.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while getting the variables, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return A dictionary of variables defined within the scope at the index
 *         mapped to their definition index. Return nil on error.
 */
-(NSDictionary *)variablesWithIndex:(NSUInteger)index error:(NSError **)error;

/**
 * \brief Return an array of ranges for each occurrence of the variable at an
 *        index within the scope defined by the index in the source code.
 *
 * \details Use `index` to determine the variable and its current scope.
 *          The returned variable ranges should be those applicable at `index`
 *          in the source code. This method my be used for highlighting
 *          occurrences of a variable or refactoring instances of it within the
 *          current scope
 *
 * \param index The index in the source string defining the scope in the source.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while getting the variable ranges, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return An array of `NSValue` ranges where the variable is located. Return
 *         nil on error.
 */
-(NSArray *)variableRangesWithIndex:(NSUInteger)index error:(NSError **)error;

/**
 * \brief Get the navigation information about the source code.
 *
 * \details This method retrieves all navigation points in the source code.
 *          These may include, for instance, function, class, and method
 *          definitions. This method is designed to be used with the
 *          `PLNavigationPopUpButton`.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while getting the navigation points, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return A dictionary mapping the range of the navigation item wrapped in an
 *         `NSValue` to a `PLNavigationItem` instance. Return nil on error.
 *
 * \see PLNavigationItem
 *
 * \see PLNavigationPopUpButton
 */
-(NSDictionary *)getNavigationAndReturnError:(NSError **)error;

@end
