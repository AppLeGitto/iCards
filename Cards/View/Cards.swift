//
//  Cards.swift
//  Cards
//
//  Created by Марк Кобяков on 05.05.2022.
//
import UIKit

protocol FlippableView: UIView {
    var isFlipped: Bool {get set}
    var flipCompletionHandler: ((FlippableView) -> Void)? {get set}
    func flip()
}

class CardView<ShapeType: ShapeLayerProtocol>: UIView, FlippableView {
    var isFlipped: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var flipCompletionHandler: ((FlippableView) -> Void)?
    var color: UIColor!
    var cornerRadius = 20
    private var anchorPoint: CGPoint = CGPoint(x: 0, y: 0)
    private var startTouchPoint: CGPoint!
    private var indentStartTouchPoint: CGFloat = 1
    private let margin: Int = 1
    
    lazy var frontSideView: UIView = getFrontSideView()
    lazy var backSideView: UIView = getBackSideView()
    
    init(frame: CGRect, color: UIColor) {
        super.init(frame: frame)
        self.color = color
        
        setupBorders()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        backSideView.removeFromSuperview()
        frontSideView.removeFromSuperview()
        
        if isFlipped {
            self.addSubview(backSideView)
            self.addSubview(frontSideView)
        } else {
            self.addSubview(frontSideView)
            self.addSubview(backSideView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        anchorPoint.x = touches.first!.location(in: window).x - frame.minX
        anchorPoint.y = touches.first!.location(in: window).y - frame.minY
        
        startTouchPoint = frame.origin
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.frame.origin.x = touches.first!.location(in: window).x - anchorPoint.x
        self.frame.origin.y = touches.first!.location(in: window).y - anchorPoint.y
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (startTouchPoint.x - indentStartTouchPoint...startTouchPoint.x + indentStartTouchPoint).contains(self.frame.origin.x) && (startTouchPoint.y - indentStartTouchPoint...startTouchPoint.y + indentStartTouchPoint).contains(self.frame.origin.y) {
            flip()
        }
    }
    
    func flip() {
        let fromView = isFlipped ? frontSideView : backSideView
        let toView = isFlipped ? backSideView : frontSideView
        
        UIView.transition(from: fromView, to: toView, duration: 0.5, options: [.transitionFlipFromLeft]) { _ in
            self.flipCompletionHandler?(self)
        }
        
        isFlipped.toggle()
    }
    
    private func getFrontSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        let shapeView = UIView(frame: CGRect(x: margin, y: margin, width: Int(self.bounds.width) - margin*2, height: Int(self.bounds.height) - margin*2))
        view.addSubview(shapeView)
        
        let shapeLayer = ShapeType(size: shapeView.frame.size, fillColor: color.cgColor)
        shapeView.layer.addSublayer(shapeLayer)
        
        return view
    }
    
    private func getBackSideView() -> UIView {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .white
        
        view.layer.masksToBounds = true
        view.layer.cornerRadius = CGFloat(cornerRadius)
        
        switch ["circle", "line"].randomElement()! {
        case "circle":
            let layer = BackSideCircle(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        case "line":
            let layer = BackSideLine(size: self.bounds.size, fillColor: UIColor.black.cgColor)
            view.layer.addSublayer(layer)
        default:
            break
        }
        
        return view
    }
    
    private func setupBorders() {
        self.layer.cornerRadius = CGFloat(cornerRadius)
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.black.cgColor
    }
}
