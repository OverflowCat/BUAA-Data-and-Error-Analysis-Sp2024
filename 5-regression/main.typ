#set page(paper: "a5")
#set text(lang: "zh", cjk-latin-spacing: auto)
#let hr = line(stroke: black.lighten(70%), length: 100%)
#let c = x => calc.round(x, digits: 3)

= 一元线性回归

#let x=(19.1, 25.0, 30.1, 36.0, 40.0, 46.5, 50.0)
#let y=(76.30, 77.80, 79.75, 80.80, 82.35, 83.90, 85.10)

#assert(x.len() == y.len())

#let N = x.len()

== 原始数据

#table(
  columns: (.8cm, ..range(N).map(x => 1fr)),
  table.header("N", ..range(N).map(x => [#(x+1)])),
  $x$, ..x.map(x => [#x]),
  $y$, ..y.map(y => [#y]),
)

== 回归方程的确定

#let DS = $sum^N_(t=1)$

// 计算x的均值
#let sum_x = x.sum()

#let x_avg = sum_x / N
$ DS x_t = #sum_x, overline(x) = #x_avg $

// 计算x的平方的平均值
#let x_sq = x.map(x => calc.pow(x, 2))
#let sum_x_sq = x_sq.sum()

$ DS x_t^2 = #sum_x_sq, (DS x_t)^2 / N = #sum_x_sq $

#let x_sq_avg = calc.pow(sum_x, 2) / N

#let l_xx = sum_x_sq - x_sq_avg

$ l_(x x) = DS x_t^2 - (DS x_t)^2 / N = #l_xx $

#hr

// 计算y的均值
#let sum_y = y.sum()

#let y_avg = sum_y / N
$ DS y_t = #sum_y, overline(y) = #y_avg $

// 计算y的平方的平均值
#let y_sq = y.map(y => y*y)
#let sum_y_sq = y_sq.sum()

$ DS y_t^2 = #sum_y_sq, (DS y_t)^2 / N = #sum_y_sq $

#let y_sq_avg = calc.pow(sum_y, 2) / N

#let l_yy = sum_y_sq - y_sq_avg

$ l_(y y) = DS y_t^2 - (DS y_t)^2 / N = #l_yy $

#hr

#let sum_xy = x.zip(y).map(((x, y)) => x * y ).sum()
#let xy_sum_avg = (sum_x * sum_y) / N
$ DS x_t y_t = #sum_xy, ((DS x_t)(DS y_t)) / N = #xy_sum_avg $

#let l_xy = sum_xy - xy_sum_avg
$ l_(x y) = DS x_t y_t - ((DS x_t)(DS y_t)) / N = #l_xy $

=== 计算 $b$ 和 $b_0$

#let b = l_xy / l_xx
$ b = l_(x y) / l_(x x) = #b $

#let b_0 = y_avg - b * x_avg
$ b_0 = overline(y) - b overline(x) = #b_0 $

最终的回归直线为

$ hat(y) = #b_0 + #b x $

== 方差分析

#let S = l_yy
#let U = calc.pow(l_xy, 2) / l_xx
#let Q = S - U

/ 总离差平方和: $ S = DS (y_t - overline(y))^2 = l_(y y) = #c(S). $
/ 回归平方和: $ U = DS (hat(y)_t - overline(y))^2 = b l_(x y) = l_(x y)^2 / l_(x x) = #c(U). $
/ 残余平方和: $ Q = l_(y y) - b l_(x y) = S - U = #c(Q). $

== 显著性检验

=== $bold(F)$ 检验

#let v_U = 1
#let v_Q = N - 2
#let F = calc.round((U/v_U)/(Q/v_Q), digits: 2)

$
F =& (U "/" v_U) / (Q "/" v_Q)
  = (U "/" 1) / (Q "/" (N - 2)) \
  =& #c(U) / (#c(Q) "/" #v_Q) \
  =& #c(F).
$

== 方差分析表

#table(
  align: center,
  columns: (auto, auto, auto, 1fr, 1fr, auto),
  table.header([来源], [平方和], [自由度], [方差], $F$, [显著性水平]),
  [回归], $U = #c(U)$, $#v_U$, table.cell(rowspan: 2, $sigma^2$), table.cell(rowspan: 2, $#F$), table.cell(rowspan: 2, $alpha = 0.01$),
  [残余], $Q = #c(Q)$, $#v_Q$,
  [总计], $S = #c(S)$, $#(v_Q + v_U)$, [#line(length: 1em)], [#line(length: 1em)], [#line(length: 1em)]
)
