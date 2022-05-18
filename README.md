# ExSha3

Pure Elixir implemtation of Keccak, SHA-3 (FIPS-202) and shake. The provided code is an experiment in porting the c-algorithm to Elixir. While it should be correct don't expect native performance.

The Elixir code is a port from: 
https://github.com/status-im/nim-keccak-tiny/blob/master/keccak_tiny/keccak-tiny.c


## Installation

The package can be installed by adding `exsha3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exsha3, "~> 0.1"}
  ]
end
```

## This Is Slow

This is a proof of concept, and while is correct it is also really slow. Have a look at these numbers from the included benchmark script:

```
> ./benchmark.sh
=========== emu_flavor = jit ===========
Operating System: Linux
CPU Information: AMD Ryzen 7 3700U with Radeon Vega Mobile Gfx
Number of Available Cores: 8
Available memory: 15.45 GB
Elixir 1.11.4
Erlang 24.0-rc1

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: long  string, short string
Estimated total run time: 28 s

Benchmarking   ex_sha3_256 with input long  string...
Benchmarking   ex_sha3_256 with input short string...
Benchmarking  nif_sha3_256 with input long  string...
Benchmarking  nif_sha3_256 with input short string...

##### With input long  string #####
Name                    ips        average  deviation         median         99th %
 nif_sha3_256        4.24 K        0.24 ms    ±24.26%        0.21 ms        0.48 ms
  ex_sha3_256     0.00989 K      101.15 ms     ±5.02%       99.30 ms      121.34 ms

Comparison: 
 nif_sha3_256        4.24 K
  ex_sha3_256     0.00989 K - 428.71x slower +100.91 ms

##### With input short string #####
Name                    ips        average  deviation         median         99th %
 nif_sha3_256      283.57 K        3.53 μs   ±499.14%        3.28 μs        8.17 μs
  ex_sha3_256        1.61 K      621.56 μs    ±18.51%      600.85 μs     1285.68 μs

Comparison: 
 nif_sha3_256      283.57 K
  ex_sha3_256        1.61 K - 176.26x slower +618.04 μs
```