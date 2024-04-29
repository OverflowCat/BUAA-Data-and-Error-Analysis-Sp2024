#set page(paper: "a5")

#let x=(19.1, 25.0, 30.1, 36.0, 40.0, 46.5, 50.0)
#let y=(76.30, 77.80, 79.75, 80.80, 82.35, 83.90, 85.10)

#assert(x.len() == y.len())

#let N = x.len()

#table(
  columns: range(N + 1).map(x => auto),
  table.header("N", ..range(N).map(x => [#(x+1)])),
  $x$, ..x.map(x => [#x]),
  $y$, ..y.map(y => [#y]),
)

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

#let sum_y = y.sum()
#let y_avg = sum_y / N
#let y_sq = y.map(y => y*y)
#let sum_y_sq = y_sq.sum()
#let y_sq_avg = calc.pow(sum_y, 2) / N
#let l_yy = sum_y_sq - y_sq_avg

$ l_(y y) = #l_yy $

#let sum_xy = x.zip(y).map(((x, y)) => x * y ).sum()
#let xy_sum_avg = (sum_x * sum_y) / N
$ DS x_t y_t = #sum_xy, ((DS x_t)(DS y_t)) / N = #xy_sum_avg $

#let l_xy = sum_xy - xy_sum_avg
$ l_(x y) = DS x_t y_t - ((DS x_t)(DS y_t)) / N = #l_xy $

== 计算 $b$ 和 $b_0$

#let b = l_xy / l_xx
$ b = l_(x y) / l_(x x) = #b $

#let b_0 = y_avg - b * x_avg
$ b_0 = overline(y) - b overline(x) = #b_0 $

最终的回归直线为

$ hat(y) = #b_0 + #b x $
