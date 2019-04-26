defmodule ExSha3Test do
  use ExUnit.Case
  doctest ExSha3

  test "comparing against reference implementations" do
    generators = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]

    data = Enum.map(generators, fn g -> String.duplicate(g, 1024) end)

    for bin <- data do
      assert {:ok, ExSha3.sha3_224(bin)} == :sha3.hash(224, bin)
      assert {:ok, ExSha3.sha3_256(bin)} == :sha3.hash(256, bin)
      assert {:ok, ExSha3.sha3_384(bin)} == :sha3.hash(384, bin)
      assert {:ok, ExSha3.sha3_512(bin)} == :sha3.hash(512, bin)

      assert ExSha3.keccak_224(bin) == :keccakf1600.hash(:sha3_224, bin)
      assert ExSha3.keccak_256(bin) == :keccakf1600.hash(:sha3_256, bin)
      assert ExSha3.keccak_384(bin) == :keccakf1600.hash(:sha3_384, bin)
      assert ExSha3.keccak_512(bin) == :keccakf1600.hash(:sha3_512, bin)

      assert ExSha3.shake_128(bin, 16) == :keccakf1600.hash(:shake128, bin, 16)
      assert ExSha3.shake_256(bin, 16) == :keccakf1600.hash(:shake256, bin, 16)
    end
  end
end
