//
//  LeaderboardServices.swift
//  OfficerBumble
//
//  Created by Ben Pierce on 2015-02-15.
//  Copyright (c) 2015 Benjamin Pierce. All rights reserved.
//

import Foundation

open class LeaderboardServices {
    /*
    open let POST_SCORES_URL = "http://www.110lbhulk.com/postscore.php"
    open let GET_SCORES_URL = "http://www.110lbhulk.com/getleaderboard.php"
    
    open func PostScore() -> Bool {
        var result = false
        var pref = GameSharedPreferences()
        
        var fbId = pref.ReadString(pref.FBID_PREFERENCE)
        var fbPic = pref.ReadString(pref.PROFILE_PIC_PREFERENCE)
        var firstName = pref.ReadString(pref.FIRST_NAME_PREFERENCE)
        var lastName = pref.ReadString(pref.LAST_NAME_PREFERENCE)
        var highscoreNormal = pref.ReadInteger(pref.HIGH_SCORE_PREFERENCE)
        var highscoreHardcore = pref.ReadInteger(pref.HIGH_SCORE_HARDCORE_PREFERENCE)
        var caughtNormal = pref.ReadInteger(pref.CRIMINALS_CAUGHT_PREFERENCE)
        var caughtHardcore = pref.ReadInteger(pref.CRIMINALS_CAUGHT_HARDCORE_PREFERENCE)
    
        if( fbId != "" ) {
            var sb = "scores=\(fbId)|\(CleanseData(fbPic))|\(CleanseData(firstName))|\(CleanseData(lastName))|\(highscoreNormal)|\(highscoreHardcore)|\(caughtNormal)|\(caughtHardcore)"
    
            var url = URL(string: POST_SCORES_URL)
            var request = NSMutableURLRequest(url: url!)
            request.httpMethod = "POST"
            
            let data: Data = (sb as NSString).data(using: String.Encoding.utf8.rawValue)!
            request.httpBody = data
            
            var response: URLResponse?
            var error: NSError?
            
            let reply = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
            
            if ( reply != nil ) {
                let decodedReply = NSString(data:reply!, encoding:String.Encoding.utf8)
            
                if (error != nil || decodedReply! != "\nSuccess" )
                {
                    //println("Error posting \(data) to leaderboard with response \(decodedReply!) and error \(error)!")
                } else {
                    if ( decodedReply! == "\nSuccess" ) {
                        result = true
                        //println("Successful Post of \(sb)!")
                    }
                }
            } // End reply != nil check.
        } else {
            result = true	// Can't save if we don't have a FacebookId.
        }
    
        return result;
    }
    
    fileprivate func CleanseData(_ data: String) -> String {
        var result = data.replacingOccurrences(of: "}", with: "", options: NSString.CompareOptions.literal, range: nil)
        result = data.replacingOccurrences(of: "|", with: "", options: NSString.CompareOptions.literal, range: nil)
        result = data.replacingOccurrences(of: "{", with: "", options: NSString.CompareOptions.literal, range: nil)
        
        return result
    }
    
    // Saves all leaderboard related values locally. Increments the number of criminals caught by one if this is being called from a "win" scenario.
    open func SaveLocally(_ gameStateManager: GameStateManager, criminalsCaught: Int, criminalsCaughtHardcore: Int) {
        let gm = GameSharedPreferences()
        let highScore = gm.ReadInteger(gm.HIGH_SCORE_PREFERENCE)
        gm.WriteString(gm.CRIMINALS_CAUGHT_PREFERENCE, value: String(criminalsCaught))
        
        if ( gameStateManager.GetScore() > highScore ) {
            gm.WriteString(gm.HIGH_SCORE_PREFERENCE, value: String(gameStateManager.GetScore()))
        }

        if ( gameStateManager.GetDifficulty().DifficultyName == "Hardcore" ) {
            let highScoreHardcore = gm.ReadInteger(gm.HIGH_SCORE_HARDCORE_PREFERENCE)
            gm.WriteString(gm.CRIMINALS_CAUGHT_HARDCORE_PREFERENCE, value: String(criminalsCaughtHardcore))
            
            if ( gameStateManager.GetScore() > highScoreHardcore ) {
                gm.WriteString(gm.HIGH_SCORE_HARDCORE_PREFERENCE, value: String(gameStateManager.GetScore()))
            }
        }
    }
    
    // _friendIds will be pipe separated.
    open func GetLeaderboardData(_ fbId: String, friendIds: String) -> LeaderboardData? {
        var result: LeaderboardData? = nil
    
        let url = URL(string: GET_SCORES_URL)
        let cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        var request = NSMutableURLRequest(url: url!, cachePolicy: cachePolicy, timeoutInterval: 2.0)
        request.httpMethod = "POST"
    
        // set Content-Type in HTTP header
        let boundaryConstant = "----------V2ymHFg03esomerandomstuffhbqgZCaKO6jy";
        let contentType = "multipart/form-data; boundary=" + boundaryConstant
        URLProtocol.setProperty(contentType, forKey: "Content-Type", in: request)
    
        // set data
        var dataString = "fbid=\(fbId)&friends=\(friendIds)"
        //println("DataString is \(GET_SCORES_URL)\(dataString)")
        let requestBodyData = (dataString as NSString).data(using: String.Encoding.utf8.rawValue)
        request.httpBody = requestBodyData
    
        var response: URLResponse? = nil
        var error: NSError? = nil
        let reply = NSURLConnection.sendSynchronousRequest(request, returningResponse:&response, error:&error)
    
        if ( reply == nil ) {
            //println("Failed to retrieve the leaderboard - probably no Internet Connection")
        } else {
            let results = NSString(data:reply!, encoding:String.Encoding.utf8)
    
            if ( error != nil || results! == "Failure" ) {
                //println("Failed to retrieve the leaderboard \(error)")
            } else {
                result = LeaderboardData(_payLoad: results!, _fbId: fbId)
            }
        }
    
        return result
    }
    */
}
