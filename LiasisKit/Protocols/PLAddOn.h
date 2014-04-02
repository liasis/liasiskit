/**
 * \file PLAddOn.h
 * \brief Liasis Python IDE addon protocol file.
 *
 * \details This protocol file specifies all the methods that must be
 *          implemented by addons in addition to definitions for the addon type.
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

/**
 * \brief A new data type that holds the add on type.
 *
 * \details This data type is used by the add-on manager and other objects to 
 *          determine the type of add-on for any object that conforms to this protocol.
 */
typedef enum {
        PLAddOnExtension,            //!< Value used to indicate that an add-on is a view extension.
        /** 
         * \brief Value used to indicate that an add-on is a wrapper for python
         *         code.
         * \details This type of add-on is intended to wrap code that will directly
         *          manipulate the internal python interpreter. 
         *
         * \note The api for manipulating application behavior through the python 
         *       interpreter has not yet been determined. It may be a good idea 
         *       to store additional application behavior properties within as
         *       python variables to allow for python plug-ins.
         */
        PLAddOnPythonCodeController
} PLAddOnType;

/** \protocol PLAddon \headerfile \headerfile
 * \brief An abstract protocol that should be inherited by all add-on protocols.
 *
 * \details The main function of this protocol is to define a common mechanism
 *          by which the application can determine the type of add-on for any
 *          add-on object.
 */
@protocol PLAddOn <NSObject>

/**
 * \brief Class method that indicates the type of add-on for any instance of the class
 *        that conforms to this protocol.
 *
 * \return A PLAddOnType value indicating the type of add-on for objects conforming
 *         to this protocol.
 *
 * \see PLAddOnType
 */
+(PLAddOnType)type;

@end
