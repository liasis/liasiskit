/**
 * \file NSArray+pythonList.m
 * \brief Liasis Python IDE extension of NSArray class implementation file.
 *
 * \details
 * This file contains the function implementation for an extension to the
 * NSArray object, providing the interface for a factory method that creates a
 * NSArray from a Python sequence.
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

#import "NSArray+pythonList.h"

@implementation NSArray (pythonList)

+(NSArray *)arrayByEnumeratingPythonSequence:(PyObject *)pySequence error:(NSError **)error withBlock:(id (^)(PyObject * obj, NSUInteger idx))block
{
        id arrayItem = nil;
        NSMutableArray * output = nil;
        NSString * errorMessage = nil;
        PyObject * pyItem = NULL;
        Py_ssize_t (*sequenceSize)(PyObject *);
        PyObject * (*sequenceGetItem)(PyObject *, Py_ssize_t);
        
        if (PyList_Check(pySequence)) {
                sequenceSize = PyList_Size;
                sequenceGetItem = PyList_GetItem;
        } else if (PyTuple_Check(pySequence)) {
                sequenceSize = PyTuple_Size;
                sequenceGetItem = PyTuple_GetItem;
        } else {
                errorMessage = @"Input argument is not a python sequence.";
                goto exit;
        }
        
        output = [NSMutableArray array];
        for (int i = 0; i < (*sequenceSize)(pySequence); i++) {
                pyItem = (*sequenceGetItem)(pySequence, i);
                if (pyItem == NULL) {
                        errorMessage = [NSString stringWithFormat:@"Could not get item at index %i from sequence", i];
                        goto exit;
                }
                
                arrayItem = block(pyItem, i);
                if (arrayItem == nil) {
                        errorMessage = [NSString stringWithFormat:@"Error processing item at index %i from sequence", i];
                        goto exit;
                }
                [output addObject:arrayItem];
        }

exit:
        if (errorMessage && error) {
                *error = [NSError errorWithDomain:PLLiasisErrorDomain
                                             code:PLErrorCodeLog
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                return nil;
        }
        return [NSArray arrayWithArray:output];
}

@end
