//
//  FyMKUtils.swift
//  SimulationMouseKeyboard
//
//  Created by l on 2020/3/30.
//  Copyright © 2020 ifeiyv. All rights reserved.
//

import Cocoa

class FyMKUtils: NSObject {
    
    //MARK:移动鼠标到坐标位置
    open class func mouseMove(point:CGPoint,button:CGMouseButton = .left){
        postMouseEvent(button: button, type: .mouseMoved, point: point);
    }
    
    //MARK:左键单击
    open class func leftClick(point: CGPoint)
    {
        click(point: point, button: .left)
    }
    //MARK:左键双击
    open class func leftDoubleClick(point: CGPoint)
    {
        doubleClick(point: point, button: .left)
    }
    
    //MARK:左键拖拽
    ///point : 初始位置坐标
    ///toPoint : 拖拽到的目的位置坐标
    open class func leftMouseDragged(point:CGPoint,toPoint:CGPoint){
        mouseDragged(point:point,toPoint:toPoint,button:.left)
    }
    
    //MARK:右键单击
    open class func rightClick(point: CGPoint)
    {
        click(point: point, button: .right)
    }
    
    //MARK:右键双击
    open class func rightDoubleClick(point: CGPoint)
    {
        doubleClick(point: point, button: .right)
    }
    
    //MARK:右键拖拽
    ///point : 初始位置坐标
    ///toPoint : 拖拽到的目的位置坐标
    open class func rightMouseDragged(point:CGPoint,toPoint:CGPoint){
        mouseDragged(point:point,toPoint:toPoint,button:.right)
    }
    
    //MARK:鼠标从一个坐标移动到另一个坐标
    open class func mouseMove(point:CGPoint, toPoint:CGPoint){
        
        //拖到的目的位置x大于原始位置的X坐标
        let toMaxX:Bool = toPoint.x - point.x > 0
        //拖到的目的位置y大于原始位置的Y坐标
        let toMaxY:Bool = toPoint.y - point.y > 0
        
        var tempPointY = point.y
        var tempPointX = point.x
        
        
        let blockOperation = BlockOperation()
        
        //1.拖拽目的坐标的Y坐标
        blockOperation.addExecutionBlock {
            while  toMaxY ? (toPoint.y > tempPointY) : (toPoint.y < tempPointY){
                toMaxY ?  (tempPointY += 1) : (tempPointY -= 1)
                postMouseEvent(button: .left, type: .mouseMoved, point: CGPoint(x: tempPointX, y: tempPointY),clickCount: 1);
                Thread.sleep(forTimeInterval: 0.001)
            }
        }
        //2.拖拽目的坐标的X坐标
        blockOperation.addExecutionBlock {
            while toMaxX ? (toPoint.x > tempPointX) : (toPoint.x < tempPointX) {
                toMaxX ? (tempPointX += 1) : (tempPointX -= 1)
                postMouseEvent(button: .left, type: .mouseMoved, point: CGPoint(x: tempPointX, y: tempPointY),clickCount: 1);
                Thread.sleep(forTimeInterval: 0.001)
            }
            
        }
        //开始执行Operation
        blockOperation.start()
        
    }

    
    //MARK:拖拽鼠标事件
    open class func mouseDragged(point:CGPoint,toPoint:CGPoint,button:CGMouseButton){
        //拖到的目的位置x大于原始位置的X坐标
        let toMaxX:Bool = toPoint.x - point.x > 0
        //拖到的目的位置y大于原始位置的Y坐标
        let toMaxY:Bool = toPoint.y - point.y > 0
        
        var tempPointY = point.y
        var tempPointX = point.x
        
        //1.按下鼠标
        postMouseEvent(button: button, type: button == .left  ? .leftMouseDown : .rightMouseDown, point: point,clickCount: 1);
        
        let blockOperation = BlockOperation()
        
        //2.拖拽目的坐标的Y坐标
        blockOperation.addExecutionBlock {
            while  toMaxY ? (toPoint.y > tempPointY) : (toPoint.y < tempPointY){
                toMaxY ?  (tempPointY += 1) : (tempPointY -= 1)
                postMouseEvent(button: button, type: button == .left  ? .leftMouseDragged : .rightMouseDragged, point: CGPoint(x: tempPointX, y: tempPointY),clickCount: 1);
            }
        }
        //3.拖拽目的坐标的X坐标
        blockOperation.addExecutionBlock {
            while toMaxX ? (toPoint.x > tempPointX) : (toPoint.x < tempPointX) {
                toMaxX ? (tempPointX += 1) : (tempPointX -= 1)
                postMouseEvent(button: button, type: button == .left  ? .leftMouseDragged : .rightMouseDragged, point: CGPoint(x: tempPointX, y: tempPointY),clickCount: 1);
            }
            
        }
        //4.松开鼠标
        blockOperation.completionBlock = {
            print("hhhhh")
            postMouseEvent(button: button, type: button == .left  ? .leftMouseUp : .rightMouseUp, point: toPoint,clickCount: 1);
        }
        //开始执行Operation
        blockOperation.start()
    }

    
    //MARK:鼠标单击
    open class func click(point: CGPoint,button:CGMouseButton,clickCount:Int64 = 1){
        //1.按下鼠标左键（移动到坐标位置后，可以加适当延时再按鼠标左键）
        postMouseEvent(button: button, type: button == .left  ? .leftMouseDown : .rightMouseDown, point: point,clickCount: clickCount);
        //2.松开鼠标左键
        postMouseEvent(button: button, type: button == .left  ? .leftMouseUp : .rightMouseUp, point: point,clickCount: clickCount);
    }
    //MARK:鼠标双击
    open class func doubleClick(point: CGPoint,button:CGMouseButton){
        click(point: point, button: button,clickCount:1)
        click(point: point, button: button,clickCount:2)
    }
    
    
    //鼠标事件
    private class func postMouseEvent(button:CGMouseButton, type:CGEventType, point: CGPoint,clickCount:Int64 = 1)
    {
        let event = createMouseEvent(button: button, type: type, point: point,clickCount:clickCount)
        event.post(tap: CGEventTapLocation.cghidEventTap)
    }
    //创建鼠标事件
    open class func createMouseEvent(button:CGMouseButton, type:CGEventType, point: CGPoint,clickCount:Int64 = 1) ->  CGEvent
    {
        let event : CGEvent  = CGEvent(mouseEventSource: CGEventSource.init(stateID: CGEventSourceStateID.privateState), mouseType: type, mouseCursorPosition: point, mouseButton: button)!
        event.setIntegerValueField(CGEventField.mouseEventClickState, value: clickCount)
        return event
    }
    
    ///鼠标滚轮事件目前仅支持OSX 10.13版本以上使用
    ///postion 横向或者纵向滚动的距离，
    ///纵向   postion为正数 向下滚动，为负数 向上滚动，横向   postion为正数 向右滚动，为负数 向左滚动
    ///FyMKUtils.postScrollWheelEvent(position: -10000,scrollOrientation: .horizontal)//向左滚动10000 个像素点
    ///FyMKUtils.postScrollWheelEvent(position: 10000,scrollOrientation: .horizontal)//向右滚动10000 个像素点
    ///FyMKUtils.postScrollWheelEvent(position: -10000,scrollOrientation: .vertical)//向上滚动10000 个像素点
    ///FyMKUtils.postScrollWheelEvent(position: 10000,scrollOrientation: .vertical)//向下滚动10000 个像素点
    ///scrollOrientation  横向或者纵向
    ///units: 滚动距离单位   .pixel 像素 .line行。默认像素
    @available(OSX 10.13, *)
    open class func postScrollWheelEvent(position:Int32 ,scrollOrientation:ScrollOrientation = .vertical,units:CGScrollEventUnit = .pixel){
        //翻转偏移值
        let tempPosition = -position
        let event  = CGEvent(scrollWheelEvent2Source:nil, units: units, wheelCount: 2, wheel1: scrollOrientation == .vertical ? tempPosition : 0, wheel2: scrollOrientation == .horizontal ? tempPosition : 0,wheel3: 0)
        event?.post(tap: .cghidEventTap)
        
    }
    
    //
    
    
    //MARK:-------------------------------
    //MARK:键盘类操作
    
    /*
    public struct CGEventFlags : OptionSet {

        public init(rawValue: UInt64) /* Flags for events */

        
        /* Device-independent modifier key bits. */
     
        //大小写锁定键处于开启状态(亮灯状态)
        public static var maskAlphaShift: CGEventFlags { get }
        
        //Shift 键按下
        public static var maskShift: CGEventFlags { get }
        
        //Control 键按下
        public static var maskControl: CGEventFlags { get }

        //Alt(Option) 键按下
        public static var maskAlternate: CGEventFlags { get }

        //Command 键按下
        public static var maskCommand: CGEventFlags { get }

        
        /* Special key identifiers. */
        //Help 键按下
        public static var maskHelp: CGEventFlags { get }

        //Fn 键按下
        public static var maskSecondaryFn: CGEventFlags { get }

        
        /* Identifies key events from numeric keypad area on extended keyboards. */
        //数字键 按下
        public static var maskNumericPad: CGEventFlags { get }

        
        /* Indicates if mouse/pen movement events are not being coalesced */
        //没有鼠标和苹果笔 按下
        public static var maskNonCoalesced: CGEventFlags { get }
    }
    */
    
    /// 键盘类操作
    /// - Parameters:
    ///   - keyCode: 键盘事件中使用的虚拟键码,CGKeyCode 要使用系统定义好的，需要导入  import Carbon     eg  A:  kVK_ANSI_A
    ///   - keyDown: keyDown true按下 false 抬起  成对存在
    ///   - flags: CGEventFlags  ---- 用作组合键
    /// - ForExample:
    ///   - K: FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: true, flags: .maskNonCoalesced) <br>
    ///     FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: false, flags: .maskNonCoalesced) <br>
    ///   - Command + KC: FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: true, flags: .maskCommand) <br>FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: false, flags: .maskCommand)
    ///   - Command + Shift + K: <br> FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: true, flags: [.maskCommand,.maskShift]) <br> FyMKUtils.postKeyboardEvent(keyCode: CGKeyCode(kVK_ANSI_K), keyDown: false, flags: [.maskCommand,.maskShift])
    open class func postKeyboardEvent(keyCode:CGKeyCode,keyDown:Bool,flags:CGEventFlags){
        let event = CGEvent.init(keyboardEventSource: CGEventSource.init(stateID: CGEventSourceStateID.privateState), virtualKey: keyCode, keyDown: keyDown)
        event?.flags = flags
        event?.post(tap: .cghidEventTap)
    }
    
    
}

//MARK:鼠标滚动方向
enum ScrollOrientation {
    case horizontal
    case vertical
}
