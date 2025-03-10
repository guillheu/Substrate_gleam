import gleam/bit_array
import gleam/io
import gleam/string
import gleeunit
import gleeunit/should
import substrate_gleam/internal/crypto

pub fn main() {
  gleeunit.main()
}

pub fn erlang_blake2b_test() {
  let input =
    "This is an example of text, if you couldn't tell, lmao"
    |> bit_array.from_string
  let expected =
    "0CBA4DE3B93EF8E5B2B0CA7B801C2C9A0B6C0EC21C42BD9960974C106DA3F626"

  crypto.blake2(input)
  |> bit_array.base16_encode
  |> should.equal(expected)
}

pub fn erlang_xxhash_test() {
  // cases from https://www.shawntabrizi.com/blog/substrate/querying-substrate-storage-via-rpc/
  // case 1
  let input = "Sudo" |> bit_array.from_string
  let expected = "5c0d1176a568c1f92944340dbfed9e9c" |> string.uppercase

  crypto.xxhash(input)
  |> bit_array.base16_encode
  |> should.equal(expected)

  // case 2
  let input = "Key" |> bit_array.from_string
  let expected = "530ebca703c85910e7164cb7d1c9e47b" |> string.uppercase

  crypto.xxhash(input)
  |> bit_array.base16_encode
  |> should.equal(expected)

  // with strings

  // case 1
  let input = "Sudo"
  let expected = "5c0d1176a568c1f92944340dbfed9e9c" |> string.uppercase

  crypto.xxhash_from_string(input)
  |> bit_array.base16_encode
  |> should.equal(expected)

  // case 2
  let input = "Key"
  let expected = "530ebca703c85910e7164cb7d1c9e47b" |> string.uppercase

  crypto.xxhash_from_string(input)
  |> bit_array.base16_encode
  |> should.equal(expected)
}
