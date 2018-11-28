defmodule Crypto do

  def hash(data) do
    :crypto.hash(:sha256, data)
  end

  def create_pub_priv_keypair do
    {public_key, private_key} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(public_key), Base.encode16(private_key)}
  end

  def format_address(hash) do
    "1" <> String.slice(hash, 1..31)
  end

  def generate_address_from_public_key(pk) do
    pk |> hash() |> Base.encode16() |> format_address()
  end

end
