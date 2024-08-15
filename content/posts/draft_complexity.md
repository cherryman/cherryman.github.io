---
title: "What is average complexity anyways"
date: "2024-06-08"
math: true
description: "desc"
summary: "summary"
ShowToc: false
TocOpen: false
---

<!--
cover:
- why O vs Omega is confusing
- formal definitions for multivariate complexity
- distribution defn, generalise to percentiles?
- possibly abuse the lebesgue integral
- smol o notation
- algebra over complexities
- AvgP
- message complexity

- complexity forms a semiring (??)

https://en.wikipedia.org/wiki/Average-case_complexity
https://lilianweng.github.io/posts/2018-06-24-attention/

TODO: bibtex
TODO: references

If you're thinking "we don't need so much formalization to use this",
then I would argue that that's a skill issue. Whether that's me or
you is an exercise for the reader.

cool idea i had with tommy:
tommy was thinking about complexity for something like O(1/n).

i started thinking about "giving more info" to an algorithm;
one example is computing the preimage of a given hash, where
the input is giving the number of bits of the "answer", which
gives (i think) a complexity of Theta(1/2^n).

another one is neural nets, consider how a model converges faster
with more data points, there's some empirical results on this.

tommy is thinking about of cryptography too, number of
input/output pairs you know and some attacks around that.
-->
