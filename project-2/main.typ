#import "regression.typ": regression, transpose
#import "cuda.typ": roman
#import "helper.typ": hr
#set page(paper: "a5", margin: 1cm)
#import "@preview/unify:0.5.0": num,qty
#set text(cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#show "。": "．"

/*
= 例
#let x=(19.1, 25.0, 30.1, 36.0, 40.0, 46.5, 50.0)
#let y=(76.30, 77.80, 79.75, 80.80, 82.35, 83.90, 85.10)
#regression(x, y)
#pagebreak()


= 实验

#let x = (10, 15, 20, 25, 30, 35, 40, 45, 50)
#let y = (-0.225, -0.288, -0.319, -0.350, -0.382, -0.445, -0.445, -0.476, -0.445)

#regression(x, y, x_unit: "V", y_unit: [(m$dot$s$#h(0.01cm)^(-2))$])

= 5-1

// 正应力x/Pa
#let x = (26.8, 25.4, 28.9, 23.6, 27.7, 23.9, 24.7, 28.1, 26.9, 27.4, 22.6, 25.6)
// 抗剪强度y/Pa
#let y = (26.5, 27.3, 24.2, 27.1, 23.6, 25.9, 26.3, 22.5, 21.7, 21.4, 25.8, 24.9)
#regression(x, y, x_unit: $"Pa"^(-1)$, y_unit: $"Pa"^(-1)$, estimate: 24.5)
#pagebreak()

= 5-5

#let x = (20.3, 28.1, 35.5, 42.0, 50.7, 58.6, 65.9, 74.9, 80.3, 86.4)
#let y = (416, 386, 368, 337, 305, 282, 258, 224, 201, 183)
#regression(x, y, x_unit: "%", y_unit: sym.degree.c, estimate: 60.0, control: (310, 345))

= 5-7

#let x = (
  5, 10, 15, 20, 25, 30,
)

#let y = (
  (7.28, 8.06, 8.90, 9.98, 10.8, 11.5),
  (7.23, 8.08, 8.97, 9.91, 10.7, 11.8),
  (7.26, 8.15, 9.00, 9.86, 10.8, 11.6),
  (7.25, 8.15, 8.94, 9.84, 11.5, 11.9),
  (7.23, 8.16, 8.94, 9.91, 10.7, 12.2),
)

#regression(x, y, x_unit: "g", y_unit: "cm")
*/

= 第二次大作业

== 原始数据

// 放电量
#let x = (50, 200, 300, 500, 800)
// 电压
#let y = (
  (0.17, 0.16, 0.19, 0.20, 0.19, 0.19, 0.28, 0.23, 0.20),
  (0.31, 0.44, 0.40, 0.34, 0.33, 0.44, 0.38, 0.28, 0.33),
  (0.68, 0.48, 0.65, 0.66, 0.93, 0.64, 0.65, 0.82, 0.62),
  (1.05, 0.88, 0.92, 0.60, 1.02, 1.00, 1.40, 1.15, 1.07),
  (1.93, 1.50, 1.97, 2.30, 1.86, 1.80, 2.00, 1.99, 1.92),
)

#let m = 9

#table(columns: range(m+1).map(_ => auto),
  table.header(
    table.cell(rowspan: 2)[放电量#"\n"$"/pC"$],
    table.cell(colspan: m, align: center)[电压$"/V"$],
    ..range(m).map(x => [#(x+1)])
  ),
  ..y.enumerate().map(group => ([#x.at(group.at(0))], ..group.at(1).map(x => [#x]))).flatten()
  
)

// y 的数据还需要预处理去掉粗大误差

== 粗大误差的剔除
#show "Romanovsky": "罗曼诺夫斯基准则"
#show "3sigma": [$3 sigma$ 准则]

#let alpha = .05
由于重复测量的数据组数小于10，数据不一定符合正态分布，无法使用 3sigma。使用Romanovsky剔除粗大误差。选取显著度水平 $#sym.alpha=#alpha$。

#hr

#let y_ = y
#for (i, (x, group)) in x.zip(y).enumerate() {
  [当放电量为 #qty(x, "pC") 时，]
  let (content, group_) = roman(group, alpha)
  content
  y_.at(i) = group_
  hr
}

// #table(
  #y_.map(x => x.len())
// )

#regression(x, y_, x_unit: "pC", y_unit: "V")
