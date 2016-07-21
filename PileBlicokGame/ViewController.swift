//
//  ViewController.swift
//  PileBlicokGame
//
//  Created by zhuguangyang on 16/7/19.
//  Copyright © 2016年 Giant. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let MARGINE: CGFloat = 10
    let BUTTION_SIZE:CGFloat = 48
    let BUTTON_ALPHA:CGFloat = 0.4
    let TOOLBAR_HEIGHT:CGFloat = 44
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var gameView: GameView!
    /// 定义背景音乐的播放对象
    var bgMusicPlayer: AVAudioPlayer!
    
    ///显示当前速度
    var speedShow: UILabel!
    /// 显示当前积分
    var scoreShow: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var rect = UIScreen.mainScreen().bounds
        screenWidth = rect.size.width
        screenHeight = rect.size.height
        //添加工具条
        addToolBar()
        
        //创建GameView控件
        gameView = GameView(frame: CGRect(x: rect.origin.x + MARGINE, y: rect.origin.y + TOOLBAR_HEIGHT + MARGINE * 2, width: rect.size.width - MARGINE * 2, height: rect.size.height - 80))
        
        //添加绘制游戏状态的自定义View
        self.view.addSubview(gameView)
        //        gameView.startGame()
        //添加游戏控制按钮
        self.addButtons()
        //        //获取背景音效的音频文件URL
        //        let bgMusicURL = NSBundle.mainBundle().URLForResource("zhu", withExtension: "mp3")
        //        //创建AVAudioPlayer
        //        do {
        //            bgMusicPlayer = try AVAudioPlayer(contentsOfURL: bgMusicURL!)
        //            bgMusicPlayer.numberOfLoops = -1
        //            //播放
        //            bgMusicPlayer.play()
        //        } catch {
        //            print(error)
        //        }
        
        gameView.delegate = self
    }
    
    func addToolBar(){
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: MARGINE * 2, width: screenWidth, height: TOOLBAR_HEIGHT))
        self.view.addSubview(toolBar)
        //创建第一个显示速度Lab
        let speedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: TOOLBAR_HEIGHT))
        speedLabel.text = "速度:"
        let speedLabelItem = UIBarButtonItem(customView: speedLabel)
        
        //创建显示速度值的标签
        speedShow = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: TOOLBAR_HEIGHT))
        speedShow.textColor = UIColor.redColor()
        speedShow.text = "0"
        let  speedShowItem = UIBarButtonItem(customView: speedShow)
        
        //当前积分
        let scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 90, height: TOOLBAR_HEIGHT))
        scoreLabel.text = "当前积分:"
        let  scoreLabelItem = UIBarButtonItem(customView: scoreLabel)
        
        //显示积分
        scoreShow = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: TOOLBAR_HEIGHT))
        scoreShow.textColor = UIColor.redColor()
        scoreShow.text = "0"
        let  scoreShowItem = UIBarButtonItem(customView: scoreShow)
        
        let flexItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        //为工具条设置工具项
        toolBar.items = [speedLabelItem,speedShowItem,flexItem,scoreLabelItem,scoreShowItem];
        
        
        
    }
    
    func addButtons() {
        let startBn = UIButton(type: UIButtonType.Custom)
        startBn.frame = CGRect(x: 10, y:  screenHeight - BUTTION_SIZE - MARGINE, width: BUTTION_SIZE, height: BUTTION_SIZE)
        startBn.setTitle("开始", forState: UIControlState.Normal)
        startBn.setTitle("结束", forState: UIControlState.Selected)
        
        startBn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        startBn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Selected)
        startBn.addTarget(self, action: #selector(ViewController.startEnd(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(startBn)
        
        
        //添加向左按钮
        let leftBn = UIButton(type: UIButtonType.Custom)
        
        leftBn.frame = CGRect(x: screenWidth - BUTTION_SIZE * 3 - MARGINE, y: screenHeight - BUTTION_SIZE - MARGINE, width: BUTTION_SIZE, height: BUTTION_SIZE)
        leftBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Normal)
        leftBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Highlighted)
        leftBn.alpha = BUTTON_ALPHA
        self.view.addSubview(leftBn)
        
        leftBn.addTarget(self, action: #selector(ViewController.left(_:)), forControlEvents: .TouchUpInside)
        
        //添加向下按钮
        let downBn = UIButton(type: UIButtonType.Custom)
        
        downBn.frame = CGRect(x: screenWidth - BUTTION_SIZE * 2 - MARGINE, y: screenHeight - BUTTION_SIZE - MARGINE, width: BUTTION_SIZE, height: BUTTION_SIZE)
        downBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Normal)
        downBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Highlighted)
        downBn.alpha = BUTTON_ALPHA
        self.view.addSubview(downBn)
        
        downBn.addTarget(self, action: #selector(ViewController.down(_:)), forControlEvents: .TouchUpInside)
        
        //添加向右按钮
        let rightBn = UIButton(type: UIButtonType.Custom)
        
        rightBn.frame = CGRect(x: screenWidth - BUTTION_SIZE * 1 - MARGINE, y: screenHeight - BUTTION_SIZE - MARGINE, width: BUTTION_SIZE, height: BUTTION_SIZE)
        rightBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Normal)
        rightBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Highlighted)
        rightBn.alpha = BUTTON_ALPHA
        self.view.addSubview(rightBn)
        
        rightBn.addTarget(self, action: #selector(ViewController.right(_:)), forControlEvents: .TouchUpInside)
        
        //添加向上按钮
        let upBn = UIButton(type: UIButtonType.Custom)
        
        upBn.frame = CGRect(x: screenWidth - BUTTION_SIZE * 2 - MARGINE, y: screenHeight - BUTTION_SIZE * 2 - MARGINE, width: BUTTION_SIZE, height: BUTTION_SIZE)
        upBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Normal)
        upBn.setImage(UIImage(named: "down0.jpg"), forState: UIControlState.Highlighted)
        upBn.alpha = BUTTON_ALPHA
        self.view.addSubview(upBn)
        
        upBn.addTarget(self, action: #selector(ViewController.up(_:)), forControlEvents: .TouchUpInside)
        
        
    }
    
    func left(sender: AnyObject)  {
        gameView.moveLeft()
    }
    func right(sender: AnyObject)  {
        gameView.moveRight()
    }
    
    func down(sender: AnyObject)  {
        gameView.rotate()
    }
    
    func up(sender: AnyObject)  {
        gameView.rotate()
    }
    
    func startEnd(sender: UIButton) {
        if sender.selected {
            //开始游戏
            gameView.finishedGame()
            bgMusicPlayer.stop()
            
        } else {
            gameView.startGame()
            //获取背景音效的音频文件URL
            let bgMusicURL = NSBundle.mainBundle().URLForResource("zhu", withExtension: "mp3")
            //创建AVAudioPlayer
            do {
                bgMusicPlayer = try AVAudioPlayer(contentsOfURL: bgMusicURL!)
                bgMusicPlayer.numberOfLoops = -1
                //播放
                bgMusicPlayer.play()
            } catch {
                print(error)
            }
        }
        sender.selected = !sender.selected
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
extension ViewController: GameViewDelegate {
    
    func updateSpeed(speed: Int) {
        self.speedShow.text = "\(speed)"
    }
    func updateSouce(score: Int) {
        self.scoreShow.text = "\(score)"
    }
}
