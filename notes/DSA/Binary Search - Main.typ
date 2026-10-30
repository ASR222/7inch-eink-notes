#import "/template/boox.typ": *
#show: note.with(title: "Binary Search", subject: "DSA", kind: "main", date: "2026-10-22",
  intro: [Finding an item in a sorted array by halving the search space: the idea, the code, why it is $O(log n)$, and the classic bugs.])

= The idea
Binary search finds a target in a *sorted* array by repeatedly halving the part of the array where the target could still be.

#defn[Search space][
  The range of indices `[lo, hi]` that might still contain the answer. Every step must shrink it, and must never throw the answer away.
]

#key[
  Sorted order lets one comparison with the middle element discard *half* of the remaining elements.
]

#fig(caption: [Searching for 23 in a sorted array])[
  #diagram(
    spacing: (4mm, 18mm), node-stroke: 1.4pt, node-inset: 8pt, node-shape: rect,
    node((0, 0), [2]), node((1, 0), [5]), node((2, 0), [8]), node((3, 0), [*12*], stroke: 2pt),
    node((4, 0), [16]), node((5, 0), [23]), node((6, 0), [38]),
    node((4, 1), [16]), node((5, 1), [*23*], stroke: 2pt), node((6, 1), [38]),
    edge((3, 0), (4, 1), [12 < 23 → go right], "-|>", label-side: right),
  )
]

= The algorithm
== Iterative version
```python
def binary_search(a, target):
    lo, hi = 0, len(a) - 1
    while lo <= hi:        # space non-empty
        mid = lo + (hi - lo) // 2
        if a[mid] == target:
            return mid
        elif a[mid] < target:
            lo = mid + 1   # drop left half
        else:
            hi = mid - 1   # drop right half
    return -1
```

#pitfall[
  `mid = (lo + hi) // 2` can overflow in C/Java when `lo + hi` exceeds the integer limit. Use `lo + (hi - lo) // 2`.
]

#pitfall[
  `while lo < hi` with `hi = mid - 1` skips the last element. Match the loop condition to how you shrink the range.
]

= Why it is $O(log n)$
After $k$ steps the search space has $n / 2^k$ elements. It stops when only one is left:

#formula(name: "steps")[
  $ n / 2^k = 1 quad ==> quad k = log_2 n $
]

#table(columns: (1fr, auto, auto),
  table.header([Case], [Time], [Space]),
  [Iterative], [$O(log n)$], [$O(1)$],
  [Recursive], [$O(log n)$], [$O(log n)$ stack],
)

#example[
  For $n = 10^6$ you need at most $ceil(log_2 10^6) = 20$ comparisons. A linear scan could need $1,000,000$.
]

#mine[Binary search works on any *monotonic* yes/no condition, not only on arrays.]

#qa[What must be true of the input?][It must be sorted, or more generally the condition must be monotonic: all "no" answers come before all "yes" answers.]

#glance[
  - Sorted input → compare with the middle → discard half.
  - Loop while `lo <= hi`; move with `mid ± 1`.
  - $O(log n)$ time, $O(1)$ space when iterative.
]
