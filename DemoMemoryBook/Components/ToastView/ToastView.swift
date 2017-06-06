//
//  ToastView.swift
//  DemoMemoryBook
//
//  Created by Denis Senichkin on 5/26/17.
//  
//

import UIKit

typealias finishedLoadBlock = (() -> ())

let kToastViewTag = 1860
let kIndicatorColor: UIColor = .lightGray
let kWindowView = UIApplication.shared.keyWindow!
let kDuration = 0.3

class ToastView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkMarkView: CheckMarkView!
    @IBOutlet weak var circleIndicatorView: CircleIndicatorView!
    
    private class func loadFromNib() -> ToastView {
        let obj = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)
        let view = obj?.first as! ToastView
        view.setup()
        return view
    }
    
    private func setup() {
        tView.layer.cornerRadius = 5
        tView.clipsToBounds = true
        circleIndicatorView.isHidden = false
        checkMarkView.isHidden = true
    }
    
    public class func show(text: String?) {
        
        if (kWindowView.viewWithTag(kToastViewTag) != nil) {
            return
        }
        
        let view = ToastView.loadFromNib()
        view.tag = kToastViewTag
        view.label.text = text

        view.alpha = 0
        kWindowView.addSubview(view)
        
        UIView.animate(withDuration: kDuration, animations: {
            view.alpha = 1
        })
    }

    public class func hide(fBlock: finishedLoadBlock?) {
        
        if let view = kWindowView.viewWithTag(kToastViewTag) as? ToastView {
            
            let indicator = view.viewWithTag(10) as! CircleIndicatorView
            let checkMark = view.viewWithTag(20) as! CheckMarkView
            
            UIView.transition(with: checkMark, duration: kDuration, options: .transitionCrossDissolve, animations: {
                indicator.isHidden = true
                checkMark.isHidden = false
            })
            
            UIView.animate(withDuration: kDuration, delay: 0.5, animations: {
                view.alpha = 0
            }, completion: { (finished) in
                view.removeFromSuperview()
                if let block = fBlock {
                    block()
                }
            })
        }
    }
    
    public class func hide() {
        ToastView.hide(fBlock: nil)
    }
    
}

//MARK : - CircleIndicatorView

class CircleIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
        spinLayer(layer: self.layer, duration: 1, direction: 1)
    }
    
    func spinLayer(layer: CALayer, duration: CFTimeInterval, direction: Int) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Float.pi * 2.0 * Float(direction))
        rotation.duration = duration
        rotation.repeatCount = 100000
        layer.add(rotation, forKey: "rotationAnimation")
    }
    
    override func draw(_ rect: CGRect) {
        let bounds = self.bounds
        let lineWidth: CGFloat = 2.0
        let radius = bounds.size.width / 2 - lineWidth
        
        let ctx = UIGraphicsGetCurrentContext()!
        
        var center = CGPoint()
        center.x = bounds.origin.x + bounds.size.width / 2.0
        center.y = bounds.origin.y + bounds.size.height / 2.0
        ctx.saveGState()
        
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(kIndicatorColor.cgColor)
        ctx.addArc(center: center, radius: radius , startAngle: 0.0, endAngle: CGFloat(Float.pi * 2.0 + 0.4), clockwise: true)
        ctx.strokePath()
    }
}

//MARK : - CheckMarkView

class CheckMarkView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let bounds = self.bounds
        let lineWidth: CGFloat = 2.0
        
        let aPath = UIBezierPath()
        aPath.lineWidth = lineWidth
        aPath.move(to: CGPoint(x: lineWidth, y: bounds.height / 2))
        aPath.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height - lineWidth))
        aPath.addLine(to: CGPoint(x: bounds.width - lineWidth, y: lineWidth))
        kIndicatorColor.set()
        aPath.stroke()
    }
}

