import Foundation

let kDoenloadCategoryImage:String = "http://swiftomatics.in/Quiz/upload/"
let kServerURl:String = "http://swiftomatics.in/Quiz/"
let kQuestionTime:Int = 60
let kFiftyFiftyCount:String = "FiftyFiftyCount"
let kSkipCount:String = "SkipCount"
let kTimerCount:String = "TimerCount"
let kLoggedInUserId:String = "ObjectId"
let kLoggedInUserName:String = "UserName"
var kTimeForWrongTime : NSInteger = 0


//Switch
let kTimer:String =  "kTimer"
let kSound:String =  "kSound"
let kVibrate:String =  "kVibrate"



class GeneralClass: NSObject
{
    class var sharedInstance :GeneralClass
    {
        struct Singleton
        {
            static let instance = GeneralClass()
        }
        return Singleton.instance
    }
    

}
extension String {
    
    func trimCharacter() -> String
    {
        return  self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}

func showHud(myView:UIView)
{

    _ = MBProgressHUD.showHUDAddedTo(myView, animated: true)
    //loadingNotification.labelText = "Loading"
}

func hideHud(myView:UIView)
{
    MBProgressHUD.hideAllHUDsForView(myView, animated: true)
}

let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568 ? true : false as Bool
let IS_IPHONE_4 = UIScreen.mainScreen().bounds.size.height == 480 ? true : false as Bool
let IS_IPHONE_6 = UIScreen.mainScreen().bounds.size.height == 667 ? true : false as Bool
let IS_IPHONE_6_plus = UIScreen.mainScreen().bounds.size.height == 736 ? true : false as Bool

let IS_IOS8_AND_UP  = (UIDevice.currentDevice().systemVersion as NSString).floatValue >= 8.0
let IS_iPad = UIScreen.mainScreen().bounds.size.height == 1024 ? true : false as Bool
