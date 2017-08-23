
// Necessary imports
import UIKit
import PlaygroundSupport

// Create an view of a given size
let viewRect = CGRect(x: 0, y: 0, width: 200, height: 200)
let view = UIView(frame: viewRect)

// It starts out green
view.backgroundColor = .green

// It animates to blue over three seconds 
// and then prints a message
UIView.animate(withDuration: 3.0, animations: { 
    view.backgroundColor = .blue
}) { (finished) in
    print("Finished!")
}

// Display the view (this will also make 
// the playground run indefinitely, so 
// that we can see the animation
PlaygroundPage.current.liveView = view
