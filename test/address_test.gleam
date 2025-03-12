import gleam/bit_array
import gleam/io
import substrate_gleam/address

import gleeunit/should

pub fn address_decode_test() {
  let address = "5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR"
  let hex_address =
    "2AD6A3105D6768E956E9E5D41050AC29843F98561410D3A47F9DD5B3B227AB87464204"
  let expected_prefix = 42

  address.from_string(address)
  |> should.be_ok
  |> address.to_string
  |> should.equal(address)

  address.from_string(address)
  |> should.be_ok
  |> address.to_bit_array
  |> bit_array.base16_encode
  |> should.equal(hex_address)
}
