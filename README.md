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
> ./benchmark.sh
Compiling 2 files (.ex)
Generated ex_sha3 app
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
inputs: long  string, short string
Estimated total run time: 42 s

Benchmarking   ex_sha3_256 with input long  string...
Benchmarking   ex_sha3_256 with input short string...
Benchmarking  nif_sha3_256 with input long  string...
Benchmarking  nif_sha3_256 with input short string...
Benchmarking tiny_sha3_256 with input long  string...
Benchmarking tiny_sha3_256 with input short string...

##### With input long  string #####
Name                    ips        average  deviation         median         99th %
 nif_sha3_256       2243.02        0.45 ms    ±19.35%        0.41 ms        0.80 ms
  ex_sha3_256          9.36      106.82 ms    ±17.61%      103.31 ms      140.47 ms
tiny_sha3_256          3.08      324.64 ms     ±7.78%      329.71 ms      346.81 ms

Comparison: 
 nif_sha3_256       2243.02
  ex_sha3_256          9.36 - 239.60x slower +106.37 ms
tiny_sha3_256          3.08 - 728.18x slower +324.20 ms

##### With input short string #####
Name                    ips        average  deviation         median         99th %
 nif_sha3_256     215033.52     0.00465 ms   ±315.46%     0.00428 ms     0.00911 ms
  ex_sha3_256        870.25        1.15 ms    ±58.49%        0.90 ms        2.65 ms
tiny_sha3_256        685.44        1.46 ms    ±14.52%        1.40 ms        2.59 ms

Comparison: 
 nif_sha3_256     215033.52
  ex_sha3_256        870.25 - 247.09x slower +1.14 ms
tiny_sha3_256        685.44 - 313.71x slower +1.45 ms
```