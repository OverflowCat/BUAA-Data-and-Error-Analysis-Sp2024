#import "regression.typ": regression
#set page(paper: "a5")
#set text(lang: "zh", cjk-latin-spacing: auto)

/*
= 例
#let x=(19.1, 25.0, 30.1, 36.0, 40.0, 46.5, 50.0)
#let y=(76.30, 77.80, 79.75, 80.80, 82.35, 83.90, 85.10)
#regression(x, y)
#pagebreak()

= 5-1

// 正应力x/Pa
#let x = (26.8, 25.4, 28.9, 23.6, 27.7, 23.9, 24.7, 28.1, 26.9, 27.4, 22.6, 25.6)
// 抗剪强度y/Pa
#let y = (26.5, 27.3, 24.2, 27.1, 23.6, 25.9, 26.3, 22.5, 21.7, 21.4, 25.8, 24.9)
#regression(x, y, estimate: 24.5)
#pagebreak()
*/

= 5-5

#let x = (20.3, 28.1, 35.5, 42.0, 50.7, 58.6, 65.9, 74.9, 80.3, 86.4)
#let y = (416, 286, 368, 337, 305, 282, 258, 224, 201, 183)
#regression(x, y, x_unit: "%", y_unit: sym.degree.c)
