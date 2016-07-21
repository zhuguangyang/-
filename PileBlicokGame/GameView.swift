//
//  GameView.swift
//  PileBlicokGame
//
//  Created by zhuguangyang on 16/7/19.
//  Copyright © 2016年 Giant. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameViewDelegate {
    func updateSouce(score: Int)
    func updateSpeed(speed: Int)
}

class GameView: UIView {
    
    let TETRIS_ROWS = 22
    let TETRIS_COLS = 15
    let BASE_SPEED:Double = 1
    let CELL_SIZE:Int
    //定义绘制网格的笔触粗细
    let STROKE_WIDTH: Double = 1
    var ctx: CGContextRef!
    //定义一个UIImage实例，该实例代表内存中的图片
    var image: UIImage!
    //定义一个消除音乐的AVAudioPlayer对象
    var disPlayer: AVAudioPlayer!
    //记录方块状态的二维数组属性
    var tetris_status = [[Int]]()
    var curScore: Int = 0
    var curSpeed: Int = 1
    /// 方块的颜色
    let colors = [UIColor.whiteColor().CGColor,
                  UIColor.redColor().CGColor,
                  UIColor.greenColor().CGColor,
                  UIColor.blueColor().CGColor,
                  UIColor.yellowColor().CGColor,
                  UIColor.magentaColor().CGColor,
                  UIColor.purpleColor().CGColor,
                  UIColor.brownColor().CGColor]
    /// 定义几种可能出现的方块
    let blockArr: [[Block]]
    /// 定义记录正在下掉的四个方块的属性
    var currentFall: [Block]!
    
    var curTimer: NSTimer
    
    var delegate: GameViewDelegate?
    override init(frame: CGRect) {
        //计算方块大小
        self.CELL_SIZE = Int(frame.size.width) / TETRIS_COLS
        
        self.blockArr = [
            //Z
            [Block(x: TETRIS_COLS / 2 - 1,y: 0,color: 1),
                Block(x: TETRIS_COLS / 2,y: 0,color: 1),
                Block(x: TETRIS_COLS / 2 ,y: 1,color: 1),
                Block(x: TETRIS_COLS / 2 + 1,y: 1,color: 1)],
            //反Z
            [Block(x: TETRIS_COLS / 2 + 1,y: 0,color: 2),
                Block(x: TETRIS_COLS / 2,y: 0,color: 2),
                Block(x: TETRIS_COLS / 2 ,y: 1,color: 2),
                Block(x: TETRIS_COLS / 2 - 1,y: 1,color: 2)],
            //田
            [Block(x: TETRIS_COLS / 2 - 1,y: 0,color: 3),
                Block(x: TETRIS_COLS / 2,y: 0,color: 3),
                Block(x: TETRIS_COLS / 2 - 1,y: 1,color: 1),
                Block(x: TETRIS_COLS / 2,y: 1,color: 3)],
            //L
            [Block(x: TETRIS_COLS / 2 - 1,y: 0,color: 4),
                Block(x: TETRIS_COLS / 2 - 1,y: 1,color: 4),
                Block(x: TETRIS_COLS / 2 - 1,y: 2,color: 4),
                Block(x: TETRIS_COLS / 2 ,y: 2,color: 4)],
            //j
            [Block(x: TETRIS_COLS / 2,y: 0,color: 5),
                Block(x: TETRIS_COLS / 2,y: 1,color: 5),
                Block(x: TETRIS_COLS / 2,y: 2,color: 5),
                Block(x: TETRIS_COLS / 2 - 1 ,y: 2,color: 5)],
            //条
            [Block(x: TETRIS_COLS / 2,y: 0,color: 6),
                Block(x: TETRIS_COLS / 2,y: 1,color: 6),
                Block(x: TETRIS_COLS / 2,y: 2,color: 6),
                Block(x: TETRIS_COLS / 2,y: 3,color: 6)],
            //j
            [Block(x: TETRIS_COLS / 2,y: 0,color: 7),
                Block(x: TETRIS_COLS / 2 - 1,y: 1,color: 7),
                Block(x: TETRIS_COLS / 2,y: 1,color: 7),
                Block(x: TETRIS_COLS / 2 + 1 ,y: 1,color: 7)]
        ]
        self.curTimer = NSTimer()
        super.init(frame: frame)
        //获取消除方块的音频文件的URL
        let disMusicURL = NSBundle.mainBundle().URLForResource("zhu1", withExtension: "mp3")
        //创建AVAudioPlayer对象
        do {
            disPlayer = try AVAudioPlayer(contentsOfURL: disMusicURL!)
            disPlayer.numberOfLoops = 0
            
        } catch{
            print(error)
        }
        //开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        //获取Quartz 2D绘图的CGContextRef对象
        ctx = UIGraphicsGetCurrentContext()
        //填充背景色
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextFillRect(ctx, self.bounds)
        //绘制方块的网格
        createCells(TETRIS_ROWS, cols: TETRIS_COLS, cellWidth: CELL_SIZE, cellHeight: CELL_SIZE)
        image = UIGraphicsGetImageFromCurrentImageContext()
        
    }
    
    
    override func drawRect(rect: CGRect) {
        //获取绘图的上下文
        var curCtx = UIGraphicsGetCurrentContext()
        //将内存的image图片绘制在该组件的左上角
        image.drawAtPoint(CGPointZero)
        
        
    }
    
    //开始游戏
    func startGame() {
        print(#function)
        //
        initTerisStatus()
        initBlock()
        if currentFall != nil && delegate != nil{
            self.curSpeed = 1
            self.delegate?.updateSpeed(curSpeed)
            self.curScore = 0
            self.delegate?.updateSouce(curScore)
        }
        
        
        curTimer = NSTimer.scheduledTimerWithTimeInterval(BASE_SPEED/Double(curSpeed), target: self, selector: #selector(GameView.moveDown), userInfo: nil, repeats: true)
    }
    
    //暂停游戏
    func stopGame() -> Void {
        curTimer.invalidate()
    }
    
    func finishedGame() -> Void {
        tetris_status.removeAll()
        initTerisStatus()
        curTimer.invalidate()
        //通知该组件重绘
        self.setNeedsDisplay()
    }
    
    
    //MARK:- 初始化游戏状态
    func initTerisStatus() {
        let tmpRow = Array(count: TETRIS_COLS, repeatedValue: 0)
        tetris_status = Array(count: TETRIS_ROWS, repeatedValue: tmpRow)
    }
    
    func initBlock() {
        //生成一个  0~blockArr.count 之间的随机数
        let rand = Int(arc4random()) % blockArr.count
        //随机取出blockArr数组的某个元素作为正在下掉的方块组合
        currentFall = blockArr[rand]
        
    }
    
    //MARK: - 控制方块组合向下掉落
    func moveDown() {
        //是否向下掉落的标志
        var canDown = true
        for i in 0 ..< currentFall.count {
            //判断是否达到底部
            if currentFall[i].y >= TETRIS_ROWS - 1 {
                canDown = false
                break
            }
            //判断下一个是否有方块 若有  则不能向下掉落
            if tetris_status[currentFall[i].y + 1][currentFall[i].x] != 0 {
                canDown = false
                break
            }
        }
        //若能向下掉落
        if canDown {
            self.drawBlock()
            //将下移前的每个方块的背景图成白色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                //绘制矩形
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            
            //遍历每个方块 控制每个方块的Y坐标+1
            //也就是控制方块都掉落一格
            for i in 0..<currentFall.count {
                currentFall[i].y += 1
            }
            //将下移后的每个方块的背景色都涂成该方块的颜色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, colors[cur.color])
                //绘制矩形
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
                
            }
        } else {
            //不能向下掉落
            //便利每个方块  把每个方块的值记录到 staus数组中
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                if cur.y < 2 {
                    //清楚计时器
                    curTimer.invalidate()
                    //显示提示框
                    let alert = UIAlertView(title: "游戏结束", message: "游戏已经结束，请问是否重新开始", delegate: self, cancelButtonTitle: "否")
                    alert.addButtonWithTitle("是")
                    alert.show()
                    return
                    
                }
                /**
                 把每个方块当前所在位子辅为当前方块的的颜色值
                 */
                tetris_status[cur.y][cur.x] = cur.color
            }
            //判断是否有可 “消除”的行
            lineFull()
            //开始一组新的方块
            initBlock()
        }
        //获取缓冲区的图片
        image = UIGraphicsGetImageFromCurrentImageContext()
        //通知该组件重绘
        self.setNeedsDisplay()
    }
    
    func lineFull() {
        //依次遍历每一行
        for i in 0..<TETRIS_ROWS {
            var flag = true
            for j in 0..<TETRIS_COLS {
                if tetris_status[i][j] == 0 {
                    flag = false
                    break
                }
            }
            //如果当前行已全部有方块了
            if flag {
                //将当前积分增加100
                curScore += 100
                self.delegate?.updateSouce(curScore)
                //如果当前积分达到升级界限
                if curScore >= curSpeed * curSpeed * 500{
                    //速度增加1
                    curSpeed += 1
                    self.delegate?.updateSpeed(curSpeed)
                    //让原有定时器失效  重新开启新的计时器
                    curTimer.invalidate()
                    curTimer = NSTimer.scheduledTimerWithTimeInterval(BASE_SPEED / Double(curSpeed), target: self, selector: #selector(GameView.moveDown), userInfo: nil, repeats: true)
                }
                // 把当前的所有方块下移一行
                for var j = i;j>0;j -= 1 {
                    for k in 0..<TETRIS_COLS {
                        tetris_status[j][k] = tetris_status[j-1][k]
                    }
                }
                //播放消除方块的音乐
                if !disPlayer.playing {
                    disPlayer.play()
                }
                
            }
        }
    }
    
    //绘制方块的状态
    func drawBlock() {
        for i in 0..<TETRIS_ROWS {
            for j in 0..<TETRIS_COLS {
                //有方块的地方绘制颜色
                if tetris_status[i][j] != 0 {
                    //设置填充颜色
                    CGContextSetFillColorWithColor(ctx, colors[tetris_status[i][j]])
                    //绘制矩形
                    CGContextFillRect(ctx, CGRect(x: CGFloat(Double(j * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(i * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
                } else {
                    CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                    //绘制矩形
                    CGContextFillRect(ctx, CGRect(x: CGFloat(Double(j * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(i * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
                }
            }
        }
    }
    
    func createCells(rows: Int,cols: Int,cellWidth: Int,cellHeight: Int) {
        //开始创建路径
        CGContextBeginPath(ctx)
        //绘制横向网格对应的路径
        for var i = 0; i <= TETRIS_ROWS;i += 1 {
            CGContextMoveToPoint(ctx, 0, CGFloat(i * CELL_SIZE))
            CGContextAddLineToPoint(ctx, CGFloat(TETRIS_COLS * CELL_SIZE), CGFloat(i * CELL_SIZE))
        }
        //绘制竖向网格对应的路径
        for var i = 0; i <= TETRIS_COLS;i += 1 {
            CGContextMoveToPoint(ctx, CGFloat(i * CELL_SIZE),0 )
            CGContextAddLineToPoint(ctx, CGFloat(i * CELL_SIZE), CGFloat(TETRIS_ROWS * CELL_SIZE))
        }
        
        CGContextClosePath(ctx)
        //设置笔触颜色
        CGContextSetStrokeColorWithColor(ctx, UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor)
        //设置线条粗细
        CGContextSetLineWidth(ctx, CGFloat(STROKE_WIDTH))
        //绘制线条
        CGContextStrokePath(ctx)
        
    }
    
    //定义左移方块组合的方法
    func moveLeft() {
        //定义能否左移的标志
        var canLeft = true
        for i in 0..<currentFall.count {
            //如果达到了最左边，不能左移
            if currentFall[i].x <= 0 {
                canLeft = false
                break
            }
            
            //或者左边的位置已有方块，不能左移
            if tetris_status[currentFall[i].y][currentFall[i].x - 1] != 0{
                canLeft = false
                break
            }
        }
        //如果能左移
        if canLeft {
            self.drawBlock()
            //将左移前的每个方块的背景涂成白色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            //左移所有正在下掉的方块
            for i in 0..<currentFall.count {
                currentFall[i].x--
            }
            //将左移后的每个方块的背景涂成方块对应的颜色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, colors[cur.color])
                //绘制矩形
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            //获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            self.setNeedsDisplay()
            
        }
        
    }
    
    
    //定义左移方块组合的方法
    func moveRight() {
        //定义能否左移的标志
        var canRight = true
        for i in 0..<currentFall.count {
            //如果达到了最右边，不能右移
            if currentFall[i].x >= TETRIS_COLS - 1 {
                canRight = false
                break
            }
            
            //或者左边的位置已有方块，不能左移
            if tetris_status[currentFall[i].y][currentFall[i].x + 1] != 0{
                canRight = false
                break
            }
        }
        //如果能左移
        if canRight {
            self.drawBlock()
            //将左移前的每个方块的背景涂成白色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            //左移所有正在下掉的方块
            for i in 0..<currentFall.count {
                currentFall[i].x++
            }
            //将左移后的每个方块的背景涂成方块对应的颜色
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, colors[cur.color])
                //绘制矩形
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            //获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            self.setNeedsDisplay()
            
        }
        
    }
    
    func rotate()
    {
        //定义是否能旋转的标志
        var canRotate = true
        for i in 0..<currentFall.count {
            var preX = currentFall[i].x
            var preY = currentFall[i].y
            
            //始终以第三个方块作为旋转的中心
            //当I == 2 说明旋转的中心
            if i != 2 {
                //计算旋转后的坐标
                var afterRotateX = currentFall[2].x + preY - currentFall[2].y
                var afterRotateY = currentFall[2].y + currentFall[2].x - preX
                //如果旋转后的x、y坐标月结，或者宣战后的位置已有方块，表明不能旋转
                if afterRotateX < 0 || afterRotateX > TETRIS_COLS - 1 || afterRotateY < 0 || afterRotateY > TETRIS_ROWS - 1 || tetris_status[afterRotateY][afterRotateX] != 0 {
                    canRotate = false
                    break
                }
            }
        }
        //如果能旋转
        if canRotate {
            self.drawBlock()
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            
            for i in 0..<currentFall.count {
                var preX = currentFall[i].x
                var preY = currentFall[i].y
                //始终以第三个方块作为旋转的中心
                if i != 2 {
                    currentFall[i].x = currentFall[2].x + preY - currentFall[2].y
                    currentFall[i].y = currentFall[2].y + currentFall[2].x - preX
                }
                
            }
            
            for i in 0..<currentFall.count {
                var cur = currentFall[i]
                //设置填充颜色
                CGContextSetFillColorWithColor(ctx, colors[cur.color])
                //绘制矩形
                CGContextFillRect(ctx, CGRect(x: CGFloat(Double(cur.x * CELL_SIZE) + STROKE_WIDTH), y: CGFloat(Double(cur.y * CELL_SIZE) + STROKE_WIDTH), width: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2), height: CGFloat(Double(CELL_SIZE) - STROKE_WIDTH * 2)))
            }
            //获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()
            self.setNeedsDisplay()
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


