# MIX_ENV=benchmark mix run benchmark.exs
flavor = try do
  :erlang.system_info(:emu_flavor)
rescue
  ArgumentError -> "smp"
end
IO.puts("=========== emu_flavor = #{flavor} ===========")
Benchee.run(%{
  "  ex_sha3_256" => fn input -> ExSha3.sha3_256(input) end,
  " nif_sha3_256" => fn input -> :sha3.hash(256, input) end,
},
inputs: %{
  "short string" => String.duplicate("1", 128),
  "long  string" => String.duplicate("1234567890", 2048),
})
