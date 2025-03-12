// Reference: https://www.shawntabrizi.com/blog/substrate/querying-substrate-storage-via-rpc/

import base_x_gleam/base58
import gleam/dynamic.{type Dynamic}

const substrate_blake2_output_bit_size = 256

const substrate_xxhash_seed_round_1 = 0

const substrate_xxhash_seed_round_2 = 1

pub fn blake2(data: BitArray) -> BitArray {
  do_hash2b(data, substrate_blake2_output_bit_size / 8, <<>>)
}

pub fn blake2_512(data: BitArray) -> BitArray {
  do_hash2b(data, 64, <<>>)
}

pub fn xxhash(data: BitArray) -> BitArray {
  <<
    do_xxh64(dynamic.from(data), substrate_xxhash_seed_round_1):little-size(64),
    do_xxh64(dynamic.from(data), substrate_xxhash_seed_round_2):little-size(64),
  >>
}

pub fn xxhash_from_string(data: String) -> BitArray {
  <<
    do_xxh64(dynamic.from(data), substrate_xxhash_seed_round_1):little-size(64),
    do_xxh64(dynamic.from(data), substrate_xxhash_seed_round_2):little-size(64),
  >>
}

pub fn b58_encode(input: BitArray) -> String {
  base58.encode(input)
}

pub fn b58_decode(input: String) -> Result(BitArray, Nil) {
  base58.decode(input)
}

// https://hexdocs.pm/blake2/Blake2.html#hash2b/3
@external(erlang, "Elixir.Blake2", "hash2b")
fn do_hash2b(data: BitArray, output_size: Int, secret_key: BitArray) -> BitArray

// https://hexdocs.pm/xxhash/XXHash.html#xxh64/2
@external(erlang, "Elixir.XXHash", "xxh64")
fn do_xxh64(input: Dynamic, seed: Int) -> Int
