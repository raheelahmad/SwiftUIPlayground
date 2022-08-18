# SwiftUI Playground

Random experiments with SwiftUI

## Cloth-like

A take on Philip Davis' [cloth effect](https://twitter.com/philipcdavis/status/1550133881168269312).

[video1]
[video2]

Mine is a little simpler: the deformation function is basically a `lerp` based on the distance from touch.

I also added a view to tweak the many parameters. Even with SwiftUI, having a "runtime" tweaking interface is invaluable. You can save and load the parameters.

[params video]
