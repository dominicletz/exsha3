# ExSha3

Pure Elixir implemtation of Keccak, SHA-3 (FIPS-202) and shake. The provided code is an experiment in porting the c-algorithm to Elixir. While it should be correct don't expect native performance.

The Elixir code is a port from: 
https://github.com/status-im/nim-keccak-tiny/blob/master/keccak_tiny/keccak-tiny.c


## Installation

The package can be installed by adding `exsha3` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:exsha3, "~> 0.1.0"}
  ]
end
```

## This Is Slow

This is a proof of concept, and while is correct it is also really slow. Have a look at these numbers from the included benchmark script:

```
mix run benchmark.exs 
Operating System: Linux
CPU Information: Intel(R) Core(TM) i5-4210U CPU @ 1.70GHz
Number of Available Cores: 4
Available memory: 11.65 GB
Elixir 1.8.1
Erlang 21.3.6

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 ns
parallel: 1
inputs: none specified
Estimated total run time: 28 s

Benchmarking long  elx_sha3_256...
Benchmarking long  nif_sha3_256...
Benchmarking short elx_sha3_256...
Benchmarking short nif_sha3_256...

Name                         ips        average  deviation         median         99th %
short nif_sha3_256      198.18 K        5.05 μs   ±298.35%        4.34 μs        9.57 μs
long  nif_sha3_256        2.13 K      470.47 μs    ±25.09%      427.39 μs      834.64 μs
short elx_sha3_256       0.102 K     9823.35 μs    ±20.22%     9053.57 μs    16869.85 μs
long  elx_sha3_256     0.00069 K  1442829.28 μs     ±3.66%  1450521.55 μs  1494083.30 μs

Comparison: 
short nif_sha3_256      198.18 K
long  nif_sha3_256        2.13 K - 93.24x slower +465.43 μs
short elx_sha3_256       0.102 K - 1946.84x slower +9818.31 μs
long  elx_sha3_256     0.00069 K - 285946.87x slower +1442824.24 μs
```
