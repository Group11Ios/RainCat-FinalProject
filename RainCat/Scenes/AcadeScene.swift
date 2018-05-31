//
//  AcadeScene.swift
//  RainCat
//
//  Created by Hoang on 5/25/18.
//  Copyright © 2018 Thirteen23. All rights reserved.
//

import SpriteKit
import Speech
import AudioToolbox
class AcadeScene: SceneNode, QuitNavigation, SKPhysicsContactDelegate,SFSpeechRecognizerDelegate{
    
    
    //setup record
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    //set up game
    private let foodEdgeMargin : CGFloat = 75.0
    private var cat : CatSprite!
    private var food : FoodSprite?
    
    
    //
    private var fakeFood:SKSpriteNode!
    //
    private var backgroundNode : BackgroundNode!
    private var groundNode : GroundNode!
    private let labelSpeech = SKLabelNode(fontNamed: BASE_FONT_NAME)
    private let resultSpeech = SKLabelNode(fontNamed: BASE_FONT_NAME)
    
    
    private var currentPalette = ColorManager.sharedInstance.resetPaletteIndex()
    
    private var catScale : CGFloat = 1
    private var quitButton : TwoPaneButton!
    
    private var  recordButton : TwoPaneButton!
      var isMultiplayer = false
    override func detachedFromScene() {}
    
    override func layoutScene(size : CGSize, extras menuExtras: MenuExtras?) {
        
        if let extras = menuExtras {
            catScale = extras.catScale
        }
        isUserInteractionEnabled = true
        
        anchorPoint = CGPoint()
        
        labelSpeech.text = ""
        labelSpeech.fontSize = 40
        labelSpeech.position = CGPoint(x: size.width / 2, y: size.height - 100)
        labelSpeech.zPosition = 1

        addChild(labelSpeech)
        //
        
        
        resultSpeech.text = ""
        resultSpeech.fontSize = 20
        resultSpeech.position = CGPoint(x: size.width / 2, y: labelSpeech.position.y - 50)
        resultSpeech.zPosition = 1
        
        addChild(resultSpeech)
        
        //
        quitButton = TwoPaneButton(color: UIColor.clear, size: CGSize(width: 80, height: 80))
        quitButton.setup(text: "Quit", fontSize: 20)
        quitButton.elevation = 5
        quitButton.position = CGPoint(x: size.width - quitButton.size.width - 25, y: size.height - quitButton.size.height - 5)
        quitButton.zPosition = 1000
        quitButton.addTarget(self, selector: #selector(quitPressed), forControlEvents: .TouchUpInside)
        
        
        addChild(quitButton)
        
        
        recordButton = TwoPaneButton(color: UIColor.clear, size: CGSize(width: 200, height: 100))
        recordButton.setup(text: "Start Recording", fontSize: 20)
        recordButton.elevation = 5
        recordButton.position = CGPoint(x: 50, y: size.height - recordButton.size.height)
        recordButton.zPosition = 1000
        recordButton.addTarget(self, selector: #selector(recordPressed), forControlEvents: .TouchUpInside)
        
        
        
        addChild(recordButton)
        
        
        //Background Setup
        backgroundNode = BackgroundNode.newInstance(size: size, palette: currentPalette)
        
        addChild(backgroundNode)
        
        //Ground Setup
        groundNode = GroundNode.newInstance(size: size, palette: currentPalette)
        
        addChild(groundNode)
        //World Frame Setup
        
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsBody?.categoryBitMask = WorldFrameCategory
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                self.recordButton.enabled = true
                
            case .denied:
                self.recordButton.enabled = false
                print("User denied access to speech recognition")
            case .restricted:
                self.recordButton.enabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                self.recordButton.enabled = false
                print("Speech recognition not yet authorized")
                
            }
        }
    }
    
    override func attachedToScene() {
        //Spawn initial cat and food
        spawnCat()
        spawnFood()
    }
    func recordPressed() {
         SoundManager.playButtonClick(node: recordButton)
        
          SoundManager.sharedInstance.resumeMusic()
       //restore music
        
      if audioEngine.isRunning {
            spawmFoodNextToCat(foodNameRecord: labelSpeech.text!)
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.recordButton.enabled = false
        
            recordButton.setup(text: "Start Recording", fontSize: 20)
           audioEngine.prepare()
            do {
                try audioEngine.start()
            } catch {
                print("audioEngine couldn't start because of an error.")
            }
        
       }
      else {
            startRecording()
            recordButton.setup(text: "Stop Recording", fontSize: 20)
        }
    }
    func startRecording(){
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in var isFinal = false
            
            if result != nil {
                
                //self.textView.text =
                self.labelSpeech.text = result?.bestTranscription.formattedString
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                 self.recordButton.enabled = true

            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
              self.labelSpeech.text =  "Say something, I'm listening!"
              self.resultSpeech.text = ""

    }
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
              self.recordButton.enabled = true
        } else {
              self.recordButton.enabled = false
        }
    }
    func quitPressed() {
        if let parent = parent as? Router {
            parent.navigate(to: .MainMenu, extras: MenuExtras(rainScale: 0,
                                                              catScale: 0,
                                                              transition: TransitionExtras(transitionType: .ScaleInLinearTop)))
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
     
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
     
    }
    override func update(dt: TimeInterval) {
        if let food = childNode(withName: FoodSprite.foodDishName) as? FoodSprite {
            var position = food.position
            food.zPosition = -9999
            cat.update(deltaTime: dt, foodLocation: position)
        }
        cat.movementSpeed = cat.baseMovementSpeed
    }
    func spawnCat() {
        if let currentCat = cat, children.contains(currentCat) {
            cat.removeFromParent()
            cat.removeAllActions()
            cat.physicsBody = nil
        }
        
        cat = CatSprite.newInstance()
        
        cat.setScale(0.5)
        cat.position = CGPoint(x: size.width/2, y: size.height/2)
        cat.run(SKAction.scale(to: catScale, duration: 0.3))
        
        addChild(cat)
    }
    func spawmFoodNextToCat(foodNameRecord : String){

        
     
        let myStringDict1ContainsWord = FoodSprite.dict.contains {
            key, value in //<- `value` is inferred as `String`
            value.contains(foodNameRecord) //<- true when value contains "e", false otherwise
        }
        if myStringDict1ContainsWord == true{
            fakeFood = SKSpriteNode(imageNamed: foodNameRecord)
            fakeFood?.position = CGPoint(x: cat.position.x, y: cat.position.y )
            fakeFood?.zPosition = 10000
            addChild(fakeFood!)
        }
        else{
            self.resultSpeech.text   = "Not found food in cat!"
        }
       
    }
    
    func playSound() {
        var player : AVAudioPlayer?
        guard let url = Bundle.main.url(forResource: "bensound-jazzcomedy", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    func spawnFood() {
        var containsFood = false
        
        for child in children {
            if child.name == FoodSprite.foodDishName {
                containsFood = true
                break
            }
        }
        
        if !containsFood {
            food = FoodSprite.newInstance(palette: currentPalette)
            var randomPosition : CGFloat = CGFloat(arc4random())
            randomPosition = randomPosition.truncatingRemainder(dividingBy: size.width - foodEdgeMargin * 2)
            randomPosition += foodEdgeMargin
            
            food?.position = CGPoint(x: randomPosition, y: size.height)
            food?.physicsBody?.friction = 100
            food?.zPosition = -99999
            addChild(food!)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == FoodCategory || contact.bodyB.categoryBitMask == FoodCategory {
            handleFoodHit(contact: contact)
        }
        
        if contact.bodyA.categoryBitMask == CatCategory || contact.bodyB.categoryBitMask == CatCategory {
            handleCatCollision(contact: contact)
            return
        }
        if contact.bodyA.categoryBitMask == WorldFrameCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldFrameCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
    
    func handleCatCollision(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask == CatCategory {
            otherBody = contact.bodyB
        } else {
            otherBody = contact.bodyA
        }
        
        switch otherBody.categoryBitMask {

        case WorldFrameCategory:
            spawnCat()
        case FloorCategory:
            cat.isGrounded = true
        default:
            print("Something hit the cat")
        }
    }
    
    override func getGravity() -> CGVector {
        return CGVector(dx: 0, dy: -7.8)
    }
    
    func handleFoodHit(contact: SKPhysicsContact) {
        var otherBody : SKPhysicsBody
        var foodBody : SKPhysicsBody
        
        if(contact.bodyA.categoryBitMask == FoodCategory) {
            otherBody = contact.bodyB
            foodBody = contact.bodyA
        } else {
            otherBody = contact.bodyA
            foodBody = contact.bodyB
        }
        
        switch otherBody.categoryBitMask {
        case CatCategory:
            //Stronger gravity the higher the score
            
            fallthrough
        case WorldFrameCategory:
            foodBody.node?.removeFromParent()
            foodBody.node?.physicsBody = nil
            
            food = nil
            
            spawnFood()
            
        default:
            print("something else touched the food")
        }
    }
    
    func updateColorPalette() {
        currentPalette = ColorManager.sharedInstance.getNextColorPalette()
        
        for node in children {
            if let node = node as? Palettable {
                node.updatePalette(palette: currentPalette)
            }
        }
    }
    
    func resetColorPalette() {
        currentPalette = ColorManager.sharedInstance.resetPaletteIndex()
        
        for node in children {
            if let node = node as? Palettable {
                node.updatePalette(palette: currentPalette)
            }
        }
    }
    
    deinit {
        print("game scene destroyed")
    }
}
