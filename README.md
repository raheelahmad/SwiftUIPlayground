# SwiftUI Playground

Random experiments with SwiftUI

## Cloth-like

A take on Philip Davis' [cloth effect](https://twitter.com/philipcdavis/status/1550133881168269312).


https://user-images.githubusercontent.com/54114/185269392-c73119a8-fb25-4470-9ae3-3a2487658636.mp4


https://user-images.githubusercontent.com/54114/185269447-8779d7e9-5f16-4376-8308-934243b287c0.mp4



Mine is a little simpler: the deformation function is basically a `lerp` based on the distance from touch.

I also added a view to tweak the many parameters. Even with SwiftUI, having a "runtime" tweaking interface is invaluable. You can save and load the parameters.



https://user-images.githubusercontent.com/54114/185269516-42cab70e-e9b6-4c55-bd25-b3e3966793ae.mp4

