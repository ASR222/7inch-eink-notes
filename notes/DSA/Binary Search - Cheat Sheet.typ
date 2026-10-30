#import "/template/boox.typ": *
#show: note.with(title: "Binary Search", subject: "DSA", kind: "cheat")

#let small(body) = text(0.8em, body)
#let s = 1.3pt  // diagram stroke

= Template
```python
lo, hi = 0, len(a) - 1
while lo <= hi:
    mid = lo + (hi - lo) // 2
    if a[mid] == t: return mid
    if a[mid] < t: lo = mid + 1
    else:          hi = mid - 1
return -1
```

#fig(caption: [One loop iteration])[
  #diagram(spacing: (9mm, 6mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 1), [`lo <= hi`?], name: <cond>, stroke: 2pt),
    node((1, 1), [`a[mid]` vs `t`], name: <cmp>, stroke: 2pt),
    node((2, 0), [`==` → *return mid*], name: <eq>),
    node((2, 1), [`<` → `lo = mid+1`], name: <lt>),
    node((2, 2), [`>` → `hi = mid-1`], name: <gt>),
    node((0, 2), [return *-1*], name: <nf>, shape: fletcher.shapes.pill),
    edge(<cond>, <cmp>, "-|>", [yes]), edge(<cond>, <nf>, "-|>", [no], label-side: left),
    edge(<cmp>, <eq>, "-|>"), edge(<cmp>, <lt>, "-|>"), edge(<cmp>, <gt>, "-|>"),
    edge(<lt>, (3, 1), (3, -1), (0, -1), <cond>, "-|>", [repeat], label-pos: 0.5, stroke: (dash: "dashed")),
    edge(<gt>, (3, 2), (3, 1), "-", stroke: (dash: "dashed")),
  )
]

= Variants
#table(columns: (auto, 1fr),
  table.header([Goal], [Change]),
  [First ≥ t (lower bound)], [`while lo < hi`, `hi = len(a)`; if `a[mid] < t` then `lo = mid+1` else `hi = mid`; return `lo`],
  [First > t (upper bound)], [same, but test `a[mid] <= t`],
  [On a condition], [find the first `x` where `ok(x)` is true; `ok` must be monotonic],
)

#fig(caption: [Which variant?])[
  #diagram(spacing: (9mm, 5mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 1), [*What do you need?*], name: <q>, stroke: 2pt),
    node((1, 0), [exact match → *template*], name: <a>),
    node((1, 1), [first `≥ t` → *lower bound*], name: <b>),
    node((1, 2), [first `> t` → *upper bound*], name: <c>),
    node((1, 3), [first `ok(x)` → *on a condition*], name: <d>),
    edge(<q>, <a>, "-|>"), edge(<q>, <b>, "-|>"), edge(<q>, <c>, "-|>"), edge(<q>, <d>, "-|>"),
  )
]

= Complexity
#formula[$ T(n) = T(n/2) + O(1) = O(log n) $]
- Iterative: $O(1)$ space · Recursive: $O(log n)$ space
- $n = 10^6$ → at most 20 steps · $n = 10^9$ → at most 30 steps

#fig(caption: [Each step halves the search space: about $log_2 n$ steps])[
  #diagram(spacing: (10mm, 6mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 0), [$n$]), edge("-|>", small[÷2]), node((1, 0), [$n\/2$]), edge("-|>", small[÷2]),
    node((2, 0), [$n\/4$]), edge("-|>", small[…]), node((3, 0), [*1*], stroke: 2pt),
  )
]

= Traps
- Overflow: use `lo + (hi-lo)//2`
- `lo < hi` goes with `hi = mid`; `lo <= hi` goes with `hi = mid - 1`
- Unsorted input → wrong answers, but no error

#fig(caption: [Match the loop condition to the update])[
  #diagram(spacing: (12mm, 4mm), node-stroke: s, edge-stroke: s, node-inset: 6pt, node-corner-radius: 2pt, node-shape: rect,
    node((0, 0), [`while lo <= hi`]), edge("<|-|>"), node((1, 0), [`hi = mid - 1`]),
    node((0, 1), [`while lo < hi`]), edge("<|-|>"), node((1, 1), [`hi = mid`]),
  )
]
