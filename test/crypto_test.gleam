import gleam/bit_array
import gleam/string
import gleeunit/should
import substrate_gleam/internal/crypto

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

pub fn base58_encoding_test() {
  let to_encode =
    "2AD6A3105D6768E956E9E5D41050AC29843F98561410D3A47F9DD5B3B227AB87464204"
    |> bit_array.base16_decode
    |> should.be_ok
  let expected = "5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR"
  let invalid = "5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyI"

  crypto.b58_encode(to_encode)
  |> should.equal(expected)

  crypto.b58_decode(expected)
  |> should.be_ok
  |> should.equal(to_encode)

  crypto.b58_decode(invalid)
  |> should.be_error
}
