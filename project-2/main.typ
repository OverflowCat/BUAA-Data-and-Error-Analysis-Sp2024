#import "./regression.typ": regression, transpose
#import "./cuda.typ": roman
#import "./helper.typ": hr, r0
#import "./vendor/lib.typ": round
#import "./private.typ": *
#import "@preview/pinit:0.1.4": *
#import "@preview/unify:0.5.0": num, qty
#set text(lang: "zh", cjk-latin-spacing: auto, font: "Noto Serif CJK SC")
#show heading.where(level: 1): set text(font: "Noto Sans CJK SC", size: 1.2em)
#show heading.where(level: 2): set text(size: 1.1em)
#show "。": "．"
#show heading.where(level: 3): set text(font: "Noto Sans CJK SC", size: 1.05em)
#show "Romanovsky": "罗曼诺夫斯基准则"
#show "3sigma": [$3 sigma$ 准则]

#import "@preview/touying:0.4.0": *
#let s = themes.metropolis.register(aspect-ratio: "16-9")
#let s = (s.methods.info)(
  self: s,
  title: [局部放电检测系统的数据分析和处理],
  subtitle: [*误差理论与数据处理* 第二次讨论课],
  author:   author_info,
  date: datetime(
    year: 2024,
    month: 5,
    day: 14,
  ),
  institution: [北京航空航天大学],
  toc: none
)

#let (init, slides, touying-outline) = utils.methods(s)
#show: init

#let (slide, empty-slide) = utils.slides(s)
#show: slides

// = 第二次大作业

== 选题依据及理由

局部放电普遍存在于变压器、电力电缆、开关柜、等电力设备的运行过程中，设备的局部放电会伴随各种电、光、声等复杂的现象。而电气设备绝缘故障早期阶段通常表现为局部放电，对局部放电进行实时在线检测，尽早识别并能迅速准确找到局部放电发生位置是保障电力设备乃至电网安全运行所迫切需要解决的问题。

#figure(caption: "电力电缆绝缘故障引发火灾",
  stack(
    image("./fire-1.png", height: 8cm),
    image("./fire-2.jpg", height: 8cm),
    dir: ltr,
    spacing: .2cm
  )
)

按照实现的技术手段和检测方法的基本原理进行分类，局部放电的检测方法分为直接法和间接法。直接法的理论基础是经典电路理论，如脉冲电流法，间接法就是基于以上物理现象逐渐衍生出的多种局部放电检测方法，如化学法、光学法、电磁法、声波法、热扫描法和测温法等，常用的局部放电检测方法特性如@comparison 所示。

#import "@preview/tablem:0.1.0": tablem
#figure(
  caption: "局部放电检测方法特性比较",
  tablem[
  | *检测方法*
 | *优点* | *缺点* | *可达精度* | *实际应用* |
|---|---|---|---|---|
| 脉冲电流检测法 | 方法简单，灵敏度高 | 不能在线检测 | 5 pC | 早期应用较多 |
| 超高频法 | 灵敏度高，在线检测 | 造价高 | $0.5"~  "#qty(0.8, "pC")$ | 应用多 |
| 超声波 | 不受电磁干扰 | 信号衰减大，距离有限 | $<#qty(2, "pC")$ | 应用多 |
| 化学法 | 不受电磁干扰 | 灵敏度差，不能长时间监测 | 差 | 极少应用 |
| 光检测法 | 不受电磁干扰 | 灵敏度差，需多个传感器 | 差 | 极少应用 |
]
)<comparison>

/*
常见的局部放电检测方式有：
- 脉冲电流法
- 超高频检测法
- 介质损耗分析法
- 无线电干扰电压法
- 局部放电光纤传感检测法
*/

脉冲电流法通过检测局部放电在接地线上产生的电流来检测局部放电，能及时发现电力设备的缺陷；可以评估缺陷损坏程度；校准方法比较有效，能对局部放电定量分析。

根据脉冲电流法测局部放电，可以得到放电量与电压的关系。但是其中会存在误差需要修正，我们选择这个题目分析误差源并且得到更精准的测量方案。

== 测量方案
 
#let scheme = image("./diagram.png", height: 80%)
#figure(caption: "局部放电测试系统框图", scheme)

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
  ..y.enumerate().map(group => ([#x.at(group.at(0))], ..group.at(1).map(x => r0(x)))).flatten()
  
)

// y 的数据还需要预处理去掉粗大误差

== 粗大误差的剔除

#let alpha = .05
由于重复测量的数据组数小于10，数据不一定符合正态分布，无法使用 3sigma。

使用Romanovsky剔除粗大误差。选取显著度水平 $#sym.alpha=#alpha$。

每组数据都是等精度独立测量。

#"\n\n"

#hr

#let y_ = y
#for (i, (x, group)) in x.zip(y).enumerate() {
  [当放电量为 #qty(x, "pC") 时，]
  let (content, group_) = roman(group, alpha)
  content
  y_.at(i) = group_
  hr
}

== 剔除粗大误差后的数据

#table(
  columns: range(m+1).map(_ => 1fr),
  table.header("N", ..range(m).map(x => [#(x+1)])),
  ..x.zip(y_).map(((x, g)) => {
    let cells = g.map(c => r0(c) + " V")
    for i in range(m - g.len()) {
      cells.push(table.cell(align: center, line(length: 3.5em, angle: 14deg)))
    }
    (table.cell([#x pC], align: right), ..cells)
  }).flatten()
)

#regression(
  x,
  y_,
  x_unit: "pC",
  y_unit: $upright(V)$ // https://github.com/typst/typst/issues/366#issuecomment-1868963477
)

== 误差源分析

#scheme

#pagebreak()

=== 传感器导致的误差
  - 由于在放电过程中存在放热现象，传感器并不能工作在稳定的环境内，由于温度变化，传感器温漂将会带来误差。
  - 如果传感器的响应时间较慢，测得的电压值会小于局部放电的瞬时的电压峰值。
  - 如果传感器的分辨力不足，将会导致测量值的精确度不够，使得误差增大。
=== 数据传输和存储造成的误差
  - RS485/232作为串口通信的功能，若没有选择校验方式，则接收到的数据流可能会因噪声、干扰、失真或比特同步错误而使流中的某一个或几个比特翻转。
  #figure(caption: "RS485/232通信模块", image("./rs.jpg", width: 70%))
  - 未使用 ECC 的 SRAM 存储器也有可能发生比特翻转，导致数据错误。
  #figure(caption: "SRAM存储器的可能的比特错误发生方式", image("./sram-bit-error-e.svg", width: 61%))

=== 放大器及滤波电路模块

由于环境中的电磁干扰带来的噪声影响，如果滤波器并未完全消除噪声，放大器将会增大噪声对于所测数据的影响，导致误差增大。

=== ADC模数转换器

在采样过程中，由于采样频率低，采样周期长，对于电压信号的测量范围的覆盖不够全面，也会导致测量不到电压峰值，使测量值偏低。

=== 环境因素带来的误差

环境条件由于放电过程所伴随的电、声、光、热等现象，会持续改变，由此导致环境因素的不稳定，系统将会受到影响，使得误差增大。

== 系统精度提高方案

=== 选择合适的校验方式

奇偶校验能够检测出信息传输过程中的部分误码（1位误码能检出，2位及2位以上误码不能检出），使用简单，同时，它不能纠错。在发现错误后，只能要求重发。CRC循环冗余校验。检错和纠错能力强，可以用于实现差错控制。

=== 改进采样方式

根据 Nyquist 采样定理，为了正确地重构一个信号，采样频率应至少为信号最高频率的两倍。如果采样频率低于这个标准，就会发生欠采样。因此，对于 ADC，可以增大采样频率，增大采样带宽，得到更多的数据量，保证信号峰值被测量到。

=== 减少电磁干扰

确保所有设备都正确接地，使用屏蔽电缆和屏蔽组件。

=== 更换传感器

选择更稳定的传感器，并在使用前校准。

=== 选择更好的测量方案

局部放电光纤传感检测法是目前较为常见的检测方法。因其能够实现长距离、分布式、快速实时检测，且所用传感光纤具有本质安全，抗电磁干扰，铺设灵活等优点为局部放电的检测提供了新的思路。

自从Bucaro等人于1977年首次报道了使用光纤 Mach-Zehnder 干涉仪进行声检测以来，*光纤干涉传感器已成为声学测量的重要技术*。2007 年，IEEE 标准规定局部放电产生的超声波范围为 $50 "~ " #qty(300, "kHz")$。2014 年，王伟等人提出了一种基 Fabry-Perot 干涉仪的声传感器，并*验证了局部放电电荷量与局放超声信号幅值之间的关系*。

@sagnac 是基于Sagnac干涉仪的多点局部放电检测系统。

#figure(caption: "检测系统结构示意图")[
  #image("./sagnac.png", width: 85%)
]<sagnac>
由于使用的光纤具有抗电磁干扰、绝缘性能极佳、体积小、布置方式灵活、灵敏度高、耐腐蚀等特点，工作状态不会受到影响。抗干扰能力更强。

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

#pagebreak()

= 敬请批评指正
