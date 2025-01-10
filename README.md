# mpl-wc

A simple clone of the Unix `wc` utility, written and parallelized with
[MaPLe](https://github.com/MPLLang/mpl). Significant speedups over the default
`wc` implementation. On my MacBook Air M2 (2022), using all 8 cores, it's as
much as 4x faster.

```bash
$ make mpl-wc   # need mpl and smlpkg installed
$ hyperfine --warmup 5 'wc inputs/rmat-10M-symm' './mpl-wc @mpl procs 8 -- inputs/rmat-10M-symm'
Benchmark 1: wc inputs/rmat-10M-symm
  Time (mean ± σ):      2.587 s ±  0.023 s    [User: 2.362 s, System: 0.178 s]
  Range (min … max):    2.561 s …  2.641 s    10 runs
 
Benchmark 2: ./mpl-wc @mpl procs 8 -- inputs/rmat-10M-symm
  Time (mean ± σ):     611.5 ms ±  18.7 ms    [User: 4077.1 ms, System: 296.5 ms]
  Range (min … max):   592.9 ms … 643.9 ms    10 runs
 
Summary
  ./mpl-wc @mpl procs 8 -- inputs/rmat-10M-symm ran
    4.23 ± 0.13 times faster than wc inputs/rmat-10M-symm
```

This particular input is approximately 1.7GB with 215M lines (one word per line).

The fast implementation is in `BufferedWC.sml`; a simpler (but significantly
slower) implementation is in `SimpleWC.sml`.