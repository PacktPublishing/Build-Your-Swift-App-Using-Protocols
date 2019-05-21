
import UIKit

/// The Drawable protocol that describes a type that can be drawn in a Renderer.
/// Also has a frame that represents the minimum area that the drawable occupies in space.
protocol Drawable {
    var frame: CGRect { get }
    func draw(with renderer: Renderer)
}

extension Drawable {
    
    /// Draws the given drawable into an image.
    func rasterize(scale: CGFloat) -> DrawableImage? {
        
        let resultantRect = frame
        
        if resultantRect.size == .zero {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(resultantRect.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // offset by the origin such that from the perspective of the drawable, the top
        // left of the context is (0, 0).
        context.translateBy(x: -resultantRect.origin.x, y: -resultantRect.origin.y)
        draw(with: context)
        
        // offset back once done.
        context.translateBy(x: resultantRect.origin.x, y: resultantRect.origin.y)
        
        // attempt to make an image from the context, creating a new DrawableImage
        // if successful, else return nil.
        return context.makeImage().map { DrawableImage(image: $0, frame: resultantRect) }
    }
}

struct Rectangle : Drawable {
    
    var color: UIColor
    var frame: CGRect
    
    func draw(with renderer: Renderer) {
        renderer.setFillColor(color.cgColor)
        renderer.fill(frame)
    }
}

extension CGPoint {
    
    /// Returns the smallest rectangle that encloses both the callee's point and the point
    /// passed as the argument.
    func rectEnclosingLineTo(_ endPoint: CGPoint) -> CGRect {
        return CGRect(x: min(x, endPoint.x), y: min(y, endPoint.y),
                      width: abs(x - endPoint.x), height: abs(y - endPoint.y))
    }
}

struct Line : Drawable {
    
    var color: UIColor
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    
    var width: CGFloat
    var lineCap: CGLineCap
    
    init(startPoint: CGPoint, endPoint: CGPoint, width: CGFloat, color: UIColor, lineCap: CGLineCap = .round) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.width = width
        self.lineCap = lineCap
        self.color = color
    }
    
    var frame: CGRect {
        // get the rectangle enclosing both the start and end points, then increasing the edges by half the width to account for the stroking.
        return startPoint.rectEnclosingLineTo(endPoint).insetBy(dx: -width / 2, dy: -width / 2)
    }
    
    func draw(with renderer: Renderer) {
        renderer.move(to: startPoint)
        renderer.addLine(to: endPoint)
        renderer.setLineWidth(width)
        renderer.setStrokeColor(color.cgColor)
        renderer.setLineCap(lineCap)
        renderer.strokePath()
    }
}

struct Circle : Drawable {
    
    var color: UIColor
    var radius: CGFloat
    var center: CGPoint
    
    var frame: CGRect {
        // for the origin, simply offset the center back by the radius,
        // then the lengths are simply the diameter.
        return CGRect(origin: center.applying(CGAffineTransform(translationX: -radius, y: -radius)),
                      size: CGSize(width: radius * 2, height: radius * 2))
    }
    
    func draw(with renderer: Renderer) {
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        renderer.addPath(path.cgPath)
        renderer.setFillColor(color.cgColor)
        renderer.fillPath(using: .evenOdd)
    }
}

struct DrawableCollection : Drawable {
    
    var elements = [Drawable]()
    
    var frame: CGRect {
        // simply get the first element, then union this rect with the remainder of the elements in order to get the smallest rect that encloses them all, or, if empty, return .zero.
        guard let first = elements.first else {
            return CGRect.zero
        }
        return elements.dropFirst().reduce(first.frame, { $0.union($1.frame) })
    }
    
    func draw(with renderer: Renderer) {
        for element in elements {
            // save and restore the graphics state such that the drawing of one element doesn't interfere with the others.
            renderer.saveGState()
            element.draw(with: renderer)
            renderer.restoreGState()
        }
    }
}

struct DrawableImage : Drawable {
    
    var image: CGImage
    var frame: CGRect
    
    func draw(with renderer: Renderer) {
        renderer.draw(image, in: frame, byTiling: false)
    }
}


