//
//  chartView.swift
//  ChartView
//
//  Created by ZhengWeiLi on 2017/9/12.
//  Copyright © 2017年 sss. All rights reserved.
//

import UIKit

enum chartViewMode
{
    case week
    case month
    case year
}

class chartView: UIView ,mainScrollViewDelegate
{
    // MARK: Property
    var width: CGFloat = 0
    var height: CGFloat = 0
    var heightWithoutBtn: CGFloat = 0
    var mode: chartViewMode = chartViewMode.week
    var xCount: Int = 0
    var maxValue: CGFloat = 0
    var minValue: CGFloat = 0
    var avgValue: CGFloat = 0
    var unitY: CGFloat = 0
    var labelHeight: CGFloat = 30
    var xLabelWidth: CGFloat = 0
    let yLabelWidth: CGFloat = 40
    var chartHeight: CGFloat = 0
    var firstExistIndex = -1
    var lastExistIndex = -1
    var delegate: chartViewDelegate? = nil
    let myScrollView: mainScrollView = mainScrollView()
    var datas: Array<Any> = []
    var xPositonArray:Array<CGFloat> = []
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        width = self.frame.size.width
        height = self.frame.size.height
        heightWithoutBtn = height - (height * 0.15)
        myScrollView.frame = CGRect (x: yLabelWidth, y: 0, width: width - yLabelWidth, height: heightWithoutBtn)
        myScrollView.backgroundColor = UIColor.clear
        chartHeight = heightWithoutBtn - labelHeight - 2
        switch mode
        {
        case .week:
            xCount = 7
            break
        case .month:
            xCount = 30
            break
        case .year:
            xCount = 12
            break
        }
        xLabelWidth = (width - yLabelWidth) / CGFloat(xCount)
        getNeededValue(datas: self.datas)

        xPositonArray.removeAll()
        for index in 0..<self.datas.count
        {
            xPositonArray.append(CGFloat(index) * xLabelWidth + yLabelWidth)
        }
        myScrollView.setDataSource(xPositonArray)
        myScrollView.myDelegate = self
        myScrollView.contentSize = CGSize (width: getTotalContentSizeOfWidth(), height: heightWithoutBtn)
        myScrollView.scrollRectToVisible(CGRect (x: myScrollView.contentSize.width - 1, y: myScrollView.contentSize.height - 1, width: 1, height: 1), animated: true)
    }
    
    override func draw(_ rect: CGRect)
    {
        self.addSubview(myScrollView)
        drawUnderXLine()
        drawBtn()
        drawXValue()
        drawYValue()
        drawLineWithDatas(datas: self.datas)
        drawAvgLine()
    }
    
    // MARK: Draw Methods
    
    fileprivate func drawUnderXLine()
    {
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint (x: 0, y: heightWithoutBtn))
        var atLeastCount = 0
        switch mode
        {
        case .week:
            atLeastCount = self.datas.count >= 7 ? self.datas.count : 7
        case .month:
            atLeastCount = self.datas.count >= 30 ? self.datas.count : 30
        case .year:
            atLeastCount = self.datas.count >= 12 ? self.datas.count : 12
        }
        path.addLine(to: CGPoint (x: xLabelWidth * CGFloat(atLeastCount), y: heightWithoutBtn))
        let shaper: CAShapeLayer = CAShapeLayer()
        shaper.path = path.cgPath
        shaper.strokeColor = UIColor.white.cgColor
        shaper.lineWidth = 2
        myScrollView.layer.addSublayer(shaper)
    }
    
    fileprivate func drawXValue()
    {
        var atLeastX: Int = 0
        var eachXWidth: CGFloat = 0
        switch mode
        {
        case .week:
             atLeastX = self.datas.count >= 7 ? self.datas.count : 7
             eachXWidth = xLabelWidth
        case .year:
            atLeastX = self.datas.count >= 12 ? self.datas.count : 12
            eachXWidth = xLabelWidth
        case .month:
            atLeastX = self.datas.count / 7 >= 4 ? self.datas.count / 7 : 4
            eachXWidth = myScrollView.frame.size.width / 4
        }
        for index in 0..<atLeastX
        {
            let xLabel: UILabel = UILabel (frame: CGRect (x: CGFloat(index) * eachXWidth,
                                                                  y: chartHeight,
                                                                  width: eachXWidth,
                                                                  height: labelHeight))
            xLabel.textColor = UIColor.white
            xLabel.font = UIFont.systemFont(ofSize: 10)
            xLabel.text = String(format: "%i", index + 1 - (Int(index / xCount) * xCount))
            xLabel.textAlignment = .center
            myScrollView.addSubview(xLabel)
        }
    }
    
    fileprivate func drawYValue()
    {
        for index in 0..<5
        {
            let yLabel: UILabel = UILabel (frame: CGRect (x: 0,
                                                                  y: (chartHeight / 5 * CGFloat(index)),
                                                                  width: yLabelWidth,
                                                                  height: chartHeight / 5))
            yLabel.textColor = UIColor.white
            yLabel.font = UIFont.systemFont(ofSize: 10)
            yLabel.text = String(format: "%.2f", maxValue - (unitY * CGFloat(index)))
            yLabel.textAlignment = .center
            self.addSubview(yLabel)
        }
    }
    
    fileprivate func drawAvgLine()
    {
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint (x: 0, y: calculateYVlaue(value: Float(avgValue))))
        var atLeastCount = 0
        switch mode
        {
        case .week:
            atLeastCount = self.datas.count >= 7 ? self.datas.count : 7
        case .month:
            atLeastCount = self.datas.count >= 30 ? self.datas.count : 30
        case .year:
            atLeastCount = self.datas.count >= 12 ? self.datas.count : 12
        }
        path.addLine(to: CGPoint (x: xLabelWidth * CGFloat(atLeastCount), y: calculateYVlaue(value: Float(avgValue))))
        let shaper: CAShapeLayer = CAShapeLayer()
        shaper.path = path.cgPath
        shaper.strokeColor = UIColor.white.cgColor
        shaper.lineWidth = 1
        shaper.lineDashPattern = [4,2]
        shaper.fillColor = UIColor.clear.cgColor
        myScrollView.layer.addSublayer(shaper)
    }

    fileprivate func drawBtn()
    {
        let buttonWidth: CGFloat = width / 3
        let modeTitleArray = ["week","month","year"]
        for index in 0..<3
        {
            let modeBtn: UIButton = UIButton (frame: CGRect (x: buttonWidth * CGFloat(index), y: heightWithoutBtn, width: buttonWidth, height: height * 0.15))
            modeBtn.backgroundColor = UIColor.lightGray
            modeBtn.tag = index
            modeBtn.layer.borderColor = UIColor.white.cgColor
            modeBtn.layer.borderWidth = 0.5
            modeBtn.setTitle(modeTitleArray[index], for: .normal)
            modeBtn.titleLabel?.textColor = UIColor.white
            modeBtn.addTarget(self, action: #selector(modeBtnOnClicked), for: .touchUpInside)
            self.addSubview(modeBtn)
        }
    }
    
    func drawLineWithDatas(datas: Array<Any>) -> Void
    {
        let circlePath = UIBezierPath()
        let pathLine = UIBezierPath()
        pathLine.move(to: CGPoint (x: xLabelWidth / 2 + (xLabelWidth * CGFloat(firstExistIndex)) , y: calculateYVlaue(value: (((datas[firstExistIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!)))
        
        for index in 0..<datas.count
        {
            if datas[index] as? NSNull == NSNull()
            {
                if index == datas.count - 1
                {
                    let lastDashPath = UIBezierPath()
                    let xWidth = (xLabelWidth * CGFloat(index)) + (xLabelWidth / 2)
                    let yValue = calculateYVlaue(value: (((datas[lastExistIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!)
                    lastDashPath.move(to: CGPoint (x: (xLabelWidth * CGFloat(lastExistIndex)) + (xLabelWidth / 2), y: yValue))
                    lastDashPath.addLine(to: CGPoint (x: xWidth, y: yValue))
                    let shaperForDashLine = CAShapeLayer()
                    setLineWithDash(shaperForDashLine, lastDashPath)
                    myScrollView.layer.addSublayer(shaperForDashLine)
                    
                    circlePath.move(to: CGPoint (x: xWidth , y: yValue))
                    circlePath.addArc(withCenter: CGPoint (x: xWidth, y: yValue), radius: 3, startAngle: 0, endAngle: 360, clockwise: true)
                }
                else
                {
                    continue
                }
            }
            else
            {
                let xWidth = (xLabelWidth * CGFloat(index)) + (xLabelWidth / 2)
                let yValue = calculateYVlaue(value: (((datas[index] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!)
                circlePath.move(to: CGPoint (x: xWidth , y: yValue))
                circlePath.addArc(withCenter: CGPoint (x: xWidth, y: yValue), radius: 3, startAngle: 0, endAngle: 360, clockwise: true)
                pathLine.addLine(to: CGPoint (x: xWidth, y: yValue))
            }
        }
        
        // fulfill under color
        pathLine.addLine(to: CGPoint (x: getTotalContentSizeOfWidth() - (xLabelWidth / 2), y: calculateYVlaue(value: (((datas[lastExistIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!)))
        pathLine.addLine(to: CGPoint (x: getTotalContentSizeOfWidth() - (xLabelWidth / 2), y: heightWithoutBtn))
        pathLine.addLine(to: CGPoint (x: 0, y: heightWithoutBtn))
        pathLine.addLine(to: CGPoint (x: 0, y: calculateYVlaue(value: (((datas[firstExistIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!)))
        
        let shaperForLine: CAShapeLayer = CAShapeLayer()
        shaperForLine.path = pathLine.cgPath
        shaperForLine.strokeColor = UIColor.yellow.cgColor
        shaperForLine.lineWidth = 1
        shaperForLine.fillColor = UIColor.white.withAlphaComponent(0.5).cgColor
        myScrollView.layer.addSublayer(shaperForLine)
        
        let shaper: CAShapeLayer = CAShapeLayer()
        shaper.path = circlePath.cgPath
        shaper.strokeColor = UIColor.yellow.cgColor
        shaper.lineWidth = 1
        shaper.fillColor = UIColor.yellow.cgColor
        myScrollView.layer.addSublayer(shaper)
    }
    
    fileprivate func drawCircleWith(index: Int, datas: Array<Any>)
    {
        let pathWithData: UIBezierPath = UIBezierPath()
        var xWidth: CGFloat? = nil
        var value: Float? = nil
        if datas[index] as? NSNull == NSNull()
        {
            for newIndex in index + 1..<datas.count
            {
                if datas[newIndex] as? NSNull != NSNull()
                {
                    value = (((datas[newIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!
                    xWidth = (xLabelWidth * CGFloat(newIndex)) + (xLabelWidth / 2)
                }
            }
            if value == nil
            {
                value = (((datas[lastExistIndex] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!
                xWidth = (xLabelWidth * CGFloat(self.datas.count - 1)) + (xLabelWidth / 2)
            }
        }
        else
        {
            value = (((datas[index] as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)?.floatValue)!
            xWidth = (xLabelWidth * CGFloat(index)) + (xLabelWidth / 2)
        }
        let yValue = calculateYVlaue(value: value!)
        pathWithData.move(to: CGPoint (x: xWidth! , y: yValue))
        pathWithData.addArc(withCenter: CGPoint (x: xWidth!, y: yValue), radius: 5, startAngle: 0, endAngle: 360, clockwise: true)
        let shaper: CAShapeLayer = CAShapeLayer()
        shaper.path = pathWithData.cgPath
        shaper.strokeColor = UIColor.yellow.cgColor
        shaper.lineWidth = 1
        shaper.fillColor = UIColor.yellow.cgColor
        myScrollView.layer.addSublayer(shaper)
    }
    
    // MARK: Common Methods
    
    func setDataSource(_ datas: Array<Any>)
    {
        self.datas = datas
    }
    
    fileprivate func getNeededValue(datas: Array<Any>) -> Void
    {
        let allValue: NSMutableArray = []
        for dic in datas
        {
            if dic as? NSNull == NSNull()
            {
                continue
            }
            allValue.add(((dic as! Dictionary<AnyHashable,Any>)["Value"] as? NSNumber)!)
        }
        maxValue = CGFloat(((allValue.value(forKeyPath: "@max.self")! as? NSNumber)?.floatValue)!)
        minValue = CGFloat(((allValue.value(forKeyPath: "@min.self")! as? NSNumber)?.floatValue)!)
        avgValue = CGFloat(((allValue.value(forKeyPath: "@avg.self")! as? NSNumber)?.floatValue)!)
        unitY = (maxValue - minValue) / 4
        
        for index in 0..<datas.count
        {
            if datas[index] as? NSNull != NSNull()
            {
                firstExistIndex = index
                break
            }
        }
        for index in 0..<datas.reversed().count
        {
            if datas.reversed()[index] as? NSNull != NSNull()
            {
                lastExistIndex = datas.count - (index + 1)
                break
            }
        }
    }
    
    fileprivate func calculateYVlaue(value: Float) -> CGFloat
    {
        let unitHeight = chartHeight / 5
        let totalValue = maxValue - minValue
        let actualHeight = chartHeight - unitHeight
        let actualValue = CGFloat(value) - minValue <= 0 ? 0 : CGFloat(value) - minValue
        let halfUnitHeight = unitHeight / 2
        return (actualHeight - (actualHeight / totalValue * actualValue)) + halfUnitHeight
        
    }
    
    fileprivate func getTotalContentSizeOfWidth() -> CGFloat
    {
        return xLabelWidth * CGFloat(self.datas.count)
    }
    
    fileprivate func cleanAllView()
    {
        for label in self.subviews
        {
            if label is UILabel
            {
                label.removeFromSuperview()
            }
        }
        for subview in myScrollView.subviews
        {
            subview.removeFromSuperview()
        }
        for layer in myScrollView.layer.sublayers ?? []
        {
            layer.removeFromSuperlayer()
        }
    }
    
    fileprivate func setLineWithDash(_ shaperForDashLine: CAShapeLayer, _ lastDashPath: UIBezierPath)
    {
        shaperForDashLine.path = lastDashPath.cgPath
        shaperForDashLine.strokeColor = UIColor.yellow.cgColor
        shaperForDashLine.lineWidth = 1
        shaperForDashLine.lineDashPattern = [2,4]
    }
    
    // MARK:  ChartView Delegate
    
    func modeBtnOnClicked(_ sender: UIButton)
    {
        switch sender.tag
        {
        case 0:
            mode = .week
        case 1:
            mode = .month
        case 2:
            mode = .year
        default:
            break
        }
        cleanAllView()
        delegate?.modeBeenChanged(mode: mode)
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    // MARK: MainScrollView Delegate
    
    func didClickedAt(index: Int)
    {
        drawCircleWith(index: index, datas: self.datas)
    }
}

protocol chartViewDelegate
{
    func modeBeenChanged(mode: chartViewMode)
}

protocol mainScrollViewDelegate
{
    func didClickedAt(index: Int)
}

class mainScrollView: UIScrollView
{
    var myDelegate: mainScrollViewDelegate? = nil
    var xPostionArray: Array<CGFloat>? = nil
    func setDataSource(_ datas: Array<CGFloat>)
    {
        xPostionArray = datas
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let position = touches.first?.location(in: self)
        {
            myDelegate?.didClickedAt(index: getNearestArrayIndexWithX(X: Int(position.x), WithArray: xPostionArray!))
        }
    }
    
    fileprivate func getNearestArrayIndexWithX(X: Int, WithArray array: [CGFloat]) -> Int
    {
        var searchIndex = min((array as NSArray).index(of:Int(X), inSortedRange: NSMakeRange(0, array.count), options: [.firstEqual , .insertionIndex], usingComparator: {(obj1: Any, obj2: Any) -> ComparisonResult in
            return (obj1 as? NSNumber ?? 0).compare((obj2 as? NSNumber ?? 0))
        }), array.count - 1)
        if searchIndex > 0
        {
            let leftHandDiff = labs(Int(Int(array[searchIndex - 1]) - X))
            let rightHandDiff = labs(Int(Int(array[searchIndex]) - X))
            if leftHandDiff >= rightHandDiff
            {
                searchIndex -= 1
            }
            else if leftHandDiff < rightHandDiff
            {
                searchIndex -= 1
            }
        }
        return searchIndex
    }
}
