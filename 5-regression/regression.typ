#import "@preview/unify:0.5.0": num,qty,numrange,qtyrange

#let hr = line(stroke: black.lighten(70%), length: 100%)
#let c = x => calc.round(x, digits: 3)

#let regression = (x, y, x_unit: "", y_unit: "", estimate: none, control: none) => {
// = 一元线性回归
assert(x.len() == y.len())
let N = x.len()

[== 原始数据]

table(
  columns: (.8cm, ..range(N).map(x => 1fr)),
  table.header("N", ..range(N).map(x => [#(x+1)])),
  $x$, ..x.map(x => [#x]),
  $y$, ..y.map(y => [#y]),
)

[== 回归方程的确定]

let DS = $sum^N_(t=1)$
let XU = x_unit
let XU2 = ""
let YU = y_unit
let YU2 = ""
let XYU = []
let YXU = []
if XU != "" {
  XU2 = $XU^2$
  XYU += XU
  YXU += "/" + XU
}
if YU != "" {
  YU2 = $#y_unit^2$
  if XU != "" {
    XYU += $dot.c$
  }
  XYU += YU
  YXU = YU + YXU
}

// 计算x的均值
let sum_x = x.sum()

let x_avg = sum_x / N
$ DS x_t = #sum_x XU, overline(x) = #c(x_avg) XU $

// 计算x的平方的平均值
let x_sq = x.map(x => calc.pow(x, 2))
let sum_x_sq = x_sq.sum()
let x_sq_avg = calc.pow(sum_x, 2) / N
$ DS x_t^2 = #c(sum_x_sq) XU2, quad (DS x_t)^2 / N = #c(x_sq_avg) XU2 $


let l_xx = sum_x_sq - x_sq_avg

$ l_(x x) = DS x_t^2 - (DS x_t)^2 / N = #c(l_xx) XU2 $

hr

// 计算y的均值
let sum_y = y.sum()

let y_avg = sum_y / N
$ DS y_t = #sum_y YU, overline(y) = #y_avg YU $

// 计算y的平方的平均值
let y_sq = y.map(y => y*y)
let sum_y_sq = y_sq.sum()

let y_sq_avg = calc.pow(sum_y, 2) / N
$ DS y_t^2 = #c(sum_y_sq) YU2, quad (DS y_t)^2 / N = #c(y_sq_avg) YU2 $

let l_yy = sum_y_sq - y_sq_avg

$ l_(y y) = DS y_t^2 - (DS y_t)^2 / N = #c(l_yy) YU2 $

hr

let sum_xy = x.zip(y).map(((x, y)) => x * y ).sum()
let xy_sum_avg = (sum_x * sum_y) / N
$ DS x_t y_t = #c(sum_xy) XYU, quad ((DS x_t)(DS y_t)) / N = #c(xy_sum_avg) XYU $

let l_xy = sum_xy - xy_sum_avg
$ l_(x y) = DS x_t y_t - ((DS x_t)(DS y_t)) / N = #c(l_xy) XYU $

[=== 计算 $b$ 和 $b_0$]

let b = l_xy / l_xx
$ b = l_(x y) / l_(x x) = #b YXU $

let b_0 = y_avg - b * x_avg
$ b_0 = overline(y) - b overline(x) = #c(b_0) YU $

[最终的回归直线为]

$ hat(y) = #b_0 YU + (#b YXU) x $

[== 方差分析]

let S = l_yy
let U = calc.pow(l_xy, 2) / l_xx
let Q = S - U

[
/ 总离差平方和: $ S = DS (y_t - overline(y))^2 = l_(y y) = #c(S) YU2. $
/ 回归平方和: $ U = DS (hat(y)_t - overline(y))^2 = b l_(x y) = l_(x y)^2 / l_(x x) = #c(U) YU2. $
/ 残余平方和: $ Q = l_(y y) - b l_(x y) = S - U = #c(Q) YU2. $

== 显著性检验

=== $bold(F)$ 检验
]
let v_U = 1
let v_Q = N - 2
let F = calc.round((U/v_U)/(Q/v_Q), digits: 2)

$
F =& (U "/" v_U) / (Q "/" v_Q)
  = (U "/" 1) / (Q "/" (N - 2)) \
  =& #c(U) / (#c(Q) "/" #v_Q) \
  =& #c(F).
$

[
== 方差分析表
]

let sigma2 = Q / (N - 2)

table(
  align: center,
  columns: (auto, auto, auto, auto, 1fr, auto),
  table.header([来源], [平方和], [自由度], [方差], $F$, [显著性水平]),
  [回归], $U = #c(U)$, $#v_U$, table.cell(rowspan: 2, $
  sigma^2 &= Q / (N - 2)\
  &= #c(sigma2)
  $), table.cell(rowspan: 2, $#F$), table.cell(rowspan: 2, $alpha = 0.01$),
  [残余], $Q = #c(Q)$, $#v_Q$,
  [总计], $S = #c(S)$, $#(v_Q + v_U)$, [#line(length: 1em)], [#line(length: 1em)], [#line(length: 1em)]
) 

let sigma_ = calc.sqrt(sigma2)
/* 在定点的值 */
if estimate != none { 
  [
    == 预测问题
    当 $x_0 = estimate$ 时，有
  ]
  let y_0 = b_0 + b * estimate
  $ y_0 = #c(b_0) + (#c(b)) times estimate = #c(y_0) $
  $ sqrt(Q / (N - 2)) = #c(sigma_) $
  if N > 90 { 
    [因 $alpha$ = 0.05，查附表 2.1 正态分布表可得 $Z_alpha approx 1.95$，得到]
    let d = 1.95 * sigma_
    $ d = 1.95 times sigma = #c(d) $
    [$y_0$ 的 95% 近似预测区间为 $(#c(y_0 - d), #c(y_0 + d)).$]
  } else {
    let t = 2.31
    [查附表2.3可得 $t_alpha (N-2)= #t.$]
    let d = t * sigma_ * calc.sqrt(1 + 1/N + calc.pow(estimate - x_avg, 2) / l_xx)
    $ delta(x_0) = t_alpha (N-2) sigma sqrt(1 + 1/N + (x_0 - overline(x))^2/l_(x x)) = #c(d). $
    [即预测水平为0.95的区间为 $(#c(y_0 - d), #c(y_0 + d))$．]
  }
}

if control != none {
  let (y01, y02) = control
  [
    == 控制问题
    $ y_"0 1" = y01, y_"0 2" = y02, $
  ]
  $ cases(
    x_1 = 1/b ((y_0)_1 - b_0 plus/* .minus */ Z_alpha sqrt(Q/(N-2))),
    x_2 = 1/b ((y_0)_2 - b_0 minus/* .plus */ Z_alpha sqrt(Q/(N-2)))
  ) $
  if b > 0 {
    $ b > 0, x_1 > x > x_2, $
  } else {
    $ b < 0, x_1 < x < x_2, $
  }
  let Z = 1.95
  let x1 = 1/b*(y01 - b_0 + Z * sigma_)
  let x2 = 1/b*(y02 - b_0 - Z * sigma_)
  [其中 $x_1 = x1, x_2 = x2.$]
}
}
