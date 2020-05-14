//
//  ViewController.swift
//  Maze
//
//  Created by 竹村明日香 on 2020/05/14.
//  Copyright © 2020 Takemura assan. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var playerView: UIView!
    var playerMotionManager: CMMotionManager!
    var speedX: Double = 0.0
    var sppedY: Double = 0.0
    
    
    let scrrenSize = UIScreen.main.bounds.size
    
    let maze = [
        [1, 0, 0, 0, 1, 0],
        [1, 0, 1, 0, 1, 0],
        [3, 0, 1, 0, 1, 0],
        [1, 1, 1, 0, 0, 0],
        [1, 0, 0, 1, 1, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 1, 1, 0, 1, 0],
        [0, 0, 0, 0, 1, 1],
        [0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 2],
    ]
    
    var startView: UIView!
    var goalView: UIView!
    
    var wallRectArray = [CGRect]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let cellWidth = scrrenSize.width / CGFloat(maze[0].count)
        let cellHeight = scrrenSize.height / CGFloat(maze.count)
        
        let cellOffsetX = cellWidth / 2
        let cellOffsetY = cellHeight / 2
        
        for y in 0 ..< maze.count {
            for x in 0 ..< maze[y].count{
                switch maze[y][x] {
                case 1:
                    let wallView = creatView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    wallView.backgroundColor = UIColor.black
                    view.addSubview(wallView)
                    wallRectArray.append(wallView.frame)
                case 2:
                    startView = creatView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    startView.backgroundColor = UIColor.green
                    view.addSubview(startView)
                    
                case 3:
                    goalView = creatView(x: x, y: y, width: cellWidth, height: cellHeight, offsetX: cellOffsetX, offsetY: cellOffsetY)
                    goalView.backgroundColor = UIColor.red
                    view.addSubview(goalView)
                    
                default:
                    break
                }
            }
        }
        
        playerView = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth / 6, height: cellHeight / 6))
        playerView.center = startView.center
        playerView.backgroundColor = UIColor.gray
        view.addSubview(playerView)
        
        playerMotionManager = CMMotionManager()
        playerMotionManager.accelerometerUpdateInterval = 0.02
        
        startAccelerometer()
        
    }
    
    func creatView(x: Int, y: Int, width: CGFloat, height: CGFloat, offsetX: CGFloat, offsetY: CGFloat) -> UIView {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        let view = UIView(frame: rect)
        
        let center = CGPoint(x: offsetX + width * CGFloat(x), y: offsetY + height * CGFloat(y))
        
        view.center = center
        
        return view
    }
    
    func startAccelerometer(){
        let handler: CMAccelerometerHandler = {(CMAccelerometerData: CMAccelerometerData?, error: Error?) -> Void in
            self.speedX += CMAccelerometerData!.acceleration.x
            self.sppedY += CMAccelerometerData!.acceleration.y
            
            var posX = self.playerView.center.x + (CGFloat(self.speedX) / 3)
            var posY = self.playerView.center.y - (CGFloat(self.sppedY) / 3)
            
            if posX <= self.playerView.frame.width / 2{
                self.speedX = 0
                posX = self.playerView.frame.width / 2
            }
            if posY <= self.playerView.frame.height / 2{
                self.sppedY = 0
                posY = self.playerView.frame.height / 2
            }
            if posX >= self.scrrenSize.width - (self.playerView.frame.width / 2){
                self.speedX = 0
                posX = self.scrrenSize.width - (self.playerView.frame.width / 2)
            }
            if posY >= self.scrrenSize.height - (self.playerView.frame.height / 2){
                self.sppedY = 0
                posY = self.scrrenSize.height - (self.playerView.frame.height / 2)
            }
            
            for wallRect in self.wallRectArray{
                if wallRect.intersects(self.playerView.frame){
                    self.gameCheck(result: "gameover", massage: "壁に当たりました")
                    return
                }
            }
            
            if self.goalView.frame.intersects(self.playerView.frame){
                self.gameCheck(result: "clear", massage: "クリアしました！")
                return
            }
            
            self.playerView.center = CGPoint(x: posX, y: posY)
        }
        
        playerMotionManager.startAccelerometerUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    func gameCheck(result: String, massage: String){
        if playerMotionManager.isAccelerometerActive{
            playerMotionManager.stopAccelerometerUpdates()
        }
        
        let gameCheckAleat: UIAlertController = UIAlertController(title: result, message: "message", preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: "もう一度", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.retry()
            })
        
    }
    
    func retry() {
        playerView.center = startView.center
        
        if !playerMotionManager.isAccelerometerActive{
            self.startAccelerometer()
        }
        
        speedX = 0.0
        sppedY = 0.0
    }
    
    
}

