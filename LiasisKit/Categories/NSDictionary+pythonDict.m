/**
 * \file NSDictionary+pythonDict.m
 * \brief Liasis Python IDE extension of NSDictionary class interface file.
 *
 * \details This file contains the function prototypes and interface for an
 *          extension to the NSDictionary object, providing the interface for a
 *          factory method that creates a NSDictionary from a Python dict. Also
 *          includes an implementation for a container object used in converting
 *          the dictionaries.
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

#import "NSDictionary+pythonDict.h"

@implementation PLDictionaryItem

-(void)dealloc
{
        [_key release];
        [_object release];
        [super dealloc];
}

+(instancetype)dictionaryItemWithObject:(id)object forKey:(id)key
{
        PLDictionaryItem * dictionaryItem = [[PLDictionaryItem alloc] init];
        [dictionaryItem setKey:key];
        [dictionaryItem setObject:object];
        return [dictionaryItem autorelease];
}

@end

@implementation NSDictionary (pythonDict)

+(NSDictionary *)dictionaryByEnumeratingPythonDict:(PyObject *)pyDict error:(NSError **)error withBlock:(PLDictionaryItem * (^)(PyObject * key, PyObject * value))block
{
        NSMutableDictionary * dict = nil;
        NSString * errorMessage = nil;
        PLDictionaryItem * dictionaryItem;
        PyObject * pyKeys = NULL;
        PyObject * pyKey = NULL;
        PyObject * pyValue = NULL;
        
        if (PyDict_Check(pyDict) == 0) {
                errorMessage = @"Input argument is not a python dict.";
                goto exit;
        }
        
        pyKeys = PyDict_Keys(pyDict);
        if (pyKeys == NULL) {
                errorMessage = @"Could not get keys from dict.";
                goto exit;
        }
        
        dict = [NSMutableDictionary dictionary];
        for (int i = 0; i < PyList_Size(pyKeys); i++) {
                pyKey = PyList_GetItem(pyKeys, i);
                if (pyKey == NULL) {
                        errorMessage = [NSString stringWithFormat:@"Could not get key at index %i.", i];
                        goto exit;
                }
                
                pyValue = PyDict_GetItem(pyDict, pyKey);
                if (pyValue == NULL) {
                        errorMessage = [NSString stringWithFormat:@"Could not get value at index %i.", i];
                        goto exit;
                }
                
                dictionaryItem = block(pyKey, pyValue);
                if (dictionaryItem == nil) {
                        errorMessage = [NSString stringWithFormat:@"Error processing item at index %i.", i];
                        goto exit;
                }
                [dict setObject:dictionaryItem.object
                         forKey:dictionaryItem.key];
        }
        
exit:
        Py_XDECREF(pyKeys);
        if (errorMessage && error) {
                *error = [NSError errorWithDomain:PLLiasisErrorDomain
                                             code:PLErrorCodeLog
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
                return nil;
        }
        return [NSDictionary dictionaryWithDictionary:dict];
}

@end