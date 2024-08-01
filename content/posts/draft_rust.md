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
https://mmapped.blog/posts/12-rust-error-handling
https://blog.burntsushi.net/rust-error-handling/

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

rust error handling has several different modes. for example,
for cli applications, the examples given by `anyhow` or `eyre`
work great

```rust
use eyre::{WrapErr, Result};

fn main() -> Result<()> {
    ...
    it.detach().wrap_err("Failed to detach the important thing")?;

    let content = std::fs::read(path)
        .wrap_err_with(|| format!("Failed to read instrs from {}", path))?;
    ...
}
```

```
Error: Failed to read instrs from ./path/to/instrs.json

Caused by:
    No such file or directory (os error 2)
```

ultimately, the purpose of the error is to bubble up while building the
error that is ultimately returned to the user. similarly, errors are
great for libraries that are ultimately used by the end consumer.

a great example is `std::error::ErrorKind`

```rust
pub enum ErrorKind {
    NotFound,
    PermissionDenied,
    ConnectionRefused,
    ConnectionReset,
    /* a fuckton more errors */
}
```

this is great as it allows the library author to granularly handle
specific cases, such as retrying on transient errors while reporting
failing instances.

however, there's one specific case that i can't seem to find anything
reasonable on, which surprisingly gets little attention, and that is
that of _rust error handling for production infrastructure_.

an example flow is as follows:

0. you want to do an api call to foo api
0. this api request fails in some critical component

now, to handle this cleanly, you'll want to

- print a log so that you can catch it in your alerting
- have a backtrace of this so that you can figure out where
  it was triggered
- in other cases allow the caller to handle the error
- in some conditional case do the alerting and printing the
  backtrace

this "backtrace" use case is currently super awkward in rust.
in fact, without `RUST_LIB_BACKTRACE=1` or `RUST_BACKTRACE=1`,
rust doesn't even record backtraces, despite there being no
documented on what the actual performance impact of always
enabling backtraces even is!

the appriach i've found that seems to work best is a combination
of the `tracing` crate with the `instrument` macro, combined with
the `err` keyword, which will log if a given function returns
an error. combined with rust's `backtrace` feature, this allows
creating this experience smoothly. the level can be overwritten
as well, so if you want a warning instead, `#[tracing::instrument(level
= Level::WARN)]` works perfectly.

this covers all our use cases above, though is somewhat clunky.
perhaps backtraces should be the default.

```rust
#[tracing::instrument(ret, err)]
fn faillible_function(x: &[u8]) -> eyre::Result<()> {
    Ok(())
}
```

(TODO: look at other `tracing::instrument` shit)
(TODO: test if what i'm saying is true)

this provides an interesting dynamic:

- `tracing` builds the stack _downwards_
- `eyre` with backtrace builds it upwards

thus, at any point when the log is printed, the error will provide
all information that is necessary. there is an annoyance however:
what happens if you nest functions that print the error as above?

```rust
#[tracing::instrument(ret, err)]
fn foo(x: &[u8]) -> eyre::Result<()> {
    todo!()
}

#[tracing::instrument(ret, err)]
fn bar(_: &[u8]) -> eyre::Result<()> {
    foo()
}
```

then we get two logs for no reason. this is stupid. to deal with this,
we can rely on a little bit of self-discipline. namely, only printing
errors at a given layer. i'm not sure what the appropriate rule is,
and of course it depends on how your program is leveraging tracing
as well. personally, a nice rule of thumb may be:

- "pure" functions need only return their error; no logging or trace needed
- callers of faillible functions should log and propagate the error
- any function above in the stack shouldn't print an error, instead
  just forwarding it.

i suppose we can also use that there are sort of only two errors:

- recoverable
- fatal

for the former, we log and continue running; in that case, best to log
at the tail. for fatal errors, we know we will propagate all the way up.
in that case, it makes more sense to let the error bubble up, and then
do the logging at the shallowest part of the stack.
