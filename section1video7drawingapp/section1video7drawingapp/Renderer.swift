
import UIKit

// A protocol that represents a renderer that can recieve drawing commands.
// In this case, the API happens to line up nicely with CGContext, but we could
// have other types conforming to it such that we could completely change the renderers
// that are drawables are drawn with.
protocol Renderer {
    
    var ctm: CGAffineTransform { get }
    
    func concatenate(_ transform: CGAffineTransform)
    
    func addPath(_ cgPath: CGPath)
    
    func saveGState()
    func restoreGState()
    
    func setFillColor(_ color: CGColor)
    func setStrokeColor(_ color: CGColor)
    func setLineCap(_ cap: CGLineCap)
    
    func move(to point: CGPoint)
    func addLine(to point: CGPoint)
    func setLineWidth(_ width: CGFloat)
    
    func fill(_ rect: CGRect)
    
    func strokePath()
    func fillPath(using fillRule: CGPathFillRule)
    
    func draw(_ image: CGImage, in rect: CGRect, byTiling: Bool)
}

extension CGContext : Renderer {}


