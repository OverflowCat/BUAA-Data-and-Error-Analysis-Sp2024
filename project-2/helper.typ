#let hr = line(stroke: black.lighten(70%), length: 100%)
#let c = x => calc.round(x, digits: 3)
#let c2 = x => calc.round(x, digits: 2)
#let average(arr) = {
  let n = arr.len()
  arr.sum() / n
}
#let stderr(arr) = {
  let avg = average(arr)
  let vs = arr.map(x => x - avg)
  let n = arr.len()
  let sigma2 = vs.map(x=>x*x).sum()/(n - 1)
  calc.sqrt(sigma2)
}