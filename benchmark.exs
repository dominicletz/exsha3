# MIX_ENV=benchmark mix run benchmark.exs
Benchee.run(%{
  "  ex_sha3_256" => fn input -> ExSha3.sha3_256(input) end,
  "tiny_sha3_256" => fn input -> ExSha3Tiny.sha3_256(input) end,
  " nif_sha3_256" => fn input -> :sha3.hash(256, input) end,
},
inputs: %{
  "short string" => String.duplicate("1", 128),
  "long  string" => String.duplicate("1234567890", 2048),
})
