/*
===============================================================================
LeaderboardScreen

Displays a custom leaderboard for the game. I used a SpriteKit scene rather than
a regular UI view because UI views were not as flexible and did not look that
great.
===============================================================================
*/

import Foundation
import SpriteKit

open class LeaderboardScreen: GameScene {
    
    /*
    // Storing the UI elements like checkbox and option button in tools2.atlas
    fileprivate let textureAtlas1 = SKTextureAtlas(named:"tools2")
    
    fileprivate let ROW_COUNT = 11                          // How many rows are always in the leaderboard?
    fileprivate let BORDER_SIZE_PERCENT = CGFloat(0.02)     // The border size of the leaderboard table (in % of outer box size).
    fileprivate let ROW_HEIGHT_PERCENT = CGFloat(0.15)      // How large should each row be from a percentage of screen height?
    fileprivate let MIN_INNER_BOX_PERCENT = CGFloat(0.60)   // The minimum height of the outer box, even if empty.
    fileprivate let ENTRY_PADDING_PERCENT = CGFloat(0.05)   // Padding between leaderboard entries.
    fileprivate let INNER_BOX_TOP_PADDING_PERCENT = CGFloat(0.10)   // Amount of space between inner box top and first entry.
    fileprivate let INNER_BOX_BOTTOM_PADDING_PERCENT = CGFloat(0.05)   // Amount of space between inner box top and first entry.
    fileprivate let INTERFACE_HEIGHT = CGFloat(0.20)     // % of the height that's reserved for UI.
    fileprivate let SCENE_BOTTOM_PADDING = CGFloat(0.05)  // % of padding between bottom of the outer box and the background.
    fileprivate let TAB_HEIGHT = CGFloat(0.10)            // How tall are the friend and global tab (in %)
    fileprivate let TAB_WIDTH = CGFloat(0.15)             // How wide are the friend and global tab (in %)
    fileprivate let CHECKBOX_WIDTH = CGFloat(0.10)        // Width of checkboxes.
    fileprivate let CHECKBOX_HEIGHT = CGFloat(0.10)       // Height of checkboxes.
    
    fileprivate let FONT_SIZE = CGFloat(15)               // Size of the font.
    fileprivate let COL1_WIDTH = CGFloat(0.20)            // Column widths for all 5 columns.
    fileprivate let COL2_WIDTH = CGFloat(0.20)
    fileprivate let COL3_WIDTH = CGFloat(0.20)
    fileprivate let COL4_WIDTH = CGFloat(0.20)
    fileprivate let COL5_WIDTH = CGFloat(0.20)
    fileprivate let OUTER_WIDTH = CGFloat(0.90)
    
    fileprivate var backgroundBox: SKSpriteNode?
    fileprivate var outerBox: SKSpriteNode?
    fileprivate var innerBox: SKSpriteNode?
    fileprivate var globalTab: ToggleButton?
    fileprivate var friendsTab: ToggleButton?
    fileprivate var hardcore: ToggleButton?
    fileprivate var score: ToggleButton?
    fileprivate var criminalsCaught: ToggleButton?
    
    fileprivate var hardcoreOn = false
    fileprivate var globalOn = true
    fileprivate var sortByScore = true
    fileprivate var connectionWarningPending = false;       // Set to true if you want to show connection warning on next frame.
    
    fileprivate var data: LeaderboardData?
    fileprivate let panRec = UIPanGestureRecognizer()
    fileprivate var backgroundHeight = CGFloat(0)
    fileprivate var maxWorldPositionY = CGFloat(0)
    fileprivate var minWorldPositionY = CGFloat(0)
    fileprivate var fbId = ""
    fileprivate var friendIds = ""
    
    override open func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Initialization of Gesture
        let pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(LeaderboardScreen.detectPan(_:)))
        view.addGestureRecognizer(pan)
        
        // Get the leaderboard data.
        let gm = GameSharedPreferences()
        
        fbId = gm.ReadString(gm.FBID_PREFERENCE)
 
        // Attempt to get your friends list (we do it here because it could have changed since you logged into Facebook).
        friendIds = FB.GetFacebookFriends()
        
        WireButtons()
        
        // Initial UI setup (one time only)
        backgroundHeight = CreateBackgroundBox(data)
        CreateOuterBox(data)
        CreateInnerBox(data)
        CreateHeaderRow()
        CreateTabs()
        CreateHardcoreCheckbox()
        CreateSortByCheckbox()
        CreateLeaderboardRows()
        
        // We need to default the view such that the top of the background box aligns with the top of the screen.
        // World goes down half the background height.
        world!.position.y = world!.position.y - ((backgroundHeight - display.sceneSize.height) / 2)
        maxWorldPositionY = world!.position.y
        minWorldPositionY = world!.position.y + (backgroundHeight - display.sceneSize.height)
        
        SetupScreenAsync()
    }
    
    /*
    ===============================================================================
    SetupScreenAsync
    
    We don't want to tie up the main UI thread, so we're going to post your scores, 
    retrieve leaderboard data, and refresh the leaderboard all through a different
    thread. Prior to implementing this, the leaderboard screen would appear to freeze
    if you were in a low internet area like the subway.
    ===============================================================================
    */
    fileprivate func SetupScreenAsync() {
        let queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        queue.async {
            LeaderboardServices().PostScore()
            
            // Retrieve the data from our OfficerBumble web services.
            self.data = LeaderboardServices().GetLeaderboardData(self.fbId, friendIds: self.friendIds)
            
            if ( self.data != nil ) {
                // This is allowable from a different thread since we've already setup all the sprites - we're just 
                // updating them, not messing with the sprite array.
                self.RefreshLeaderboard(self.data!)
            } else {
                // We can only queue up the connection warning message for the next frame because we're not in the main UI
                // thread, so adding any sprites could get an error about modifying an array while it's being iterated 
                // through on the main UI thread.
                self.connectionWarningPending = true
            }
        }
    }
    
    // So that we can display the connection warning if it's queued up.
    override open func update(_ currentTime: TimeInterval) {
        if ( connectionWarningPending ) {
            connectionWarningPending = false
            DisplayConnectionWarning()
        }
        
        super.update(currentTime)
    }
    
    // Unbind the gestures
    override open func willMove(from view: SKView) {
        if let recognizers = self.view!.gestureRecognizers {
            for recognizer in recognizers {
                self.view!.removeGestureRecognizer(recognizer as UIGestureRecognizer)
            }
        }
    }
    
    /*
    ===============================================================================
    detectPan
    
    Allow smooth scrolling through the leaderboard on any device.
    ===============================================================================
    */
    func detectPan(_ recognizer:UIPanGestureRecognizer) {
        if (recognizer.state == UIGestureRecognizerState.began ) {
            // Do Nothing
        } else if (recognizer.state == UIGestureRecognizerState.changed) {
            var translation = recognizer.translation(in: self.view!)
            translation = CGPoint(x: translation.x, y: translation.y)
            
            // Do panning
            let originalY = world!.position.y
            
            if ( world!.position.y - translation.y < maxWorldPositionY) {
                world!.position.y = maxWorldPositionY   // We're already at the top!
            }
            else if ( world!.position.y - translation.y > minWorldPositionY) {
                world!.position.y = originalY
            } else {
                world!.position.y = world!.position.y - translation.y
            }
            
            recognizer.setTranslation(CGPoint.zero, in: self.view!)
        } else if (recognizer.state == UIGestureRecognizerState.ended ) {
            // Do nothing
        }
    }
    
    /*
    ===============================================================================
    DisplayConnectionWarning
    
    If we don't get any leaderboard data back for any reason, we'll display the
    following message.
    ===============================================================================
    */
    fileprivate func DisplayConnectionWarning() {
        let text = "Unable to retrieve leaderboard data. This device is not connected to the Internet or the leaderboard services are currently down."
        let width = innerBox!.size.width * 0.80
        let topPadding = display.GetNormalizedScreenHeightByPercentage(0.15)
        
        let warningLabel = MultiLineTextLabel(text: text, name: "WarningLabel", parent: innerBox!, width: width, font_width: 20, font_height: 20, top_padding: topPadding, bottom_padding: 0)
        warningLabel.Show()
    }
    
    /*
    ===============================================================================
    CreateBackgroundBox
    
    Creates the entire background which spans the entire screen and offscreen
    area.
    ===============================================================================
    */
    fileprivate func CreateBackgroundBox(_ data: LeaderboardData?) -> CGFloat {
        let outerBoxHeight = GetOuterBoxHeight(data)
        let topPadding = (display.sceneSize.height * INTERFACE_HEIGHT)
        let bottomPadding = (display.sceneSize.height * SCENE_BOTTOM_PADDING)
        
        var backgroundHeight = outerBoxHeight + topPadding + bottomPadding
        if ( backgroundHeight < display.sceneSize.height ) {
            backgroundHeight = display.sceneSize.height
        }
        
        world!.size = CGSize(width: display.sceneSize.width, height: backgroundHeight)
        world!.position = CGPoint(x: 0, y: 0)
        
        var size = display.sceneSize
        backgroundBox = SKSpriteNode()
        backgroundBox!.color = SKColor(red: 0.93725, green: 0.90588, blue: 0.59608, alpha: 1.0)
        backgroundBox!.size = world!.size
        
        world!.addChild(backgroundBox!)
        
        return backgroundHeight
    }
    
    /*
    ===============================================================================
    CreateOuterBox
    
    The outer box is behind the inner box and creates an illusion of a border.
    ===============================================================================
    */
    fileprivate func CreateOuterBox(_ data: LeaderboardData?) {
        let innerBoxHeight = GetInnerBoxHeight(data)
        let outerBoxHeight = GetOuterBoxHeight(data)
        let outerBoxWidth = display.sceneSize.width * OUTER_WIDTH
        let size = CGSize(width: outerBoxWidth, height: outerBoxHeight)
        
        outerBox = SKSpriteNode()
        outerBox!.color = SKColor(red: 0.75294, green: 0.38824, blue: 0.18824, alpha: 1.0)
        outerBox!.size = size
        
        let top = (INTERFACE_HEIGHT * display.sceneSize.height)
        let howMuchLeft = backgroundHeight - outerBoxHeight
        let y = (howMuchLeft / 2) - top
        
        outerBox!.position = CGPoint(x: 0, y: y)
        backgroundBox!.addChild(outerBox!)
    }
    
    fileprivate func GetOuterBoxHeight(_ data: LeaderboardData?) -> CGFloat {
        let innerBoxHeight = GetInnerBoxHeight(data)
        
        let outerBoxHeight = innerBoxHeight + (innerBoxHeight * BORDER_SIZE_PERCENT) + (innerBoxHeight * BORDER_SIZE_PERCENT)
        
        return outerBoxHeight
    }
    
    /*
    ===============================================================================
    CreateInnerBox
    
    The inner box is where all the leaderboard rows live.
    ===============================================================================
    */
    fileprivate func CreateInnerBox(_ data: LeaderboardData?) {
        let innerBoxHeight = GetInnerBoxHeight(data)
        
        // We want to set the inner box width such that the boarder on each side is the same as the border
        // between outer box top and inner box top.
        let heightDifferential = outerBox!.size.height - innerBoxHeight
        let innerBoxWidth = outerBox!.size.width - heightDifferential
        
        // Set the inner box height.
        let size = CGSize(width: innerBoxWidth, height: innerBoxHeight)
        
        innerBox = SKSpriteNode()
        innerBox!.color = SKColor(red: 0.23529, green: 0.24314, blue: 0.10588, alpha: 1.0)
        innerBox!.size = size
        
        innerBox!.position = CGPoint(x: 0, y: 0)
        outerBox!.addChild(innerBox!)
    }
    
    // Determines how large tall the inner box should be.
    fileprivate func GetInnerBoxHeight(_ data: LeaderboardData?) -> CGFloat {
        var rowCount: Int = 0
        var totalHeight: CGFloat = display.GetNormalizedScreenHeightByPercentage(MIN_INNER_BOX_PERCENT)
        
        //if ( data != nil ) {
            
            let rowHeight = display.GetNormalizedScreenHeightByPercentage(ROW_HEIGHT_PERCENT)
            
            // Height of all rows.
            totalHeight = CGFloat(ROW_COUNT) * rowHeight
            
            // Add in padding between rows.
            totalHeight = totalHeight + ((rowHeight * CGFloat(ROW_COUNT - 1)) * ENTRY_PADDING_PERCENT)
            
            // Add in top padding.
            totalHeight = totalHeight + (totalHeight * INNER_BOX_TOP_PADDING_PERCENT)
            
            // Add in bottom padding.
            totalHeight = totalHeight + (totalHeight * INNER_BOX_BOTTOM_PADDING_PERCENT)
        //}
        
        return totalHeight
    }
    
    /*
    ===============================================================================
    CreateHeaderRow
    
    Displays headers so we know what each column represents.
    ===============================================================================
    */
    fileprivate func CreateHeaderRow() {
        //if ( data != nil ) {
        let nameLabel = GetTextLabel("Name", wide: true, name: "hdrName")
        var x = -(innerBox!.size.width / 2) + (innerBox!.size.width * 0.30)
        var y = (innerBox!.size.height / 2) - nameLabel.frame.size.height
        nameLabel.position = CGPoint(x: x, y: y)
        innerBox!.addChild(nameLabel)
        
        let rankLabel = GetTextLabel("Rank", wide: true, name: "hdrRank")
        x = -(innerBox!.size.width / 2) + (innerBox!.size.width * 0.50)
        rankLabel.position = CGPoint(x: x, y: y)
        innerBox!.addChild(rankLabel)
        
        let scoreLabel = GetTextLabel("Score", wide: true, name: "hdrScore")
        x = -(innerBox!.size.width / 2) + (innerBox!.size.width * 0.68)
        scoreLabel.position = CGPoint(x: x, y: y)
        innerBox!.addChild(scoreLabel)
        
        let criminalsCaughtLabel = GetTextLabel("Crim. Caught", wide: true, name: "hdrCrimCaught")
        x = -(innerBox!.size.width / 2) + (innerBox!.size.width * 0.90)
        criminalsCaughtLabel.position = CGPoint(x: x, y: y - display.GetNormalizedScreenHeightByPercentage(0.005))
        innerBox!.addChild(criminalsCaughtLabel)
        //}
    }
    
    /*
    ===============================================================================
    CreateTabs
    
    Creates the global tab and the freind tab.
    ===============================================================================
    */
    fileprivate func CreateTabs() {
        CreateGlobalTab()
        CreateFriendsTab()
        SelectGlobalTab()
    }
    
    /*
    ===============================================================================
    CreateLeaderboardRows
    
    Creates all of the leaderboard rows and sets their initial value to blank. We
    do this when the screen loads because removing and re-adding the leaderboard rows
    whenever it refreshed was taking way too long.
    ===============================================================================
    */
    fileprivate func CreateLeaderboardRows() {
        let row: Int = 1
        
        if ( row <= ROW_COUNT ) {
            for i in row ... ROW_COUNT {
                CreateLeaderboardRow(i, rank: "", profilePicURL: "", name: "", highscore: "", criminalsCaught: "", isYou: false)
            }
        }
    }
    
    /*
    ===============================================================================
    RefershLeaderboard
    
    Refreshes leaderboard data by updating the existing labels. If we don't have data
    for all the rows, we simply fill the rest in with blank.
    ===============================================================================
    */
    fileprivate func RefreshLeaderboard(_ data: LeaderboardData?) {
        var row: Int = 1
        
        if ( data != nil ) {
            let entries = data!.GetLeaderboard(!globalOn, hardcore: hardcoreOn, highscore: sortByScore)
            
            for entry: LeaderboardData.LeaderboardEntry in entries! {
                
                UpdateLeaderboardRow(row, rank: entry.GetRank(), profilePicURL: entry.GetProfilePic(), name: entry.GetName(), highscore: entry.GetHighScore(), criminalsCaught: entry.GetCriminalsCaught(), isYou: entry.IsYou())
                
                row = row + 1
            }
        }
        
        // Any remaining rows are set to blank.
        if ( row <= ROW_COUNT ) {
            for i in row ... ROW_COUNT {
                UpdateLeaderboardRow(i, rank: "", profilePicURL: "", name: "", highscore: "", criminalsCaught: "", isYou: false)
            }
        }
    }
    
    /*
    ===============================================================================
    CreateLeaderboardRow
    
    Creates a leaderboard row by attaching an image, setting the font color, and 
    setting up the labels.
    ===============================================================================
    */
    fileprivate func CreateLeaderboardRow(_ row: Int, rank: String, profilePicURL: String, name: String, highscore: String, criminalsCaught: String, isYou: Bool) {
        let cols = CreateAndFetchRow(row)
        
        AttachExternalImage(cols.col1, imageURL: profilePicURL)
        
        var color = SKColor.white
        if ( isYou ) {
            color = SKColor.green
        }
        
        cols.col2.addChild(GetTextLabel("\(name)", wide: true, color: color, name: "lblName\(row)"))
        cols.col3.addChild(GetTextLabel("\(rank)", wide: true, color: color, name: "lblRank\(row)"))
        cols.col4.addChild(GetTextLabel("\(highscore)", wide: true, color: color, name: "lblHS\(row)"))
        cols.col5.addChild(GetTextLabel("\(criminalsCaught)", wide: true, color: color, name: "lblCC\(row)"))
    }
    
    /*
    ===============================================================================
    UpdateLeaderboardRow
    
    Updates a single leaderboard row - much faster than removing and re-adding everything.
    ===============================================================================
    */
    fileprivate func UpdateLeaderboardRow(_ row: Int, rank: String, profilePicURL: String, name: String, highscore: String, criminalsCaught: String, isYou: Bool) {
        
        var color = SKColor.white
        if ( isYou ) {
            color = SKColor.green
        }
        
        // Update Leaderboard to Col.
        let imgNode = self.childNode(withName: "//FBPic_\(row)") as! SKSpriteNode?
        if ( imgNode != nil ) {
            imgNode!.removeAllChildren()
            AttachExternalImage(imgNode!, imageURL: profilePicURL)
        }
        
        // Update First Name
        let lblName = self.childNode(withName: "//lblName\(row)") as! SKLabelNode?
        if ( lblName != nil ) {
            lblName!.fontColor = color
            lblName!.text = name
        }
        
        // Update Rank
        let lblRank = self.childNode(withName: "//lblRank\(row)") as! SKLabelNode?
        if ( lblRank != nil ) {
            lblRank!.fontColor = color
            lblRank!.text = rank
        }
        
        // Update High Score
        let lblHS = self.childNode(withName: "//lblHS\(row)") as! SKLabelNode?
        if ( lblHS != nil ) {
            lblHS!.fontColor = color
            lblHS!.text = highscore
        }
        
        // Upate Criinals Caught
        let lblCC = self.childNode(withName: "//lblCC\(row)") as! SKLabelNode?
        if ( lblCC != nil ) {
            lblCC!.fontColor = color
            lblCC!.text = criminalsCaught
        }
        
    }
    
    fileprivate func WireButtons() {
        // Training Button.
        super.WireButton("btnback", pressBlock: TransitionToTitle)
    }
    
    fileprivate func SelectGlobalTab() {
        friendsTab!.ToggleOn()
        globalTab!.ToggleOff()
        globalOn = true
        if ( data != nil ) {
            RefreshLeaderboard(data)
        }
    }
    
    fileprivate func SelectFriendsTab() {
        globalOn = false
        globalTab!.ToggleOn()
        friendsTab!.ToggleOff()
        if ( data != nil ) {
            RefreshLeaderboard(data)
        }
    }
    
    fileprivate func HardcorePressed() {
        hardcoreOn = !hardcoreOn
        if ( data != nil ) {
            RefreshLeaderboard(data)
        }
    }
    
    fileprivate func SortByScore() {
        sortByScore = true
        score!.ToggleOn()
        criminalsCaught!.ToggleOn()
        if ( data != nil ) {
            RefreshLeaderboard(data)
        }
    }
    
    fileprivate func SortByCriminalsCaught() {
        sortByScore = false
        score!.ToggleOff()
        criminalsCaught!.ToggleOff()
        if ( data != nil ) {
            RefreshLeaderboard(data)
        }
    }
    
    fileprivate func CreateSortByCheckbox() {
        // Sort By
        let label = SKLabelNode()
        label.fontColor = SKColor.black
        label.text = "Sort By:"
        label.fontName = "MarkerFelt"
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.fontSize = FONT_SIZE
        label.zPosition = ZPOSITION.background_FLOOR.rawValue
        let labelX = hardcore!.position.x + (label.frame.width / 6)
        let labelY = hardcore!.position.y - (hardcore!.size.height / 2) - (label.frame.size.height / 2) - (display.GetNormalizedScreenHeightByPercentage(0.02))
        label.position = CGPoint(x: labelX, y: labelY)
        backgroundBox!.addChild(label)
        
        // Score
        score = ToggleButton(texture: textureAtlas1.textureNamed("option2"), texturePressed: textureAtlas1.textureNamed("option1"))
        score!.Initialize("btnscore", inputManager: inputManager, pressBlock: SortByScore)
        score!.name = "btnscore"
        let size = display.GetSizeByPercentageOfScene(CHECKBOX_WIDTH, heightPercent: CHECKBOX_HEIGHT, considerAspectRatio: true)
        score!.size = size
        score!.zPosition = ZPOSITION.background.rawValue
        let x = label.position.x + (label.frame.size.width / 2) + (score!.size.width / 2)
        let y = labelY
        score!.position = CGPoint(x: x, y: y)
        backgroundBox!.addChild(score!)
        
        // Score Label
        let scoreLabel = SKLabelNode()
        scoreLabel.fontColor = SKColor.black
        scoreLabel.text = "Score "
        scoreLabel.fontName = "MarkerFelt"
        scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        scoreLabel.fontSize = FONT_SIZE
        scoreLabel.zPosition = ZPOSITION.background_FLOOR.rawValue
        let scoreLabelX = score!.position.x + (score!.size.width / 2) + (scoreLabel.frame.size.width / 2)
        let scoreLabelY = labelY
        scoreLabel.position = CGPoint(x: scoreLabelX, y: scoreLabelY)
        backgroundBox!.addChild(scoreLabel)
        
        // Criminals Caught Button
        criminalsCaught = ToggleButton(texture: textureAtlas1.textureNamed("option1"), texturePressed: textureAtlas1.textureNamed("option2"))
        criminalsCaught!.Initialize("btncriminalscaught", inputManager: inputManager, pressBlock: SortByCriminalsCaught)
        criminalsCaught!.name = "btncriminalscaught"
        criminalsCaught!.size = size
        criminalsCaught!.zPosition = ZPOSITION.background.rawValue
        let criminalsCaughtX = scoreLabel.position.x + (scoreLabel.frame.size.width / 2) + (criminalsCaught!.size.width / 2) + display.GetNormalizedScreenWidthByPercentage(0.01)
        criminalsCaught!.position = CGPoint(x: criminalsCaughtX, y: y)
        backgroundBox!.addChild(criminalsCaught!)
        
        // Criminals Caught Label
        let criminalsCaughtLabel = SKLabelNode()
        criminalsCaughtLabel.fontColor = SKColor.black
        criminalsCaughtLabel.text = "Criminals Caught"
        criminalsCaughtLabel.fontName = "MarkerFelt"
        criminalsCaughtLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        criminalsCaughtLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        criminalsCaughtLabel.fontSize = FONT_SIZE
        criminalsCaughtLabel.zPosition = ZPOSITION.background_FLOOR.rawValue
        let criminalsCaughtLabelX = criminalsCaught!.position.x + (criminalsCaught!.size.width / 2) + (criminalsCaughtLabel.frame.size.width / 2)
        let criminalsCaughtLabelY = scoreLabelY - display.GetNormalizedScreenHeightByPercentage(0.005)
        criminalsCaughtLabel.position = CGPoint(x: criminalsCaughtLabelX, y: criminalsCaughtLabelY)
        backgroundBox!.addChild(criminalsCaughtLabel)
    }
    
    fileprivate func CreateHardcoreCheckbox() {
        hardcore = ToggleButton(texture: textureAtlas1.textureNamed("checkbox1"), texturePressed: textureAtlas1.textureNamed("checkbox2"))
        hardcore!.name = "btnhardcore"
        hardcore!.Initialize("btnhardcore", inputManager: inputManager, pressBlock: HardcorePressed)
        let size = display.GetSizeByPercentageOfScene(CHECKBOX_WIDTH, heightPercent: CHECKBOX_HEIGHT, considerAspectRatio: true)
        hardcore!.size = size
        hardcore!.zPosition = ZPOSITION.background.rawValue
        let x = friendsTab!.position.x + (friendsTab!.size.width / 2) + (hardcore!.size.width)
        let y = friendsTab!.position.y + (friendsTab!.size.height / 2) + (hardcore!.size.height / 2)
        hardcore!.position = CGPoint(x: x, y: y)
        backgroundBox!.addChild(hardcore!)
        
        let label = SKLabelNode()
        label.fontColor = SKColor.black
        label.text = "Hardcore Only"
        label.fontName = "MarkerFelt"
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.fontSize = FONT_SIZE
        label.zPosition = ZPOSITION.background_FLOOR.rawValue
        let labelX = hardcore!.position.x + (hardcore!.size.width / 2) + (label.frame.size.width / 2) + display.GetNormalizedScreenWidthByPercentage(0.01)
        let labelY = y - display.GetNormalizedScreenHeightByPercentage(0.005)
        label.position = CGPoint(x: labelX, y: labelY)
        backgroundBox!.addChild(label)
        
        super.WireButton("btnhardcore", pressBlock: HardcorePressed)
    }
    
    fileprivate func CreateGlobalTab() {
        let tab = ToggleButton(texture: textureAtlas1.textureNamed("btnglobal1"), texturePressed: textureAtlas1.textureNamed("btnglobal2"))
        
        tab.name = "btnglobal"
        tab.size = CGSize(width: display.sceneSize.width * TAB_WIDTH, height: display.sceneSize.height * TAB_HEIGHT)
        tab.zPosition = ZPOSITION.background.rawValue
        tab.color = SKColor(red: 0.75294, green: 0.38824, blue: 0.18824, alpha: 1.0)
        let x = -(outerBox!.size.width / 2) + (tab.size.width / 2) + (display.sceneSize.width * 0.05)
        let y = outerBox!.position.y + (outerBox!.size.height / 2) + (tab.size.height / 2)
        tab.position = CGPoint(x: x, y: y)
        backgroundBox!.addChild(tab)
        globalTab = tab
        
        super.WireButton("btnglobal", pressBlock: SelectGlobalTab)
    }
    
    fileprivate func CreateFriendsTab() {
        let tab = ToggleButton(texture: textureAtlas1.textureNamed("btnfriends1"), texturePressed: textureAtlas1.textureNamed("btnfriends2"))

        tab.name = "btnfriends"
        tab.size = CGSize(width: display.sceneSize.width * TAB_WIDTH, height: display.sceneSize.height * TAB_HEIGHT)
        tab.zPosition = ZPOSITION.background.rawValue
        tab.color = SKColor(red: 0.49, green: 0.506, blue: 0.259, alpha: 1.0)
        let x = globalTab!.position.x + (globalTab!.size.width / 2) + (display.sceneSize.width * 0.005) + (tab.size.width / 2)
        let y = outerBox!.position.y + (outerBox!.size.height / 2) + (tab.size.height / 2)
        tab.position = CGPoint(x: x, y: y)
        backgroundBox!.addChild(tab)
        friendsTab = tab
        
        super.WireButton("btnfriends", pressBlock: SelectFriendsTab)
    }
    
    fileprivate func AttachExternalImage(_ node: SKSpriteNode, imageURL: String) {
        if ( imageURL != "" ) {
            let imageData = try? Data(contentsOf: URL(string: imageURL)!)
            if ( imageData != nil ) {
                let theImage = UIImage(data: imageData!)
        
                var imageSizePercent = ROW_HEIGHT_PERCENT - 0.02
                var imageNode: SKSpriteNode = SKSpriteNode(texture: SKTexture(image: theImage!))
                imageNode.size = display.GetSizeByPercentageOfScene(imageSizePercent, heightPercent: imageSizePercent, considerAspectRatio: true)
        
                node.addChild(imageNode)
            }
        }
    }
    
    fileprivate func GetTextLabel(_ text: String, wide: Bool, name: String) -> SKLabelNode {
        let color = SKColor.white
        return GetTextLabel(text, wide: wide, color: color, name: name)
    }
    
    fileprivate func GetTextLabel(_ text: String, wide: Bool, color: SKColor, name: String) -> SKLabelNode {
        let label = SKLabelNode()
        label.text = text
        if ( wide ) {
            label.fontName = "MarkerFelt-Wide"
        } else {
            label.fontName = "MarkerFelt"
        }
        
        label.fontColor = color
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
        label.fontSize = FONT_SIZE
        label.zPosition = ZPOSITION.background_FLOOR.rawValue
        label.name = name
        
        return label
    }
    
    fileprivate func CreateAndFetchRow(_ rowNumber: Int) -> (col1: SKSpriteNode, col2: SKSpriteNode, col3: SKSpriteNode, col4: SKSpriteNode, col5: SKSpriteNode) {
        
        let rowHeight = display.GetNormalizedScreenHeightByPercentage(ROW_HEIGHT_PERCENT)
        let rowWidth = innerBox!.size.width * 0.95
        
        let rowNode = SKSpriteNode()
        rowNode.size.width = rowWidth
        rowNode.size.height = rowHeight
        
        if ( rowNumber % 2 == 0 ) {
            rowNode.color = SKColor(red: 0.71373, green: 0.55294, blue: 0.19216, alpha: 1)
        } else {
            rowNode.color = SKColor(red: 0.70980, green: 0.41961, blue: 0.18039, alpha: 1)
        }
        
        var y = (innerBox!.size.height / 2) - (innerBox!.size.height * INNER_BOX_TOP_PADDING_PERCENT) + (rowHeight / 2)
        y = y - (rowHeight * CGFloat(rowNumber - 1))
        y = y - ((rowHeight * CGFloat(rowNumber - 1)) * ENTRY_PADDING_PERCENT)
        y = y - (rowHeight / 2)
        
        rowNode.position = CGPoint(x: 0, y: y)
        rowNode.name = "Row_\(rowNumber)"
        innerBox!.addChild(rowNode)
        
        let col1 = SKSpriteNode()
        col1.size.width = rowWidth * COL1_WIDTH
        col1.size.height = rowHeight
        col1.position = display.GetParentAnchor(col1, parent: rowNode, anchorTo: Display.ANCHOR.CENTER_LEFT)
        col1.name = "FBPic_\(rowNumber)"
        rowNode.addChild(col1)
        
        let col2 = SKSpriteNode()
        col2.size.width = rowWidth * COL2_WIDTH
        col2.size.height = rowHeight
        col2.position = display.GetSiblingAnchor(col2, sibling: col1, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        col2.name = "Name_\(rowNumber)"
        rowNode.addChild(col2)
        
        let col3 = SKSpriteNode()
        col3.size.width = rowWidth * COL3_WIDTH
        col3.size.height = rowHeight
        col3.position = display.GetSiblingAnchor(col3, sibling: col2, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        col3.name = "Rank_\(rowNumber)"
        rowNode.addChild(col3)
        
        let col4 = SKSpriteNode()
        col4.size.width = rowWidth * COL4_WIDTH
        col4.size.height = rowHeight
        col4.position = display.GetSiblingAnchor(col4, sibling: col3, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        col4.name = "HighScore_\(rowNumber)"
        rowNode.addChild(col4)
        
        let col5 = SKSpriteNode()
        col5.size.width = rowWidth * COL5_WIDTH
        col5.size.height = rowHeight
        col5.position = display.GetSiblingAnchor(col5, sibling: col4, anchorTo: Display.ANCHOR.CENTER_RIGHT)
        col5.name = "CriminalsCaught_\(rowNumber)"
        rowNode.addChild(col5)
        
        return (col1, col2, col3, col4, col5)
    }
      */
}
