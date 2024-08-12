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

https://docs.rs/tracing-subscriber/latest/tracing_subscriber/fmt/struct.TestWriter.html

TODO:
https://docs.rs/tracing-error/latest/tracing_error/
https://docs.rs/displaydoc/latest/displaydoc/
https://docs.rs/backtrace/latest/backtrace/
https://docs.rs/educe/latest/educe/
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

a great example is `std::io::ErrorKind`

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

the approach i've found that seems to work best is a combination
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

a full example below:

```rust
fn main() -> anyhow::Result<()> {
    std::env::set_var("RUST_LIB_BACKTRACE", "1");
    tracing_subscriber::fmt()
        .with_max_level(tracing::Level::DEBUG)
        .init();

    foo()
        .inspect_err(|e| {
            tracing::error!(error = %e, backtrace = %e.backtrace(), "error");
        })
        .ok();

    Ok(())
}

#[tracing::instrument()]
fn foo() -> anyhow::Result<()> {
    bar()?;
    Ok(())
}

#[tracing::instrument(ret, err)]
fn bar() -> anyhow::Result<()> {
    anyhow::bail!("something really bad happened");
}
```

the output looks like:

(TODO: enable line numbers)

```
2024-08-09T04:30:17.232035Z ERROR foo:bar: errtest: error=something really bad happened
2024-08-09T04:30:17.232073Z ERROR errtest: error error=something really bad happened backtrace=   0: std::backtrace_rs::backtrace::libunwind::trace
             at /rustc/b1ec1bd65f89c1375d2cf2fb733a87ef390276d3/library/std/src/../../backtrace/src/backtrace/libunwind.rs:105:5
   1: std::backtrace_rs::backtrace::trace_unsynchronized
             at /rustc/b1ec1bd65f89c1375d2cf2fb733a87ef390276d3/library/std/src/../../backtrace/src/backtrace/mod.rs:66:5

# omitted ...
```

admittedly, the backtrace is quite ugly when printed to the command
line. however, i think this is fine since in practice, for the purposes
of what we're doing here, you'll be using some other tool to view the
logs. of course, if this really bothers you, then modifying the
`on_error` recorder is a totally valid option:

(TODO: EXAMPLE HERE)

## What about `tracing-error`

An alternative is using this crate to also capture
the span, as the span has crucial information. you can
consider making a fancy error type that encompasses everything,
though it may be better to instead use `color-eyre` for this.

also, the unfortunate tradeoff is that this ends up losing
a lot of the benefits of tracing, namely, using it with
tooling for tracing the actual error! with the trick above,
we can log the error and include it in our traces, while also
ensuring that it can be debugged through the logs.

<!-- ARTICLE BEGINS BELOW -->

"Rust errors for reporting"

Rust error handling has several "modes" to it. We always start from
the basic approach that everyone learns when they first learn Rust,
where the caller can deal with the error with pattern matching. For
example, `std::env::VarError`:

```rust
pub enum VarError {
    NotPresent,
    NotUnicode(OsString),
}
```

This approach is nicely covered in [this great article by Sabrina
Jewson](https://sabrinajewson.org/blog/errors). Of course, for
applications such as command-line, we do want to turn this into
a nice error message for the user. This is where crates like `anyhow`
come in. They have a great example to demonstrate:

<!-- TODO: link -->

```rust
use anyhow::{Context, Result};

fn main() -> Result<()> {
    ...
    it.detach().context("Failed to detach the important thing")?;

    let content = std::fs::read(path)
        .with_context(|| format!("Failed to read instrs from {}", path))?;
    ...
}
```

Which produces:

```
Error: Failed to read instrs from ./path/to/instrs.json

Caused by:
    No such file or directory (os error 2)
```

<!-- TODO: possibly mention eyre -->

However, there's one that I think is critically not covered enough, and
that's how to deal with errors _in production_. Specifically, for long
running services that don't necessarily terminate when a given call
fails, but do want to _report_ it so it can be investigated. Not only
that, but we want to be able to pin down exactly what triggered the
error. This is probably still unclear, so as an example:

0. You want to do an HTTP request to an external API.
0. Certain errors that the API returns are completely fatal.

If this happens, we're doomed! The service dies, and we need to deal
with the source of the error ASAP. How do we design our system to be
as easy to debug as possible?

## Enter `tracing`
