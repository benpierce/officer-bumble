open class LeaderboardData {
    // High Score
    fileprivate var m_friendsLeaderboardHighscoreNormal : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_globalLeaderboardHighscoreNormal : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_friendsLeaderboardHighscoreHardcore : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_globalLeaderboardHighscoreHardcore : [LeaderboardEntry] = [LeaderboardEntry]()
    
    // Criminals Caught
    fileprivate var m_friendsLeaderboardCriminalsCaughtNormal : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_globalLeaderboardCriminalsCaughtNormal : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_friendsLeaderboardCriminalsCaughtHardcore : [LeaderboardEntry] = [LeaderboardEntry]()
    fileprivate var m_globalLeaderboardCriminalsCaughtHardcore : [LeaderboardEntry] = [LeaderboardEntry]()
    
    open func GetLeaderboard(_ friendsOnly: Bool, hardcore: Bool, highscore: Bool) -> [LeaderboardEntry]? {
        if( friendsOnly && highscore && !hardcore ) {
            return m_friendsLeaderboardHighscoreNormal
        }
    
        if(!friendsOnly && highscore && !hardcore) {
            return m_globalLeaderboardHighscoreNormal
        }
    
        if(friendsOnly && highscore && hardcore) {
            return m_friendsLeaderboardHighscoreHardcore
        }
    
        if(!friendsOnly && highscore && hardcore) {
            return m_globalLeaderboardHighscoreHardcore
        }
    
        if(friendsOnly && !highscore && !hardcore) {
            return m_friendsLeaderboardCriminalsCaughtNormal
        }
    
        if(!friendsOnly && !highscore && !hardcore) {
            return m_globalLeaderboardCriminalsCaughtNormal
        }
    
        if(friendsOnly && !highscore && hardcore) {
            return m_friendsLeaderboardCriminalsCaughtHardcore
        }
    
        if(!friendsOnly && !highscore && hardcore) {
            return m_globalLeaderboardCriminalsCaughtHardcore
        }
    
        return nil
    }
    
    // leaderboard groups split by {
    // leaderboard entries split by }
    // leaderboard values are split by |
    public init(_payLoad: String, _fbId: String) {
        let parts = _payLoad.components(separatedBy: "{")
        var leaderboardId: Int = 0;
        var entry : LeaderboardEntry;
        
        for _leaderboard in parts {
 
            let leaderboardEntries = _leaderboard.components(separatedBy: "}")
            for _entry in leaderboardEntries {
				entry = LeaderboardEntry(_serialized: _entry, _fbId: _fbId);
				
                    switch(leaderboardId) {
                    case 0:
                        m_friendsLeaderboardHighscoreNormal.append(entry)
                    case 1:
                        m_globalLeaderboardHighscoreNormal.append(entry)
                    case 2:
                        m_friendsLeaderboardHighscoreHardcore.append(entry)
                    case 3:
                        m_globalLeaderboardHighscoreHardcore.append(entry)
                    case 4:
                        m_friendsLeaderboardCriminalsCaughtNormal.append(entry)
                    case 5:
                        m_globalLeaderboardCriminalsCaughtNormal.append(entry)
                    case 6:
                        m_friendsLeaderboardCriminalsCaughtHardcore.append(entry)
                    case 7:
                        m_globalLeaderboardCriminalsCaughtHardcore.append(entry)
                    default:
                        break
                    }

            }
    
            leaderboardId = leaderboardId + 1
        }
    }
    
    // Represents a single leaderboard entry.
    open class LeaderboardEntry {
        fileprivate var m_fbId = ""
        fileprivate var m_rank = ""
        fileprivate var m_firstName = ""
        fileprivate var m_lastName = ""
        fileprivate var m_profilePic = ""
        fileprivate var m_highScore = ""
        fileprivate var m_criminalsCaught = ""
        fileprivate var m_isYou = false
        
        public init(_serialized: String, _fbId: String) {
            
            if(_serialized.characters.count > 0 && _serialized != "\n") {
                if ( String.occurances(_serialized, toFind: "|") > 0 ) {        // So that if we get redirected to Starbucks, no crash.
                    var parts = _serialized.components(separatedBy: "|")
                    m_rank = parts[0]
                    m_fbId = parts[1]
                    m_firstName = parts[2]
                    m_lastName = parts[3]
                    m_profilePic = parts[4]
                    m_highScore = parts[5]
                    m_criminalsCaught = parts[6]
        
                    if(m_fbId == _fbId) {
                        m_isYou = true
                    }
                }
            }
        }
        
        open func IsYou() -> Bool {
            return m_isYou
        }
        
        open func GetRank() -> String {
            return m_rank
        }
        
        open func GetFbId() -> String {
            return m_fbId
        }
        
        open func GetName() -> String {
            return m_firstName //+ " " + m_lastName
        }
        
        open func GetProfilePic() -> String {
            return m_profilePic
        }
        
        open func GetHighScore() -> String {
            return m_highScore
        }
        
        open func GetCriminalsCaught() -> String {
            return m_criminalsCaught
        }
    }   // End of inner class.
    
}
