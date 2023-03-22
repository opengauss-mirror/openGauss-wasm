A complete and mature WebAssembly runtime for openGauss based on [WasmEdge](https://wasmedge.org/book/zh/index.html).
It's an original way to extend your favorite database capabilities.

> Note This project is inspired by [wasmer-postgres](https://github.com/wasmerio/wasmer-postgres)

Features:

  * **Easy to use**: The `wasmedge` API mimics the standard WebAssembly API,
  * **Fast**: `wasmedge` executes the WebAssembly modules as fast as
    possible, close to **native speed**,
  * **Safe**: All calls to WebAssembly will be fast, but more
    importantly, completely safe and sandboxed.

> Note: The project is still in heavy development. This is a
0.1.0 version. Some API are missing and are under implementation. But
it's fun to play with it.

# Installation

The project comes in two parts:

  1. A shared library, and
  2. A PL/pgSQL extension.
  
To compile the former, the wasmedge should have been installed. 
You can install the wasmedge as simple as 

Refer to [https://wasmedge.org/book/en/quick_start/install.html](https://wasmedge.org/book/en/quick_start/install.html) for more details.

After that, run `CREATE EXTENSION wasm_executor` in a
openGauss shell. One new function will appear: `wasm_new_instance`; It must be
called with the absolute path to the shared library. It looks like
this:

```shell
$ # Build the shared library.
$ make

$ # Install the extension in the opengauss
$ make install

$ # Activate and initialize the extension.
$ gsql -d postgres -c 'CREATE EXTENSION wasm_executor'
```

And you are ready to go!


# Usage & documentation

Consider the `examples/sum.rs` program:

```rust
#[no_mangle]
pub extern fn sum(x: i32, y: i32) -> i32 {
    x + y
}
```

For able to compile the rust code to wasm, the rust and wasm toolchain should be installed.
```
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add wasm32-unknown-unknown

```
And also install wasm-gc, which will be used to compress the .wasm file output
```
cargo install wasm-gc
```
Then create a project using cargo
```
cargo new hello --lib
```
The file Cargo.toml (aka "manifest") contains the project's configuration. Leave everything, but append a new block called [lib]. The result should look something this
```
[package]
name = "hello"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]

[lib]
crate-type = ["cdylib"]
```
Rust code lives in the src directory. Your new project contains the default file src/lib.rs. Replace its contents with the sum.rs.
And then compile the project to Wasm and shrink the wasm output.

```
cargo build --target wasm32-unknown-unknown --release
wasm-gc target/wasm32-unknown-unknown/release/hello.wasm
```

Once compiled to WebAssembly, one obtains a similar WebAssembly binary
to `examples/sum.wasm`. To use the `sum` exported function, first, 
create a new instance of the WebAssembly module, and second, 
call the `sum` function.

To instantiate a WebAssembly module, the `wasm_new_instance` function
must be used. It has two arguments:

  1. The absolute path to the WebAssembly module, and
  2. A namespace used to prefix exported functions in SQL.

For instance, calling
`wasm_new_instance('/path/to/sum.wasm', 'wasm')` will create the
`wasm_sum` function that is a direct call to the `sum` exported function
of the WebAssembly instance. Thus:

```sql
-- New instance of the `sum.wasm` WebAssembly module.
SELECT wasm_new_instance('/absolute/path/to/sum.wasm', 'wasm');

-- Call a WebAssembly exported function!
SELECT wasm_sum(1, 2);

--  wasm_sum
-- --------
--       3
-- (1 row)
```

Isn't it awesome? Calling Rust from openGauss through WebAssembly!

Let's inspect a little bit further the `wasm_sum` function:

```sql
\x
\df+ wasm_sum
Schema              | public
Name                | wasm_sum
Result data type    | integer
Argument data types | integer, integer
Type                | normal
Volatility          | volatile
Parallel            | unsafe
Owner               | ...
Language            | plpgsql
Source code         | ...
Description         |
fencedmode          | f
propackage          | f
prokind             | f
```

The openGauss `wasm_sum` signature is `(integer, integer) -> integer`,
which maps the Rust `sum` signature `(i32, i32) -> i32`.

So far, only the WebAssembly types `i32` and `i64` are
supported; they respectively map to `integer` and `bigint`
in openGauss. Floats are partly implemented for the moment.

# Quickstart

To get your hands on openGauss with wasm, we recommend using the Docker image.
Download the docker image firstlly.

```shell
docker pull opengauss/wasmedge:0.2.0
```
Then run it.
```shell
docker run -it opengauss/wasmedge:0.2.0 bash
```
The rust and wasm toolchain have already installed in the docker image for quick use.
So just go ahead and enjoy it.


## Inspect a WebAssembly instance

The extension provides two ways to initilize a WebAssembly instance. As you can
see from the functions name show above, one way is to use `wasm_new_instance` from
.wasm file compiled from other languages.

And, the extension provides two tables, gathered together in
the `wasm` foreign schema:

  * `wasm.instances` is a table with the `id` and `wasm_file` columns,
    respectively for the instance ID, and the path of the WebAssembly
    module,
  * `wasm.exported_functions` is a table with the `instanceid`,
    `funcname`, `inputs` and `output` columns, respectively for the
    instance ID of the exported function, its name, its input types
    (already formatted for openGauss), and its output types (already
    formatted for openGauss).

Let's see:

```sql
-- Select all WebAssembly instances.
SELECT * FROM wasm.instances;

--      id        |          wasm_file
-- ---------------+-------------------------------
--  2785875771    | /absolute/path/to/sum.wasm
-- (1 row)

-- Select all exported functions for a specific instance.
SELECT
    funcname,
    inputs,
    outputs
FROM
    wasm.exported_functions
WHERE
    instanceid = 2785875771;

--   name  |     inputs      | outputs
-- --------+-----------------+---------
--  wasm_sum | integer,integer | integer
-- (1 row)
```

# Benchmarks

Benchmarks are useless most of the time, but it shows that WebAssembly
can be a credible alternative to procedural languages such as
PL/pgSQL. Please, don't take those numbers for granted, it can change
at any time, but it shows promising results:

<table>
  <thead>
    <tr>
      <th>Benchmark</th>
      <th>Runtime</th>
      <th align="right">Time (ms)</th>
      <th align="right">Ratio</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="2">Fibonacci (n = 50)</td>
      <td><code>openGauss-wasm-executor</code></td>
      <td align="right">0.765</td>
      <td align="right">1×</td>
    </tr>
    <tr>
      <td>PL/pgSQL</td>
      <td align="right">1.714</td>
      <td align="right">2×</td>
    </tr>
    <tr>
      <td rowspan="2">Fibonacci (n = 500)</td>
      <td><code>openGauss-wasm-executor</code></td>
      <td align="right">0.794</td>
      <td align="right">1×</td>
    </tr>
    <tr>
      <td>PL/pgSQL</td>
      <td align="right">9.746</td>
      <td align="right">12×</td>
    </tr>
    <tr>
      <td rowspan="2">Fibonacci (n = 5000)</td>
      <td><code>openGauss-wasm-executor</code></td>
      <td align="right">0.820</td>
      <td align="right">1×</td>
    </tr>
    <tr>
      <td>PL/pgSQL</td>
      <td align="right">92.720</td>
      <td align="right">113×</td>
    </tr>
  </tbody>
</table>

# License

The entire project is under the MulanPSL2 License. Please read [the `LICENSE` file][license].

[license]: http://license.coscl.org.cn/MulanPSL2/
