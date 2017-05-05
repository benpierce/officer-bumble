import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

let FB = Facebook();

open class Facebook {
    
    var fbSession:FBSession?;
    var friends: String = "";
    var friendsSet: Bool = false;
    
    init(){
        self.fbSession = FBSession.active();
    }
    
    // Facebook Login
    // Once the button is clicked, show the login dialog
    @objc func login(_ success: @escaping () -> Void) {
        ClearFB()   // Clear Facebook Login Cached Data
        
        let loginManager = LoginManager()
        loginManager.logIn([ .PublicProfile ], viewController: self) { loginResult in
            switch loginResult {
            case .Failed(let error):
                print(error)
            case .Cancelled:
                print("User cancelled login.")
            case .Success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                success()
            }
        }
    }
    
    @objc func logout() {
        ClearFB()
        
        let loginManager = LoginManager()
        loginManager.logOut() {
            logoutResult in
            switch logoutResult {
            case .Failed(let error):
                print(error)
            case .Cancelled:
                print("Logout Cancelled")
            case .Success():
                print("Logged out!")
        }
    }
    
    // Clear Facebook Session Cache
    // Clear Facebook values.
    func ClearFB() -> Void {
        let gm = GameSharedPreferences()
        
        gm.WriteString(gm.FBID_PREFERENCE, value: "");
        gm.WriteString(gm.PROFILE_PIC_PREFERENCE, value: "");
        gm.WriteString(gm.FIRST_NAME_PREFERENCE, value: "");
        gm.WriteString(gm.LAST_NAME_PREFERENCE, value: "");
        friends = "";
        friendsSet = false;
    }
}

    /*
    func hasActiveSession() -> Bool{
        let fbsessionState = FBSession.active().state;
        
        // If we have State Created Token Loaded, that means we have the token cached, so establishing a connection should be
        // no problem.
        if ( fbsessionState == FBSessionState.createdTokenLoaded ) {
            OpenFBSession(false, success: { })
        }
        
        if ( fbsessionState == FBSessionState.open || fbsessionState == FBSessionState.openTokenExtended || fbsessionState == FBSessionState.createdTokenLoaded) {
            self.fbSession = FBSession.active();
            return true;
        }
        
        return false;
    }
    
    func login(_ success: @escaping () -> Void) {
        
        ClearFB()
        
        let activeSession = FBSession.active();
        let fbsessionState = activeSession?.state;
        var showLoginUI = true;
        
        if(fbsessionState == FBSessionState.createdTokenLoaded){
            showLoginUI = false;
        }
        
        if(fbsessionState != FBSessionState.open
            && fbsessionState != FBSessionState.openTokenExtended){
            
            OpenFBSession(showLoginUI, success: success)
            
            return;
        }
    }
    
    fileprivate func OpenFBSession(_ showLoginUI: Bool, success: @escaping () -> Void) {
        let permission = ["public_profile", "user_friends", "publish_actions"];
        
        FBSession.openActiveSession(
            withReadPermissions: permission,
            allowLoginUI: showLoginUI,
            completionWithItemsHandler
            
            completionHandler: { (session:FBSession!, state:FBSessionState!, error:NSError!) in
                
                if(error != nil){
                    print("Session Error: \(error)");
                }
                self.SaveFacebookProfileId()
                
                success()
                self.fbSession = session;
        }
        );
    }
    
    func logout(){
        self.fbSession?.closeAndClearTokenInformation();
        self.fbSession?.close();
        ClearFB()
    }
    
    func SaveFacebookProfileId(){
        FBRequest.forMe()?.start(completionHandler: {(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) in
            
            if(error != nil){
                print("Error Getting ME: \(error)");
            } else {
                let lastName : AnyObject = result.value(forKey: "last_name")!
                let firstName : AnyObject = result.value(forKey: "first_name")!
                let userFBID : AnyObject = result.value(forKey: "id")!
                let userImageURL = "https://graph.facebook.com/\(userFBID)/picture?type=small"
                
                let gm = GameSharedPreferences()
                
                gm.WriteString(gm.FBID_PREFERENCE, value: String(userFBID as NSString));
                gm.WriteString(gm.PROFILE_PIC_PREFERENCE, value: userImageURL);
                gm.WriteString(gm.FIRST_NAME_PREFERENCE, value: String(firstName as NSString));
                gm.WriteString(gm.LAST_NAME_PREFERENCE, value: String(lastName as NSString));
            }
        });
    }
    
    func SetFacebookFriends() {
        if ( !friendsSet ) {
            FBRequest.forMyFriends()?.start(completionHandler: {(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) in
                
                if(error != nil){
                    print("Error Getting ME: \(error)");
                } else {
                    var resultdict = result as NSDictionary
                    var data : NSArray = resultdict.objectForKey("data") as NSArray
                    
                    self.friends = "";
                    for i in 0 ..< data.count {
                        let valueDict : NSDictionary = data[i] as NSDictionary
                        let id = valueDict.objectForKey("id") as String
                        
                        if ( self.friends == "" ) {
                            self.friends = id
                        } else {
                            self.friends = self.friends + "|" + id
                        }
                    }
                    
                    self.friendsSet = true
                }
            });
        }
    }
    
    func GetFacebookFriends() -> String {
        return friends;
    }
    
    func handleDidBecomeActive(){
        FBAppCall.handleDidBecomeActive();
    }
    
    func shareBadge(_ badge: BadgeManager.Badge, success: @escaping () -> Void, failure: @escaping (_ message: String) -> Void) {
        let params : NSMutableDictionary = [
            "name" : "Officer Bumble",
            "caption" : "Congratulations \(badge.badgeName) Bumble!",
            "description" : "I've captured my \(badge.criminalsCaught)\(Int.GetNumericSuffix(badge.criminalsCaught)) career McBurgler Brother and am now a proud \(badge.badgeName)",
            "link" : "http://www.officerbumble.com",
            "picture" : "http://www.110lbhulk.com/fbimg.png"]
        
        share(params, success: success, failure: failure)
    }
    
    func share(_ params: NSMutableDictionary, success: @escaping () -> Void, failure: @escaping (_ message: String) -> Void) {
        var url : FBLinkShareParams = FBLinkShareParams()
        url.link = URL(string: "http://www.officerbumble.com")
        
        FBWebDialogs.presentFeedDialogModallyWithSession(nil, parameters: params, handler: { (result : FBWebDialogResult, url : URL!, error : NSError!) -> Void in
            if error != nil{
                failure(message: "Error publishing story : \(error.description)")
            } else{
                if result == FBWebDialogResult.DialogNotCompleted{
                    print("User cancelled.")
                }else{
                    
                    var urlParams : NSDictionary = self.parseURLParams(url.query)
                    if urlParams.valueForKey("post_id") == nil{
                        print("User cancelled")
                    } else{
                        var key : NSString = urlParams.objectForKey("post_id") as NSString
                        var result : NSString = NSString(string: "Posted id:\(key)")
                        self.SaveFacebookProfileId()
                        success()
                    }
                }
            }
        })
        
    }
    
    func invite(_ success: @escaping () -> Void, failure: @escaping (_ message: String) -> Void) {
        var url : FBLinkShareParams = FBLinkShareParams()
        url.link = URL(string: "http://www.officerbumble.com")
        
        FBWebDialogs.presentRequestsDialogModally(with: nil, message: "Play Officer Bumble!", title: "Officer Bumble", parameters: nil,
                                                  handler: { (result : FBWebDialogResult, url : URL!, error : NSError!) -> Void in
                                                    if error != nil{
                                                        failure(message: "Error publishing story : \(error.description)")
                                                    } else{
                                                        if result == FBWebDialogResult.dialogNotCompleted {
                                                            print("User cancelled, dialog not complete.")
                                                            success()
                                                        } else {
                                                            if(url.description.hasPrefix("fbconnect://success?request="))
                                                            {
                                                                // Facebook returns FBWebDialogResultDialogCompleted even user
                                                                // presses "Cancel" button, so we differentiate it on the basis of
                                                                // url value, since it returns "Request" when we ACTUALLY
                                                                // completes Dialog
                                                                self.SaveFacebookProfileId()
                                                                success()
                                                                print("invite success")
                                                            }
                                                            else
                                                            {
                                                                success()
                                                                // User Cancelled the dialog
                                                                print("invite cancelled")
                                                            }
                                                        }
                                                    }
        })
    }
    
    
    func parseURLParams(_ query : NSString?) -> NSDictionary {
        var params : NSMutableDictionary = NSMutableDictionary()
        if query != nil{
            
            var pairs : NSArray = query!.components(separatedBy: "&")
            
            var kv : NSArray = NSArray()
            for pair in pairs{
                kv = (pair as AnyObject).components(separatedBy: "=")
                var val : NSString =    (kv[1] as AnyObject).replacingPercentEscapes(using: String.Encoding.utf8)!
                params = ["\(kv[0])" : "\(val)"]
                return params
            }
        }
        params = ["post_id" : "nil"]
        return params
    }
    */

