defmodule Wallet do

  defstruct [:private_key, :public_key, :address]

  def create_wallet do
    {public_key, private_key} = Crypto.create_pub_priv_keypair()
    address = Crypto.generate_address_from_public_key(public_key)
    %Wallet{
      private_key: private_key,
      public_key: public_key,
      address: address
    }
  end

  def sign(signature_string, wallet) do
    signature = :crypto.sign(:ecdsa, :sha256, signature_string, [Base.decode16!(wallet.private_key), :secp256k1])
    Base.encode16(signature)
  end

  def get_public_key_from_wallet(%Wallet{} = wallet) do
    wallet.public_key
  end


end
