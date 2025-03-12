import gleam/bit_array
import gleam/bool
import gleam/dict
import gleam/result
import substrate_gleam/internal/crypto

const checksum_context_prefix = <<"SS58PRE">>

// See https://develop--substrate-docs.netlify.app/v3/advanced/ss58/#address-formats-for-substrate
const valid_addresses_formats_by_total_length = [
  #(3, AddressFormat(1, 1, 1)),
  #(4, AddressFormat(1, 2, 1)),
  #(5, AddressFormat(1, 2, 2)),
  #(6, AddressFormat(1, 4, 1)),
  #(7, AddressFormat(1, 4, 2)),
  #(8, AddressFormat(1, 4, 3)),
  #(9, AddressFormat(1, 4, 4)),
  #(10, AddressFormat(1, 8, 1)),
  #(11, AddressFormat(1, 8, 2)),
  #(12, AddressFormat(1, 8, 3)),
  #(13, AddressFormat(1, 8, 4)),
  #(14, AddressFormat(1, 8, 5)),
  #(15, AddressFormat(1, 8, 6)),
  #(16, AddressFormat(1, 8, 7)),
  #(17, AddressFormat(1, 8, 8)),
  #(35, AddressFormat(1, 32, 2)),
]

type AddressFormat {
  AddressFormat(prefix_l: Int, pubkey_l: Int, checksum_l: Int)
}

pub opaque type Address {
  Address(address_type: Int, pubkey: BitArray, checksum: BitArray)
}

pub type AddressDecodingError {
  InvalidCharacter
  InvalidLength(Int)
  InvalidChecksum(expected: BitArray, found: BitArray)
  InvalidPrefix(Int)
}

pub fn from_string(
  address address: String,
) -> Result(Address, AddressDecodingError) {
  use decoded <- result.try(
    crypto.b58_decode(address) |> result.replace_error(InvalidCharacter),
  )
  let found_byte_size = bit_array.byte_size(decoded)

  use address_format <- result.try(
    dict.get(
      dict.from_list(valid_addresses_formats_by_total_length),
      found_byte_size,
    )
    |> result.replace_error(InvalidLength(found_byte_size)),
  )

  let assert Ok(prefix_bits) =
    bit_array.slice(decoded, 0, address_format.prefix_l)
  let assert Ok(checksum) =
    bit_array.slice(decoded, found_byte_size, -address_format.checksum_l)
  let assert Ok(pubkey) =
    bit_array.slice(decoded, address_format.prefix_l, address_format.pubkey_l)

  let assert Ok(computed_checksum) =
    crypto.blake2_512(<<
      checksum_context_prefix:bits,
      prefix_bits:bits,
      pubkey:bits,
    >>)
    |> bit_array.slice(0, 2)

  use <- bool.guard(
    computed_checksum != checksum,
    Error(InvalidChecksum(computed_checksum, checksum)),
  )

  let prefix = do_decode_unsigned(prefix_bits)
  Ok(Address(prefix, pubkey, checksum))
}

pub fn to_string(address address: Address) -> String {
  to_bit_array(address)
  |> crypto.b58_encode
}

pub fn to_bit_array(address address: Address) -> BitArray {
  <<address.address_type, address.pubkey:bits, address.checksum:bits>>
}

@external(erlang, "binary", "decode_unsigned")
fn do_decode_unsigned(input: BitArray) -> Int
