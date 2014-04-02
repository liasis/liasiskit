/**
 * \file NSArray+pythonList.h
 * \brief Liasis Python IDE extension of NSArray class interface file.
 *
 * \details
 * This file contains the function prototypes and interface for an extension to
 * the NSArray object, providing the interface for a factory method that creates
 * a NSArray from a Python sequence.
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
 * \extends NSArray
 *
 * \brief An extension to the NSArray object.
 *
 * \details This extension adds one factory method that creates a NSArray from a
 *          Python sequence.
 */
@interface NSArray (pythonList)

/**
 * \brief Factory method to create a NSArray from a Python sequence.
 *
 * \details This method takes a PyObject representing either a list or a tuple
 *          and adds its contents to a NSArray of the same length. To convert
 *          each object in the sequence to an Objective C type, iterate over all
 *          items using a block. The returned item from the block is inserted at
 *          the same index in the returned NSArray as it was found in the Python
 *          sequence. Return nil from the block if there was an error converting
 *          the Python object.
 *
 *          If returning nil from the block or if an internal error occurs, the
 *          method will stop, create an error object, and return nil.
 *
 * \param pySequence A Python list or tuple.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while converting the array or the block returns
 *              nil at any point, this parameter contains an error object on
 *              output unless it was NULL on input.
 *
 * \param block The enumeration block.
 *
 *     \param obj The Python object.
 *
 *     \param idx The index in the list.
 *
 *     \return The converted object in the list or nil if an error occurred.
 *
 * \return An NSArray with objects returned from the block or nil if an error
 *         occurred at any point.
 */
+(NSArray *)arrayByEnumeratingPythonSequence:(PyObject *)pySequence error:(NSError **)error withBlock:(id (^)(PyObject * obj, NSUInteger idx))block;

@end
