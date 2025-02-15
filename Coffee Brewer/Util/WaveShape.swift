import SwiftUI

struct WaveShape: Shape {
  var progress: Double
  var waveHeight: Double
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let width = rect.width
    let height = rect.height
    let midHeight = height * (1 - progress)
    let wavelength = width / 2
    let amplitude = waveHeight
    
    path.move(to: CGPoint(x: 0, y: height))
    
    stride(from: 0, through: width, by: 1).forEach { x in
      let relativeX = x / wavelength
      let sine = sin(relativeX * 2 * Double.pi)
      let y = midHeight + sine * amplitude
      path.addLine(to: CGPoint(x: x, y: y))
    }
    
    path.addLine(to: CGPoint(x: width, y: height))
    path.closeSubpath()
    
    return path
  }
}
