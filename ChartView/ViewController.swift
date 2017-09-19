//
//  ViewController.swift
//  ChartView
//
//  Created by ZhengWeiLi on 2017/9/12.
//  Copyright © 2017年 sss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, chartViewDelegate
{

    let myChartView: chartView = chartView()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 233/255, green: 123/255, blue: 156/255, alpha: 1)
        myChartView.frame = CGRect.init(x: 0, y: 100, width: self.view.frame.size.width, height: 300)
        self.view.addSubview(myChartView)
        myChartView.setDataSource(createFakeDatas(count: 10))
        myChartView.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func modeBeenChanged(mode: chartViewMode)
    {
        print(mode)
        switch mode
        {
        case .week:
            myChartView.setDataSource(createFakeDatas(count: 10))
        case .month:
            myChartView.setDataSource(createFakeDatas(count: 53))
        case .year:
            myChartView.setDataSource(createFakeDatas(count: 90))
        }
    }
    
    func createFakeDatas(count: Int) -> Array<Any>
    {
        var array: Array<Any> = []
        for index in 0..<count
        {
            let arcValue: Float = Float(arc4random()%99)
            let currentTimeStamp = Date().timeIntervalSince1970
            let date: Date = Date.init(timeIntervalSince1970: currentTimeStamp + (Double(index) * 36400 * 30))
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "yyyy/MM"
            if index == 0 || index == count - 2 || index == count - 1
            {
                array.append(NSNull())
            }
            else
            {
                array.append(["Value":arcValue,"Date":dateFormatter.string(from: date)])
            }
        }
        return array
    }
}

