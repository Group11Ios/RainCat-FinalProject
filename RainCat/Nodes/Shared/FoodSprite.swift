//
//  FoodSprite.swift
//  RainCat
//
//  Created by Marc Vandehey on 8/31/16.
//  Copyright © 2016 Thirteen23. All rights reserved.
//

import SpriteKit

public class FoodSprite : SKSpriteNode, Palettable {
    public static var foodDishName = "FoodDish"
    public static let dict:[String:String] = ["Apple":"Apple",
                                              "Avocado": "Avocado" ,
                                              "Banana" : "Banana",
                                              "Grape":"Grape",
                                              "Kiwi Fruit": "Kiwifruit" ,
                                              "Orange" : "Orange",
                                              "Papaya":"Papaya",
                                              "Pineapple": "Pineapple" ,
                                              "Strawberry" : "Strawberry",
                                              "Tomato":"Tomato"]
    
    public static func newInstance(palette : ColorPalette) -> FoodSprite {
        let index  = Int(arc4random_uniform(UInt32(dict.count)))
        let randomIndex:String =  Array(dict.keys)[index]
        let randomValue:String = Array(dict.values)[index]
        let foodDish = FoodSprite(imageNamed: randomValue)
        foodDishName = randomIndex
        foodDish.name = foodDishName
        foodDish.color = palette.groundColor
        //print(foodDish.name!)
        // foodDish.color = palette.foodBowlColor
        //foodDish.colorBlendFactor = 1
        
        // foodDish.anchorPoint = CGPoint(x: 0, y: 1)
        
        foodDish.physicsBody = SKPhysicsBody(rectangleOf: foodDish.size,
                                             center: CGPoint(x: foodDish.size.width / 2, y: -foodDish.size.height / 2))
        foodDish.physicsBody?.categoryBitMask = FoodCategory
        foodDish.physicsBody?.contactTestBitMask = WorldFrameCategory | RainDropCategory | CatCategory
        foodDish.zPosition = 3
        
        //Generate Food Topping - Currently will always be brown
        //let foodHeight = foodDish.size.height * 0.25
        //let foodShape = SKShapeNode(rect: CGRect(x: 0, y: -foodHeight, width: foodDish.size.width, height: foodHeight))
        //foodShape.fillColor = SKColor(red:0.36, green:0.21, blue:0.08, alpha:1.0)
        //foodShape.strokeColor = SKColor.clear
        //foodShape.zPosition = 4
        
        // foodDish.addChild(foodShape)
        
        return foodDish
    }
    public static func newInstance(palette : ColorPalette , foodName: String) -> FoodSprite {
        let foodDish = FoodSprite(imageNamed: foodName)
        foodDishName = foodName
        foodDish.name = foodDishName
        foodDish.color = palette.groundColor
        //print(foodDish.name!)
        // foodDish.color = palette.foodBowlColor
        //foodDish.colorBlendFactor = 1
        
        // foodDish.anchorPoint = CGPoint(x: 0, y: 1)
        
        foodDish.physicsBody = SKPhysicsBody(rectangleOf: foodDish.size,
                                             center: CGPoint(x: foodDish.size.width / 2, y: -foodDish.size.height / 2))
        foodDish.physicsBody?.categoryBitMask = FoodCategory
        foodDish.physicsBody?.contactTestBitMask = WorldFrameCategory | RainDropCategory | CatCategory
        foodDish.zPosition = 3
        
        //Generate Food Topping - Currently will always be brown
        //let foodHeight = foodDish.size.height * 0.25
        //let foodShape = SKShapeNode(rect: CGRect(x: 0, y: -foodHeight, width: foodDish.size.width, height: foodHeight))
        //foodShape.fillColor = SKColor(red:0.36, green:0.21, blue:0.08, alpha:1.0)
        //foodShape.strokeColor = SKColor.clear
        //foodShape.zPosition = 4
        
        // foodDish.addChild(foodShape)
        
        return foodDish
    }
    public func updatePalette(palette: ColorPalette) {
        run(ColorAction().colorTransitionAction(fromColor: color, toColor: palette.foodBowlColor, duration: colorChangeDuration))
    }
}
