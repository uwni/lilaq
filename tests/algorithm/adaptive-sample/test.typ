#import "/src/algorithm/adaptive-sample.typ": adaptive-sample

// A linear function should be sampled at just the endpoints of each interval.
#let pts = adaptive-sample(x => x, (0.0, 1.0))
#assert(pts.len() == 2)
#assert.eq(pts.at(0), (0.0, 0.0))
#assert.eq(pts.at(1), (1.0, 1.0))

// Multiple initial intervals produce points for each interval.
#let pts2 = adaptive-sample(x => x, (0.0, 1.0, 2.0))
#assert(pts2.len() >= 4)

// A highly oscillatory function should produce many samples.
#let pts3 = adaptive-sample(
  x => calc.sin(20 * x),
  (0.0, 1.0),
  cos-tol: 1e-3,
  y-tol: 1e-4,
  max-depth: 12,
)
#assert(pts3.len() > 10)

// All returned points have both x and y as floats.
#for pt in pts3 {
  assert(type(pt.at(0)) in (int, float), message: "x coordinate must be numeric")
  assert(type(pt.at(1)) in (int, float), message: "y coordinate must be numeric")
}
