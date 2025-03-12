import gleam/bit_array
import gleam/bool
import gleam/result
import substrate_gleam/internal/crypto

const expected_address_byte_length = 35

const expected_address_checksum_suffix_byte_length = 2

const expected_address_prefix_byte_length = 1

const expected_address_pubkey_byte_length = 32

const checksum_context_prefix = <<"SS58PRE">>

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
  let found_bit_size = bit_array.bit_size(decoded)
  use <- bool.guard(
    found_bit_size != expected_address_byte_length * 8,
    Error(InvalidLength(found_bit_size)),
  )

  let assert Ok(prefix_bits) =
    bit_array.slice(decoded, 0, expected_address_prefix_byte_length)
  let assert Ok(checksum) =
    bit_array.slice(
      decoded,
      expected_address_byte_length,
      -expected_address_checksum_suffix_byte_length,
    )
  let assert Ok(pubkey) =
    bit_array.slice(
      decoded,
      expected_address_checksum_suffix_byte_length - 1,
      expected_address_pubkey_byte_length,
    )

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
