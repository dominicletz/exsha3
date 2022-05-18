# MIX_ENV=benchmark mix run benchmark.exs
flavor = try do
  :erlang.system_info(:emu_flavor)
rescue
  ArgumentError -> "smp"
end
IO.puts("=========== emu_flavor = #{flavor} ===========")
input = String.duplicate("1234567890", 2048)

Profiler.profile(fn -> ExSha3.sha3_256(input) end)
Profiler.fprof(fn -> ExSha3.sha3_256(input) end)
