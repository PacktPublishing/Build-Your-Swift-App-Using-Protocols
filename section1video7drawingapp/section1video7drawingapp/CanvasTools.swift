
import UIKit

// A protocol that represents a tool that can be drawn and recieve commands with given points to move to.
protocol DrawingTool : Drawable {
    mutating func start(at point: CGPoint)
    mutating func move(to endPoint: CGPoint)
    mutating func end(at point: CGPoint)
}

// A delegate for the DrawingTool, that gets called upon the tool updating its drawing, or upon the drawing being finalised.
protocol DrawingToolDelegate : class {
    func drawingDidUpdate(_ tool: DrawingTool)
    func drawingDidEnd(tool: DrawingTool, drawable: Drawable)
}

struct PenTool : DrawingTool {
    
    var color: UIColor
    var width: CGFloat
    
    var delegate: DrawingToolDelegate?
    
    init(color: UIColor, width: CGFloat, delegate: DrawingToolDelegate) {
        self.color = color
        self.width = width
        self.delegate = delegate
    }
    
    private var intermediateDrawing = DrawableCollection()
    private var lastPoint: CGPoint?
    
    var frame: CGRect {
        return intermediateDrawing.frame
    }
    
    mutating func start(at point: CGPoint) {
        
        // simply start a pen drawing with a single circle.
        intermediateDrawing = DrawableCollection(elements: [
            Circle(color: color, radius: width / 2, center: point)
            ])
        lastPoint = point
        
        delegate?.drawingDidUpdate(self)
    }
    
    mutating func move(to point: CGPoint) {
        
        // if there's no last point, we can't do anything.
        guard let lastPoint = lastPoint else { return }
        
        // append a new line from the last recorded point to the new point.
        intermediateDrawing.elements.append(
            Line(startPoint: lastPoint, endPoint: point, width: width, color: color)
        )
        
        // update the last point.
        self.lastPoint = point
        
        delegate?.drawingDidUpdate(self)
    }
    
    mutating func end(at point: CGPoint) {
        
        self.lastPoint = point
        
        // pass off the finalised drawing to the delegate.
        delegate?.drawingDidEnd(tool: self, drawable: intermediateDrawing)
        
        // clear the drawing, and inform the delegate that it needs to be redrawn
        // (to remove the currently drawn line)
        intermediateDrawing.elements.removeAll()
        delegate?.drawingDidUpdate(self)
    }
    
    func draw(with renderer: Renderer) {
        // simply pass onto the intermediateDrawing.
        intermediateDrawing.draw(with: renderer)
    }
}

struct RectangleTool : DrawingTool {
    
    var color: UIColor
    var delegate: DrawingToolDelegate?
    
    private var intermediateDrawing: Rectangle?
    private var origin: CGPoint?
    
    var frame: CGRect {
        return intermediateDrawing?.frame ?? .zero
    }
    
    init(color: UIColor, delegate: DrawingToolDelegate) {
        self.color = color
        self.delegate = delegate
    }
    
    mutating func start(at point: CGPoint) {
        origin = point
    }
    
    mutating func move(to endPoint: CGPoint) {
        
        // if there's no starting point, we can't do anything.
        guard let origin = origin else { return }
        
        // set the intermediateDrawing to a new rectangle from the origin to the current point.
        intermediateDrawing = Rectangle(color: color, frame: origin.rectEnclosingLineTo(endPoint))
        delegate?.drawingDidUpdate(self)
    }
    
    mutating func end(at point: CGPoint) {
        
        // if we drew something, pass it back to the delegate and clear it.
        if let drawing = intermediateDrawing {
            delegate?.drawingDidEnd(tool: self, drawable: drawing)
            intermediateDrawing = nil
            delegate?.drawingDidUpdate(self)
        }
        
        origin = nil
    }
    
    func draw(with renderer: Renderer) {
        intermediateDrawing?.draw(with: renderer)
    }
}



