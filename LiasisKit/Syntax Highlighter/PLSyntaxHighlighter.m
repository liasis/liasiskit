/**
 * \file PLSyntaxHighlighter.m
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

#import "PLSyntaxHighlighter.h"

#pragma mark Constants

/**
 * \brief The method called in python scripts to get a dictionary of ranges
 *        with which to apply syntax highlighing.
 */
const char * PYTHON_METHOD = "get_coloring_dict";

/**
 * \brief The exception thrown when interfacing with Python scripts.
 */
NSString * PythonException = @"Exception with Python script";

#pragma mark -

@implementation PLSyntaxHighlighter

@synthesize activePythonScript;

-(id)init
{
        self = [super init];
        if (self) {
                importedModules = [[NSMutableDictionary alloc] init];
                activePythonScript = nil;
                isColoringEnabled = YES;
                
                PyObject * pyPath = PySys_GetObject("path");
                NSString * localPath = [[NSBundle bundleForClass:[self class]] resourcePath];
                int err = PyList_Append(pyPath, PyString_FromString([localPath UTF8String]));
                if (err < 0) {
                        NSLog(@"Error in init: could not append local path to Python sys.path");
                        PyErr_Clear();
                        [self release];
                        self = nil;
                        goto exit;
                }
        }

exit:
        return self;
}

-(void)dealloc
{
        [importedModules release];
        [super dealloc];
}

-(BOOL)setActivePythonScript:(NSString *)scriptName error:(NSError **)error
{
        BOOL successful = YES;
        PyObject * module = NULL;
        
        if ([importedModules objectForKey:scriptName] == nil) {
                module = PyImport_ImportModule([scriptName UTF8String]);
                if (module == NULL) {
                        if (error) {
                                *error = [NSError errorWithDomain:PLLiasisKitErrorDomain
                                                             code:PLErrorCodeLog
                                                         userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Disabling coloring: could not import '%@' module", scriptName]}];
                                
                        }
                        isColoringEnabled = NO;
                        successful = NO;
                } else {
                        [importedModules setObject:[NSValue valueWithPointer:module] forKey:scriptName];
                        activePythonScript = scriptName;
                        isColoringEnabled = YES;
                }
        }
        return successful;
}

-(BOOL)colorTextStorage:(PLTextStorage *)textStorage error:(NSError **)error
{
        BOOL successful = YES;
        NSError * matchesError = nil;
        
        /* set text storage font color to the theme's foreground color */
        [textStorage addAttributeWithoutEditing:NSForegroundColorAttributeName
                                          value:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                                             fromGroup:PLThemeManagerSettings]
                                          range:NSMakeRange(0, [textStorage length])];
        
        /* check if there is an active Python script to use */
        if (activePythonScript == nil) {
                if (error) {
                        *error = [NSError errorWithDomain:PLLiasisKitErrorDomain
                                                     code:PLErrorCodeStatusBar
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Disabling coloring: no syntax coloring python script loaded."}];
                }
                isColoringEnabled = NO;
                successful = NO;
                goto exit;
        }

        /* color all ranges */
        NSDictionary * matches = [self rangesFromPythonScript:activePythonScript
                                                   withSource:[[textStorage string] UTF8String]
                                                        error:&matchesError];
        if (matches == nil) {
                if (error) {
                        *error = [NSError errorWithDomain:PLLiasisKitErrorDomain
                                                     code:PLErrorCodeStatusBar
                                                 userInfo:@{NSLocalizedDescriptionKey: @"Disabling coloring: error calling the python script."}];
                }
                isColoringEnabled = NO;
                successful = NO;
                goto exit;
        }
        for (NSString * group in matches) {
                NSArray * groupMatches = [matches objectForKey:group];
                for (NSValue * range in groupMatches) {
                        [textStorage addAttributeWithoutEditing:NSForegroundColorAttributeName
                                                          value:[[PLThemeManager defaultThemeManager] getThemeProperty:PLThemeManagerForeground
                                                                                                             fromGroup:group]
                                                          range:[range rangeValue]];
                }
        }
        
exit:
        return successful;
}

/**
 * \brief Get the ranges in which to apply syntax coloring by running a Python
 *        script.
 *
 * \details This function calls the get_coloring_dict() function in a Python
 *          module, passing in a single input argument: a C string of the text
 *          source that will be colored.
 *
 * \param scriptName The name of the file to import without an extension.
 *
 * \param source The source code to apply syntax coloring.
 *
 * \param error On input, a pointer to a pointer for an error object. If an
 *              error occurs while getting the match ranges, this parameter
 *              contains an error object on output unless it was NULL on input.
 *
 * \return An NSDictionary where keys are NSString objects of the groups to
 *         color (e.g. String or Number) that map to an NSArray of NSRange
 *         structs specifying the range to color. Returns nil if an error
 *         occurred.
 */
-(NSDictionary *)rangesFromPythonScript:(NSString *)scriptName withSource:(const char *)source error:(NSError **)error
{
        NSDictionary * matches = nil;
        NSString * errorMessage = @"Disabling coloring: error getting coloring ranges from source.";
        NSError * matchError = nil;
        PyObject * pyOutput = NULL;
        
        __block NSArray * groupMatches = nil;
        __block NSArray * rangeArray = nil;
        __block NSError * groupMatchError = nil;
        __block NSError * rangeError = nil;
        __block NSString * matchErrorMessage = nil;
        __block NSString * groupMatchErrorMessage = nil;
        __block NSString * rangeErrorMessage = nil;
        
        pyOutput = PyObject_CallMethod([[importedModules objectForKey:scriptName] pointerValue], (char *)PYTHON_METHOD, "s", source);
        if (pyOutput == NULL) {
                if (error) {
                        *error = [NSError errorWithDomain:PLLiasisKitErrorDomain
                                                     code:PLErrorCodeLog
                                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"Could not call '%s' function in '%@' module.", PYTHON_METHOD, scriptName]}];
                }
                goto exit;
        }
        
        matches = [NSDictionary dictionaryByEnumeratingPythonDict:pyOutput error:&matchError withBlock:^PLDictionaryItem *(PyObject *key, PyObject *value) {
                NSString * groupKey = nil;
                char * groupString = NULL;
                
                groupString = PyString_AsString(key);
                if (groupString == NULL) {
                        PyErr_Clear();
                        matchErrorMessage = @"Could not get group string from dict key.";
                        return nil;
                }
                groupKey = [NSString stringWithUTF8String:groupString];
                
                groupMatches = [NSArray arrayByEnumeratingPythonSequence:value error:&groupMatchError withBlock:^id(PyObject * obj, NSUInteger idx) {
                        rangeArray = [NSArray arrayByEnumeratingPythonSequence:obj error:&rangeError withBlock:^id(PyObject * pyRangeValue, NSUInteger idx) {
                                long rangeValue = PyLong_AsLong(pyRangeValue);
                                if (PyErr_Occurred()) {
                                        PyErr_Clear();
                                        rangeErrorMessage = @"Could not get long from range array.";
                                        return nil;
                                }
                                return [NSNumber numberWithLong:rangeValue];
                        }];
                        
                        if (rangeArray == nil) {
                                groupMatchErrorMessage = @"Error converting range for group match.";
                                return nil;
                        }
                        return [NSValue valueWithRange:NSMakeRange([[rangeArray objectAtIndex:0] longValue],
                                                                   [[rangeArray objectAtIndex:1] longValue])];
                }];
                
                if (groupMatches == nil)
                        return nil;
                return [PLDictionaryItem dictionaryItemWithObject:groupMatches forKey:groupKey];
        }];
        
        if (matches == nil && error) {
                if (rangeErrorMessage)
                        [[groupMatchError userInfo] setValue:rangeErrorMessage forKey:NSLocalizedFailureReasonErrorKey];
                if (rangeArray == nil)
                        [[groupMatchError userInfo] setValue:rangeError forKey:NSUnderlyingErrorKey];
                if (groupMatchErrorMessage)
                        [[matchError userInfo] setValue:groupMatchErrorMessage forKey:NSLocalizedFailureReasonErrorKey];
                if (groupMatches == nil)
                        [[matchError userInfo] setValue:groupMatchError forKey:NSUnderlyingErrorKey];
                if (matchErrorMessage)
                        [[*error userInfo] setValue:matchErrorMessage forKey:NSLocalizedFailureReasonErrorKey];
                *error = [NSError errorWithDomain:PLLiasisKitErrorDomain
                                             code:PLErrorCodeLog
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                    NSUnderlyingErrorKey: matchError}];
                goto exit;
        }
        
exit:
        Py_XDECREF(pyOutput);
        return matches;
}

@end
