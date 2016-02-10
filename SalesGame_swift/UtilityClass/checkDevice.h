//
//  checkDevice.h
//  animalSpell
//
//  Created by smg on 30/09/14.
//  Copyright (c) 2014 smg. All rights reserved.
//

#ifndef animalSpell_checkDevice_h
#define animalSpell_checkDevice_h


#define AppDel ((AppDelegate *)[[UIApplication sharedApplication]delegate])

#endif

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )

#define IS_IPHONE_5 [[UIScreen mainScreen]bounds].size.height == 568?TRUE:FALSE
#define IS_IPHONE_6_plus [[UIScreen mainScreen]bounds].size.height == 736? TRUE: FALSE

#define IS_IOS6_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0 && [[UIDevice currentDevice].systemVersion floatValue] < 7.0)
#define IS_IOS7_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))


#define IS_IPAD ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?40:0)

