import gleam/bit_array
import substrate_gleam/address

import gleeunit/should

pub fn address_decode_test() {
  let address = "5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR"
  let hex_address =
    "2AD6A3105D6768E956E9E5D41050AC29843F98561410D3A47F9DD5B3B227AB87464204"

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

// Example taken from https://docs.polkadot.com/polkadot-protocol/basics/accounts/#using-subkey
pub fn address_from_components_test() {
  let prefix = 42
  let pubkey =
    "d6a3105d6768e956e9e5d41050ac29843f98561410d3a47f9dd5b3b227ab8746"
    |> bit_array.base16_decode
    |> should.be_ok
  let expected_address = "5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR"
  address.from_components(prefix, pubkey)
  |> should.be_ok
  |> address.to_string
  |> should.equal(expected_address)
}
