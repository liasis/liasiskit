/**
 * \file NSDictionary+pythonDict.h
 * \brief Liasis Python IDE extension of NSDictionary class interface file.
 *
 * \details This file contains the function prototypes and interface for an
 *          extension to the NSDictionary object, providing the interface for a
 *          factory method that creates a NSDictionary from a Python dict. Also
 *          includes an interface for a container object used in converting the
 *          dictionaries.
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
 * along with Liasis. If not, see
 * <http://www.gnu.org/licenses/>.
 *
 * \author Danny Nicklas.
 * \author Jason Lomnitz.
 * \date 2012-2014.
 *
 */

#import <Foundation/Foundation.h>
#import <Python/Python.h>
#import <LiasisKit/LiasisKit.h>

/**
 * \class PLDictionaryItem \headerfile \headerfile
 * \brief Container object for a key/object pair in a dictionary.
 *
 * \details This class is used as a return object for creating an NSDictionary
 *          from a Python dict.
 */
@interface PLDictionaryItem : NSObject

/**
 * \brief The dictionary key.
 */
@property (retain) id key;

/**
 * \brief The dictionary object.
 */
@property (retain) id object;

/**
 * \brief Factory method to create a PLDictionaryItem with an object and key.
 *
 * \return A PLDictionaryItem with an object for a key.
 */
+(instancetype)dictionaryItemWithObject:(id)object forKey:(id)key;

@end


/**
 * \extends NSDictionary
 *
 * \brief An extension to the NSDictionary object.
 *
 * \details This extension adds one factory method that creates a NSDictionary
 *          from a Python dict.
 */
@interface NSDictionary (pythonDict)

/**
 * \brief Factory method to create a NSDictionary from a Python dict.
 *
 * \details This method takes a PyObject representing a dict and converts it to a
 *          NSDictionary. To convert each key and value to Objective C types,
 *          iterate over each key and value using a block. The block will take a
 *          key/value pair and return a PLDictionaryItem. Its key and object
 *          properties will be inserted as a key/value pair in the returned
 *          NSDictionary. Return nil from the block if there was an error
 *          converting the Python object.
 *
 *          If returning nil from the block or if an internal error occurs, the
 *          method will stop, create an error object, and return nil.
 *
 * \param pyDict A Python dict.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while converting the dict or the block returns
 *              nil at any point, this parameter contains an error object on
 *              output unless it was NULL on input.
 *
 * \param block The enumeration block.
 *
 *     \param key The Python object for the key in the dict.
 *
 *     \param value The Python object for the value in the dict.
 *
 *     \return The converted object in the list or nil if an error occurred.
 *
 * \return An NSDictionary with key/value pairs returned from the block or nil
 *         if an error occurred at any point.
 */
+(NSDictionary *)dictionaryByEnumeratingPythonDict:(PyObject *)pyDict error:(NSError **)error withBlock:(PLDictionaryItem * (^)(PyObject * key, PyObject * value))block;

@end
