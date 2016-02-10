//
//  UtilityClass.h
//  bidBrokers
//
//  Created by Ankit on 09/04/15.
//  Copyright (c) 2015 Pooja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



#define bEmailAlert = ""


@class mailConformViewController;

@interface UtilityClass : NSObject <UITextFieldDelegate>

// set RGB Value

+ (UIColor *) colorWithHexString:(float)r andGreen : (float)g andBlue:(float)b;

// Email Address Validation

+(BOOL)Emailvalidate:(NSString *)tempMail;
+(BOOL)removeSpace:(NSString *)str;
+(BOOL)numericValueForTextBox:(NSString *)string;

// this is for Display AlertView with Message
+(void)showAlert:(NSString*)message;
+(BOOL)UrlValidation : (NSString *)strUrl;



// this is method for in category view to set button Border ex. 10k 5k
+(void)myBtnSet:(UIView *)myView;
+(void)setBorderAndPlaceHolder:(UITextField *)txtfld;
+(void)setBorderAndPlaceHolderForBlue:(UITextField *)txtfld;
+(void)setMyCustomAnimation:(UIView *)myView rect:(CGRect)rect;
+(void)setMyViewBorder:(UIView *)myView withBorder:(float)width radius:(float)radius;
+(void)setShedowInView:(UIView *)view;
+(void)setMyRotationhide:(UIView *)myView;
+(void)setMyRotationshow:(UIView *)myView;
+(void)setBtnBackGround:(UIButton *)btn;
+(void)setOtherBtnBackGround:(UIButton *)btn;
+(void)FireSocialSharing:(UIViewController*)view promocode:(NSString*)strPromo username:(NSString*)strUsername;



+(void)removeTextfield:(UIView *)view;



@end
