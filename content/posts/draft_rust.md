---
title: "The different modes of Rust error handling"
date: "2024-06-08"
math: true
description: "desc"
summary: "summary"
ShowToc: false
TocOpen: false
draft: false
---

<!--
we have nice errors for user stuff, and panics
create nice backtraces.

however, for production shit, you _want_ to get a
backtrace along with a detailed log of the error
that happened, along with precise line numbers
and other diagnostic information

i think a nice way would be tracing+err thingy

because tracing creates an implicit stack trace through
its tracing. tracing has a `record_error` which works well.
might want to discuss how to get line numbers this way though

https://sabrinajewson.org/blog/errors
https://www.lpalmieri.com/posts/error-handling-rust/#summary
https://www.sheshbabu.com/posts/rust-error-handling/

maybe talk about the "modes" of error handling, namely:
- user facing
- dev facing
- logging for debugging
- crashing the application?
- retry loops?

how the fuck do i start this post.

who is the audience? i'm guessing folk who have
at least some experience writing rust, and have experienced
this pain point in the past.
-->

<!--
# References

[^1]: https://sabrinajewson.org/blog/errors
[^2]: https://www.lpalmieri.com/posts/error-handling-rust/
[^3]: https://www.sheshbabu.com/posts/rust-error-handling/
-->



```rust
pub fn main() -> Result<(), Error> {
    Ok(())
}
```
