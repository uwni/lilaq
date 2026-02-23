#import "@preview/suiji:0.5.1"

// Computes the cosine of the angle between two 2D vectors.
#let cos((x1, y1), (x2, y2)) = {
  (x1 * x2 + y1 * y2) / (calc.sqrt(x1 * x1 + y1 * y1) * calc.sqrt(x2 * x2 + y2 * y2))
}

// Computes the absolute vertical distance from point (xm, ym) to the line
// segment between (x1, y1) and (x2, y2).
#let line-error((x1, y1), (x2, y2), (xm, ym)) = {
  calc.abs(y1 + (xm - x1) * (y2 - y1) / (x2 - x1) - ym)
}

/// Adaptively samples a function by recursively subdividing intervals where
/// the curve changes significantly, as measured by the cosine of the angle
/// between consecutive segments and the vertical deviation from a straight
/// line. This allows accurate plots of smooth functions with fewer evaluations
/// in flat regions and more evaluations near sharp features.
///
/// Returns an array of `(x, y)` tuples.
///
/// -> array
#let adaptive-sample(

  /// The function to sample. It must accept a single `float` argument and
  /// return a `float`.
  /// -> function
  fn,

  /// Initial $x$ coordinates defining the sampling intervals.
  /// -> array
  xs,

  /// Cosine error tolerance. Subdivision stops when
  /// $1 + \cos\theta \leq$ `cos-tol`, where $\theta$ is the angle between
  /// the two segments meeting at the midpoint.
  /// -> float
  cos-tol: 1e-3,

  /// Vertical error tolerance. Subdivision stops when the absolute distance
  /// from the midpoint to the chord is at most `y-tol`.
  /// -> float
  y-tol: 1e-4,

  /// Maximum recursion depth per interval.
  /// -> int
  max-depth: 10,

) = {
  let rng = suiji.gen-rng-f(42)
  let (rng, r1) = suiji.uniform-f(rng, low: .45, high: .55)

  let inner(a, b, depth) = {
    let ya = fn(a)
    let yb = fn(b)
    let xm = a + r1 * (b - a)
    let ym = fn(xm)
    let cos-err = 1 + cos((b - xm, yb - ym), (a - xm, ya - ym))
    let y-err = line-error((a, ya), (b, yb), (xm, ym))
    if (cos-err > cos-tol or y-err > y-tol) and depth < max-depth {
      inner(a, xm, depth + 1) + inner(xm, b, depth + 1)
    } else {
      ((a, ya), (b, yb))
    }
  }

  let result = ()
  for i in range(xs.len() - 1) {
    result += inner(xs.at(i), xs.at(i + 1), 0)
  }
  result
}
