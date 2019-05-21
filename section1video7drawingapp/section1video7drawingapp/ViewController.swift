

import UIKit

class ViewController: UIViewController {
    
    // the view we draw on.
    @IBOutlet weak var canvasView: CanvasView!
    
    // the selectors that determine the current tool.
    @IBOutlet weak var colorSelector: UISegmentedControl!
    @IBOutlet weak var toolSelector: UISegmentedControl!
    
    // the corresponding colors to the color selector.
    private let canvasToolColors: [UIColor] = [.red, .blue, .green, .purple, .cyan, .black]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // default tool of red pen with width 5.
        canvasView.currentTool = PenTool(color: .red, width: 5, delegate: canvasView)
    }
    
    @IBAction func canvasToolDidChange(_ sender: Any) {
        
        let color = canvasToolColors[colorSelector.selectedSegmentIndex]
        
        switch toolSelector.selectedSegmentIndex {
        case 0: // pen
            canvasView.currentTool = PenTool(color: color, width: 5, delegate: canvasView)
        case 1: // rectangle
            canvasView.currentTool = RectangleTool(color: color, delegate: canvasView)
        default:
            fatalError("Canvas tool selection beyond bounds.")
        }
    }
    
    @IBAction func undoButtonPressed(_ sender: UIButton) {
        canvasView.undo()
    }
    
    @IBAction func redoButtonPressed(_ sender: UIButton) {
        canvasView.redo()
    }
}

