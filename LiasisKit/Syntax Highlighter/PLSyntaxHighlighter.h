/**
 * \file PLSyntaxHighlighter.h
 * \brief Liasis Python IDE syntax coloring manager.
 *
 * \details
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
#import <Python/Python.h>
#import "PLTextStorage.h"
#import "PLThemeManager.h"
#import "NSDictionary+pythonDict.h"
#import "NSArray+pythonList.h"

/**
 * \class PLSyntaxHighlighter \headerfile \headerfile
 * \brief Provide syntax coloring for the Liasis Text Editor view
 *        extension. 
 *
 * \details This class applies syntax coloring to a NSTextStorage object.
 *          It parses for all properties in a Python document (i.e. builtin
 *          keywords, strings, and numbers). These tokens are then colored
 *          as defined by its PLThemeManager.
 */
@interface PLSyntaxHighlighter : NSObject {        
        /**
         * \brief Store a pointer to all imported Python modules used for
         *        syntax coloring.
         */
        NSMutableDictionary * importedModules;
        
        /**
         * \brief Flag denoting if coloring is enabled.
         *
         * \details Coloring is disabled if there were errors appending to the
         *          Python sys.path, loading a Python module, or calling
         *          functions in the Python module. Coloring is enabled again
         *          after successfully loading a new Python module.
         */
        BOOL isColoringEnabled;
}

@property (retain, readonly) NSString * activePythonScript;

/**
 * \brief Initialize the syntax highlighter.
 *
 * \details Add the path to this class bundle to the internal Python interpreter
 *          path in order to import Python scripts for syntax coloring. Return
 *          nil if there was an error interfacing with Python.
 */
-(id)init;

/**
 * \brief Apply syntax coloring to a text storage object.
 *
 * \details First replace all text with the default font color. Then apply
 *          syntax coloring to the groups returned from the Python script
 *          responsible for parsing the text.
 *
 *          All syntax coloring is done using the
 *          addAttributeWithoutEditing: method of the PLTextStorage object. The
 *          NSTextView calling this method is then responsible for redrawing
 *          its view (at least the visible rect) for the syntax coloring to be
 *          drawn.
 *
 *          If an error occurs, coloring is disabled until using
 *          setActivePythonScript:error: with a new script.
 *
 * \param textStorage The text storage object in which to apply syntax coloring.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while getting the match ranges, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return A boolean flag indicating whether coloring succeeded.
 *
 * \see PLTextStorage
 */
-(BOOL)colorTextStorage:(NSTextStorage *)textStorage error:(NSError **)error;

/**
 * \brief Set the active Python script used for syntax coloring.
 *
 * \details The active Python script is imported once and stored internally. The
 *          script must implement one function: get_coloring_dict(text). This
 *          method must take a string as its only argument and return a dict,
 *          mapping the group names to color with a list of tuples, where
 *          each tuple contains (start position, length of range), specifying
 *          the range to apply the corresponding syntax coloring for that group.
 *          This function is called upon every edit, so it should be fast
 *          relative to user input.
 *
 *          If the script has already been loaded, this method does nothing and
 *          returns YES. On error, disable syntax coloring until this method is
 *          called again and is successful.
 *
 * \param scriptName The name of the script to import and use for syntax
 *                   coloring. Do not include the extension, just the
 *                   name of the script as if it were imported in Python.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while importing the script, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return A boolean flag indicating whether or not setting the script was
 *         was successful.
 */
-(BOOL)setActivePythonScript:(NSString *)scriptName error:(NSError **)error;

@end
