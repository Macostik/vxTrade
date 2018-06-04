//
//  PaginatedView.swift
//  VXTrade
//
//  Created by Yuriy on 1/5/17.
//  Copyright © 2017 VXmarkets. All rights reserved.
//

import UIKit
import SnapKit

class PaginatedView: UIView {
    
    @IBOutlet weak var streamView: StreamView!
    @IBOutlet var circlePageControl: CirclePageControl!
    var dataSource: StreamDataSource<[Card]>!
    var editCardHandling: Block? = nil
    
    class PaginatedDataSource: StreamDataSource<[Card]> {
        
        required init(streamView: StreamView) {
            super.init(streamView: streamView)
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
            let x = targetContentOffset.pointee.x
            let maxX = scrollView.maximumContentOffset.x
            if abs(x - maxX) <= 1 || abs(x) <= 1 {
                return
            }
            let point = CGPoint(x: x, y: scrollView.frame.midY)
            if var item = streamView.itemPassingTest(test: { $0.frame.contains(point) }) {
                if (x - item.frame.origin.x) > item.frame.size.width/2 {
                    if let next = item.next {
                        item = next
                    }
                }
                targetContentOffset.pointee.x = item.frame.origin.x - item.frame.width/4
            }
        }
    }
    
    override func awakeFromNib() {
        streamView.showsHorizontalScrollIndicator = false
        streamView.layout = HorizontalStreamLayout()
        dataSource = PaginatedDataSource(streamView: streamView)
        
        let metrics = StreamMetrics<CardCell>()
        metrics.modifyItem = { item in
            item.insets = CGRect.init(x: 20, y: 0, width: 230, height: 0)
        }
        
        dataSource.addMetrics(metrics: metrics)
        dataSource.didEndDecelerating = {[weak self] in
            guard let `self` = self else { return }
            let page = ceil(self.streamView.contentOffset.x / 250)
            self.circlePageControl.currentPage = Int(page)
        }
        let cards: [Card] = Card().entries()
        self.dataSource.items = cards
        self.circlePageControl.numberOfPages = self.dataSource.items?.count ?? 0
    }
}

class CardCell: EntryStreamReusableView<Card> {
    
    var brandImageView = UIImageView()
    var expireDate = UILabel()
    var nameLabel = UILabel()
    var numberLabel = UILabel()
    
    var editCardHandling: Block? = nil
    @IBAction func editCardClick(sender: AnyObject) {
        editCardHandling?()
    }
    
    override func setup(entry card: Card) {
        brandImageView.image = UIImage(named: "master" + "_icon")
        let number = card.expireYear
        let lastTwo = number.substring(from: number.index(number.endIndex, offsetBy: -2))
        expireDate.text = "\(card.expireMonth)/\(lastTwo)"
        numberLabel.text = card.number
        nameLabel.text = "\(card.firstName) \(card.lastName)"
    }
    
    override func layoutWithMetrics(metrics: StreamMetricsProtocol) {
        super.layoutWithMetrics(metrics: metrics)
        
        add(specify(UIView(), {
            $0.layer.cornerRadius = 5.0
            $0.backgroundColor =  UIColor.white
        })) { (make) in
            make.edges.equalTo(self)
        }
        
       
        add(brandImageView, { (make) in
            make.top.equalTo(self).offset(12)
            make.trailing.equalTo(self).offset(-12)
            make.width.equalTo(50)
            make.height.equalTo(30)
        })
        
        add(specify(Button(), {
            $0.setImage(UIImage(named: "edit_icon"), for: .normal)
        })) { (make) in
            make.leading.equalTo(self).offset(12)
            make.width.equalTo(25)
            make.height.equalTo(10)
            make.centerY.equalTo(brandImageView)
        }
        
        let firstDotView  =  createDotView(with: Color.gray)
        let secondDotView =  createDotView(with: Color.gray)
        let thirdDotView  =  createDotView(with: Color.gray)
        firstDotView.snp.makeConstraints {
            $0.centerY.equalTo(self)
            $0.leading.equalTo(self)
        }
        secondDotView.snp.makeConstraints {
            $0.centerY.equalTo(firstDotView)
            $0.leading.equalTo(firstDotView.snp.trailing).offset(12)
        }
        thirdDotView.snp.makeConstraints {
            $0.centerY.equalTo(secondDotView)
            $0.leading.equalTo(secondDotView.snp.trailing).offset(12)
        }
        
        add(specify(numberLabel, {
            $0.textColor = Color.gray
        }), {
            $0.centerY.equalTo(thirdDotView)
            $0.leading.equalTo(thirdDotView.snp.trailing).offset(12)
        })
        
        add(specify(nameLabel, {
            $0.font = UIFont.systemFont(ofSize: 15)
            $0.textColor = Color.gray
        }), {
            $0.leading.equalTo(self).offset(12)
            $0.bottom.equalTo(self).offset(-12)
        })
        
        add(specify(expireDate, {
            $0.textColor = Color.gray
        }), {
            $0.trailing.equalTo(self).offset(-12)
            $0.bottom.equalTo(self).offset(-12)
        })
        
        add(UIImageView(image: UIImage(named: "valid_icon")), { (make) in
            make.trailing.equalTo(expireDate.snp.leading).offset(-10)
            make.centerY.equalTo(expireDate)
            make.width.equalTo(15)
            make.height.equalTo(10)
        })
    }
}

class CirclePageControl: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.backgroundColor = UIColor.clear
    }
    
    @IBInspectable var numberOfPages: Int = 0 {
        didSet {
            let center = self.center
            self.center = center
            self.currentPage = min(max(0, self.currentPage), numberOfPages - 1)
            self.setNeedsDisplay()
            self.isHidden = false
        }
    }
    
    @IBInspectable var currentPage: Int = 0 {
        willSet {
            if currentPage == newValue {
                return
            }
        }
        didSet {
            currentPage = min(max(0, currentPage), numberOfPages - 1)
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentPageColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var otherPagesColor: UIColor? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var indicatorLength: CGFloat = 4.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var indicatorSpace: CGFloat = 12.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    final override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        context.saveGState()
        context.setAllowsAntialiasing(true)
        
        
        let currentBounds = bounds
        let dotsWidth = CGFloat(numberOfPages) * indicatorLength + CGFloat(max(0, numberOfPages - 1)) * indicatorSpace
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        if frame.height > frame.width {
            x = currentBounds.midX - indicatorLength / 2
            y = currentBounds.midY - dotsWidth / 2
        }else {
            x = currentBounds.midX - dotsWidth / 2
            y = currentBounds.midY - indicatorLength / 2
        }
        
        let drawOnColor: UIColor = (currentPageColor != nil) ? currentPageColor! : UIColor(white: 1.0, alpha: 1.0)
        let drawOffColor: UIColor = (otherPagesColor != nil) ? otherPagesColor! : UIColor(white: 0.7, alpha: 0.5)
        
        for i in 0 ..< numberOfPages {
            
            let dotRect: CGRect = CGRect(x: x, y: y, width: indicatorLength, height: indicatorLength)
            
            if i == self.currentPage {
                context.setFillColor(drawOnColor.cgColor)
                createShapes(inContext: context, forDotRect: dotRect)
            }else{
                context.setFillColor(drawOffColor.cgColor)
                createShapes(inContext: context, forDotRect: dotRect)
            }
            
            if self.frame.height > self.frame.width {
                y += indicatorLength + indicatorSpace
            }else {
                x += indicatorLength + indicatorSpace
            }
        }
        
        context.restoreGState()
    }
    
    func createShapes(inContext context: CGContext, forDotRect dotRect: CGRect) {
        context.fillEllipse(in: dotRect)
    }
    
    fileprivate func sizeForNumberOfPages(_ pageCount: NSInteger) -> CGSize {
        return CGSize(width: max(44.0, indicatorLength + 4.0), height: CGFloat(pageCount) * indicatorLength + CGFloat((pageCount - 1)) * indicatorSpace + 44.0)
    }
}

extension UIView {
    func createDotView(with color: UIColor) -> UIView {
        let dotsView = UIView()
        add(dotsView)
        let firstDot = Label(icon: "l", size: 25, textColor: color)
        dotsView.add(firstDot, {
            $0.leading.top.bottom.equalTo(dotsView)
            $0.size.equalTo(15)
        })
        let secondDot = Label(icon: "l", size: 25, textColor: color)
        dotsView.add(secondDot, {
            $0.leading.equalTo(firstDot.snp.trailing).offset(-5)
            $0.centerY.equalTo(firstDot)
            $0.width.equalTo(firstDot)
        })
        let thirdDot = Label(icon: "l", size: 25, textColor: color)
        dotsView.add(thirdDot, {
            $0.leading.equalTo(secondDot.snp.trailing).offset(-5)
            $0.centerY.equalTo(secondDot)
            $0.width.equalTo(secondDot)
            
        })
        let fourthDot = Label(icon: "l", size: 25, textColor: color)
        dotsView.add(fourthDot, {
            $0.leading.equalTo(thirdDot.snp.trailing).offset(-5)
            $0.centerY.equalTo(thirdDot)
            $0.width.equalTo(thirdDot)
            $0.trailing.equalTo(dotsView)
        })
        return dotsView
    }
}




