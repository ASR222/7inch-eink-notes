deck: DSA::Binary Search
tags: dsa binary-search

Q: What property must the input have for binary search to work?
A: It must be **sorted**. More generally, the condition you test must be **monotonic**: all "no" answers come before all "yes" answers.

Q: Why is binary search $O(\log n)$?
A: Each step halves the search space. After $k$ steps $n/2^k$ elements are left, which reaches 1 when $k = \log_2 n$.

Q: Write the overflow-safe way to compute `mid`.
A:
```python
mid = lo + (hi - lo) // 2
```
`lo + hi` can overflow fixed-size integers in C or Java.

Q: Binary search: what is the space complexity of the iterative and the recursive versions?
A: Iterative: $O(1)$. Recursive: $O(\log n)$, because of the call stack.

Q: At most how many comparisons does binary search need for $10^6$ elements?
A: $\lceil \log_2 10^6 \rceil = 20$

Q: Which loop condition goes with `hi = mid - 1`, and which goes with `hi = mid`?
A: `while lo <= hi` goes with `hi = mid - 1`. `while lo < hi` goes with `hi = mid` (the lower-bound style).
