/**
 * \file PLAddOnExtension.h
 * \brief Liasis Python IDE addon protocol file.
 *
 * \details This protocol file is a placeholder for the methods that must be
 *          implemented by addon extensions.
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
#import "PLTabSubviewController.h"
#import "PLThemeManager.h"

/**
 * \protocol PLAddOnExtension
 *
 * \brief Protocol used by view extensions.
 *
 * \details This protocol effectively inherits from both the PLAddOn and 
 *          PLTabSubviewController, and therefore can be contained within the
 *          tab view.
 */
@protocol PLAddOnExtension <PLAddOn, PLTabSubviewController>

@end
