
import UIKit

extension CALayer {
    
    // Convenience initialiser for creating a new CALayer with the contents of a
    // rasterized Drawable at a given scale.
    convenience init?(rasterizing drawable: Drawable, scale: CGFloat) {
        
        guard let rasterized = drawable.rasterize(scale: scale) else { return nil }
        
        self.init()
        
        frame = rasterized.frame
        contentsScale = scale
        contents = rasterized.image
    }
}

class RenderingView : UIView {
    
    // the data source here is a closure rather than a delegate
    // for increased flexibility (and to show off both approaches in this project).
    var dataSource: () -> Drawable? = { nil }
    
    init(dataSource: @escaping () -> Drawable? = { nil }) {
        self.dataSource = dataSource
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        // simply attempt to get the drawable from the data source, and draw it
        // to the current context.
        dataSource()?.draw(with: UIGraphicsGetCurrentContext()!)
    }
}

class CanvasView : UIView, DrawingToolDelegate {
    
    // the view that displays the "already drawn" drawables.
    private let contentView = UIView()
    
    // the view that renders the current drawing.
    private let toolRenderingView = RenderingView()
    
    // a stack of layers that can be undone and redone.
    private var drawableElements = UndoRedoStack<CALayer>()
    
    // the current tool that the view is drawing with.
    var currentTool: DrawingTool?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        
        // clip the content view's sublayers to its bounds
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        // ensure self is captured weakly to prevent a retain cycle.
        toolRenderingView.dataSource = { [weak self] in self?.currentTool }
        
        // not opaque, as it's an overlay over the contentView.
        toolRenderingView.isOpaque = false
        addSubview(toolRenderingView)
    }
    
    override func layoutSubviews() {
        // ensure the two subviews always have the same frame as the view's bounds.
        contentView.frame = bounds
        toolRenderingView.frame = bounds
    }
    
    func drawingDidUpdate(_ tool: DrawingTool) {
        // redraw the current tool upon it being updated.
        toolRenderingView.setNeedsDisplay()
    }
    
    func drawingDidEnd(tool: DrawingTool, drawable: Drawable) {
        
        // rasterise the finished drawing, and add it to the contentView layer heirarcy,
        // as well as the drawableElements stack.
        guard let layer = CALayer(rasterizing: drawable, scale: UIScreen.main.scale) else { return }
        
        contentView.layer.addSublayer(layer)
        drawableElements.push(layer)
    }
    
    func undo() {
        if let layer = drawableElements.undoPush() {
            layer.removeFromSuperlayer()
        }
    }
    
    func redo() {
        if let layer = drawableElements.redoPush() {
            contentView.layer.addSublayer(layer)
        }
    }
    
    // simply forward touch methods onto tool...
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        currentTool?.start(at: touchLocation)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        currentTool?.move(to: touchLocation)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        currentTool?.end(at: touchLocation)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}


