long_string = String.duplicate("1234567890", 2048)
short_string = String.duplicate("1", 128)

Benchee.run(%{
  "long  elx_sha3_256"    => fn -> ExSha3.sha3_256(long_string) end,
  "long  nif_sha3_256" => fn -> :sha3.hash(256, long_string) end,
  "short elx_sha3_256"    => fn -> ExSha3.sha3_256(short_string) end,
  "short nif_sha3_256" => fn -> :sha3.hash(256, short_string) end,
})
