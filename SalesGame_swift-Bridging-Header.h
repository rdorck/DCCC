//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <Parse/PFObject+Subclass.h>
#import "UtilityClass.h"
#import "MBProgressHUD.h"
#import "IQKeyboardManager.h"
#import "checkDevice.h"
#import "SWRevealViewController.h"


#define IS_IPHONE_5 [[UIScreen mainScreen]bounds].size.height == 568?TRUE:FALSE
#define IS_IPHONE_4S [[UIScreen mainScreen]bounds].size.height == 480?TRUE:FALSE
#define IS_IPHONE_6 [[UIScreen mainScreen]bounds].size.height == 667?TRUE:FALSE
#define IS_IPHONE_6_PLUS [[UIScreen mainScreen]bounds].size.height == 736?TRUE:FALSE