require Bitwise

defmodule ExSha3 do
  @moduledoc """
    ExSha supports the three hash algorithms:
      * KECCAK1600-f the original pre-fips version as used in Ethereum
      * SHA3 the fips-202 approved final hash
      * SHAKE

    Keccak and SHA3 produce fixed length strings corresponding to their
    bit length, while shake produces an arbitary length output according
    to the provided outlen parameter.
  """

  @rho {1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14, 27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44}
  @pi {10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4, 15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1}
  @rc {1, 0x8082, 0x800000000000808A, 0x8000000080008000, 0x808B, 0x80000001, 0x8000000080008081,
       0x8000000000008009, 0x8A, 0x88, 0x80008009, 0x8000000A, 0x8000808B, 0x800000000000008B,
       0x8000000000008089, 0x8000000000008003, 0x8000000000008002, 0x8000000000000080, 0x800A,
       0x800000008000000A, 0x8000000080008081, 0x8000000000008080, 0x80000001, 0x8000000080008008}

  @zero64 <<0::little-unsigned-size(64)>>
  @full64 <<0xFFFFFFFFFFFFFFFF::little-unsigned-size(64)>>

  defp rho(index), do: elem(@rho, index)
  defp pi(index), do: elem(@pi, index)
  defp rc(index), do: <<elem(@rc, index)::little-unsigned-size(64)>>

  defp rol(x, 0) do
    x
  end

  defp rol(<<x::little-unsigned-size(64)>>, s) do
    x =
      if 2 * x > 0xFFFFFFFFFFFFFFFF do
        2 * x - 0x10000000000000000 + 1
      else
        2 * x - 0x10000000000000000
      end

    rol(<<x::little-unsigned-size(64)>>, s - 1)
  end

  defp for_n(n, step, acc, fun) do
    acc =
      Enum.reduce(0..(n - 1), acc, fn i, acc ->
        fun.(i * step, acc)
      end)

    acc
  end

  defp for24(step, acc, fun), do: for_n(24, step, acc, fun)
  defp for5(step, acc, fun), do: for_n(5, step, acc, fun)

  defp binary_a64(<<bin::binary-size(8), rest::binary>>, map) do
    binary_a64(rest, Map.put(map, Map.size(map), bin))
  end

  defp binary_a64("", map) do
    map
  end

  defp a64_binary(map) do
    Map.values(map)
    |> :erlang.iolist_to_binary()
  end

  defp xor(a, b), do: :crypto.exor(a, b)
  defp bnot(a), do: xor(a, @full64)

  defp band(<<a::little-unsigned-size(64)>>, <<b::little-unsigned-size(64)>>),
    do: <<Bitwise.band(a, b)::little-unsigned-size(64)>>

  defp keccakf(a) do
    state = binary_a64(a, %{})
    # acc = {a, inbin}
    acc =
      {state, %{0 => @zero64, 1 => @zero64, 2 => @zero64, 3 => @zero64, 4 => @zero64, t: @zero64}}

    {state, _inbin} =
      for24(1, acc, fn i, acc ->
        # // Theta
        acc =
          for5(1, acc, fn x, {state, inbin} ->
            inbin = %{inbin | x => @zero64}

            for5(5, {state, inbin}, fn y, {state, inbin} ->
              inbin = %{inbin | x => xor(inbin[x], state[x + y])}
              {state, inbin}
            end)
          end)

        {state, inbin} =
          for5(1, acc, fn x, acc ->
            for5(5, acc, fn y, {state, inbin} ->
              state = %{
                state
                | (y + x) =>
                    xor(state[y + x], xor(inbin[rem(x + 4, 5)], rol(inbin[rem(x + 1, 5)], 1)))
              }

              {state, inbin}
            end)
          end)

        # // Rho and pi
        inbin = %{inbin | t: state[1]}

        acc =
          for24(1, {state, inbin}, fn x, {state, inbin} ->
            inbin = %{inbin | 0 => state[pi(x)]}
            state = %{state | pi(x) => rol(inbin.t, rho(x))}
            inbin = %{inbin | t: inbin[0]}
            {state, inbin}
          end)

        # // Chi
        {state, inbin} =
          for5(5, acc, fn y, acc ->
            acc =
              for5(1, acc, fn x, {state, inbin} ->
                inbin = %{inbin | x => state[y + x]}
                {state, inbin}
              end)

            for5(1, acc, fn x, {state, inbin} ->
              state = %{
                state
                | (y + x) => xor(inbin[x], band(bnot(inbin[rem(x + 1, 5)]), inbin[rem(x + 2, 5)]))
              }

              {state, inbin}
            end)
          end)

        # // Iota
        state = %{state | 0 => xor(state[0], rc(i))}
        {state, inbin}
      end)

    a64_binary(state)
  end

  defp xorin(dst, src, offset, len) do
    new = xor(binary_part(src, offset, len), binary_part(dst, 0, len))
    dst2 = binary_put(dst, 0, new)
    {dst2, src}
  end

  defp setout(src, dst, offset, len) do
    new = binary_part(src, 0, len)
    dst2 = binary_put(dst, offset, new)
    {src, dst2}
  end

  # P*F over the full blocks of an input.
  defp foldP(a, inbin, len, fun, rate) when len >= rate do
    {a, inbin} = fun.(a, inbin, byte_size(inbin) - len, rate)
    a = keccakf(a)
    foldP(a, inbin, len - rate, fun, rate)
  end

  defp foldP(a, inbin, len, _fun, _rate) do
    {a, inbin, len}
  end

  defp binary_put(bin, offset, new) do
    binary_part(bin, 0, offset) <>
      new <> binary_part(bin, offset + byte_size(new), byte_size(bin) - (offset + byte_size(new)))
  end

  defp binary_new(size) do
    String.duplicate(<<0>>, size)
  end

  defp binary_xor(var, index, value) do
    index = floor(index)
    c = xor(binary_part(var, index, 1), value)
    binary_put(var, index, c)
  end

  @plen 200
  # /** The sponge-based hash construction. **/
  defp hash(outlen, source, rate, delim) do
    outlen = floor(outlen)
    inlen = floor(byte_size(source))
    rate = floor(rate)

    # // Absorb input.
    a = binary_new(@plen)
    {a, _, inlen} = foldP(a, source, inlen, &xorin/4, rate)
    # // Xor source the DS and pad frame.
    a = binary_xor(a, inlen, <<delim>>)
    a = binary_xor(a, rate - 1, <<0x80>>)
    # // Xor source the last block.
    {a, _source} = xorin(a, source, floor(byte_size(source) - inlen), inlen)
    # // Apply P
    a = keccakf(a)
    # // Squeeze output.
    out = binary_new(outlen)
    {a, out, outlen} = foldP(a, out, outlen, &setout/4, rate)
    {_a, out} = setout(a, out, 0, outlen)
    out
  end

  defp shake(bits, outlen, source), do: hash(outlen, source, 200 - bits / 4, 0x1F)
  @spec shake_128(binary(), number()) :: binary()
  def shake_128(source, outlen), do: shake(128, outlen, source)
  @spec shake_256(binary(), number()) :: binary()
  def shake_256(source, outlen), do: shake(256, outlen, source)

  defp sha3(bits, source), do: hash(bits / 8, source, 200 - bits / 4, 0x06)
  @spec sha3_224(binary()) :: binary()
  def sha3_224(source), do: sha3(224, source)
  @spec sha3_256(binary()) :: binary()
  def sha3_256(source), do: sha3(256, source)
  @spec sha3_384(binary()) :: binary()
  def sha3_384(source), do: sha3(384, source)
  @spec sha3_512(binary()) :: binary()
  def sha3_512(source), do: sha3(512, source)

  defp keccak(bits, source), do: hash(bits / 8, source, 200 - bits / 4, 0x01)
  @spec keccak_224(binary()) :: binary()
  def keccak_224(source), do: keccak(224, source)
  @spec keccak_256(binary()) :: binary()
  def keccak_256(source), do: keccak(256, source)
  @spec keccak_384(binary()) :: binary()
  def keccak_384(source), do: keccak(384, source)
  @spec keccak_512(binary()) :: binary()
  def keccak_512(source), do: keccak(512, source)
end
