//
//  UtilityClass.m
//  bidBrokers
//
//  Created by Ankit on 09/04/15.
//  Copyright (c) 2015 Pooja. All rights reserved.
//

#import "UtilityClass.h"
#import "MBProgressHUD.h"


@implementation UtilityClass

+ (UIColor *) colorWithHexString:(float)r andGreen : (float)g andBlue:(float)b
{
    return [UIColor colorWithRed:((float) r / 255.0f)
                       green:((float) g / 255.0f)
                        blue:((float) b / 255.0f)
                       alpha:1.0f];
}

+(BOOL)Emailvalidate:(NSString *)tempMail;
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:tempMail];
}

// this is implemented For remove space in String

+(BOOL)removeSpace:(NSString *)str {

    if ([str isEqualToString:@" "]) {
        return NO;
    } else {
        
        return YES;
    }
}


+(BOOL)numericValueForTextBox:(NSString *)string
{
    NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
    
    BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
    return stringIsValid;
}


+(void)showAlert:(NSString*)message
{
    [[[UIAlertView alloc]initWithTitle:@"BidBroker" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]show];
}


// set button color and border color

+(void)myBtnSet:(UIView *)myView
{
    for (UIButton *btn in myView.subviews) {
        
        if ([btn isKindOfClass:[UIButton class]])
        {
            [btn setBackgroundColor:[UIColor clearColor]];
            //btn.layer.borderColor = [[self colorWithHexString:89 andGreen:167 andBlue:242]CGColor];
            btn.layer.borderColor = [[UIColor blackColor]CGColor];
            btn.layer.borderWidth = 1;
            btn.clipsToBounds = YES;
        }
    }
}
// Place Holder and change border color
//gray

+(void)setBorderAndPlaceHolder:(UITextField *)txtfld
{
    txtfld.borderStyle = UITextBorderStyleLine;
    txtfld.layer.borderWidth = 2;
    txtfld.layer.cornerRadius = 5;
    [txtfld setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    txtfld.layer.borderColor = [[UIColor whiteColor]CGColor];
    txtfld.layer.masksToBounds = YES;

}

// Place Holder and change border color
//Blue

+(void)setBorderAndPlaceHolderForBlue:(UITextField *)txtfld
{
   // txtfld.layer.borderColor = [[self colorWithHexString:89 andGreen:167 andBlue:242]CGColor];
   // txtfld.layer.borderWidth = 0;

   txtfld.borderStyle = UITextBorderStyleNone;
   txtfld.layer.cornerRadius = 0;
   [txtfld setValue:[self colorWithHexString:166 andGreen:163 andBlue:164]
          forKeyPath:@"_placeholderLabel.textColor"];
}

+(void)setMyCustomAnimation:(UIView *)myView rect:(CGRect)rect
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    myView.frame = rect;
    [UIView commitAnimations];
}

+(void)setMyViewBorder:(UIView *)myView withBorder:(float)width radius:(float)radius
{
    myView.layer.borderColor = [[self colorWithHexString:89 andGreen:167 andBlue:242]CGColor];
    myView.layer.borderWidth = width;
    myView.layer.cornerRadius = radius;
    myView.clipsToBounds = YES;
}

+(void)setShedowInView:(UIView *)myView
{
    myView.layer.masksToBounds = NO;
    myView.layer.shadowOffset = CGSizeMake(5, 10);
    myView.layer.shadowRadius = 5;
    myView.layer.shadowOpacity = 0.5;
}

+(void)setMyRotationhide:(UIView *)myView
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         myView.transform =
                         CGAffineTransformScale(myView.transform, 0.01, 0.01);
                     }
                     completion:^(BOOL finished) {
                         myView.hidden = YES;
                     }];
}

+(void)setMyRotationshow:(UIView *)myView
{
    myView.hidden = NO;
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         myView.transform = CGAffineTransformIdentity;
                         
                     }
                     completion:^(BOOL finished) {
                       // myView.hidden = YES;
                     }];
}

//87 160 238

+(void)setBtnBackGround:(UIButton *)btn
{
    [btn setBackgroundColor:[UIColor colorWithRed:87.0/255.0 green:160.0/255.0 blue:238.0/255.0 alpha:1]];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
+(void)setOtherBtnBackGround:(UIButton *)btn
{
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTitleColor:[UIColor colorWithRed:87.0/255.0 green:160.0/255.0 blue:238.0/255.0 alpha:1] forState:UIControlStateNormal];
}




+(void)removeTextfield:(UIView *)view {
    for (UITextField *txt in view.superview.subviews) {
        if ([txt isKindOfClass:[UITextField class]]) {
            [txt resignFirstResponder];
        }
    }
}

+(BOOL)UrlValidation : (NSString *)strUrl
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    BOOL isValidURL = [urlPredic evaluateWithObject:strUrl];
    if (isValidURL)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
+(void)FireSocialSharing:(UIViewController*)view promocode:(NSString*)strPromo username:(NSString*)strUsername
{
    NSString *appName = @"BidBroker";
    NSString *Promo = [NSString stringWithFormat:@"%@ is share his promocode %@",strUsername,strPromo];
    NSArray *itemsToShare = @[appName, Promo];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
    [view presentViewController:activityVC animated:YES completion:nil];

}

@end
