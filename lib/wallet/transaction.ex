defmodule Transaction do

  defstruct [:ver, :no_of_inputs, :inputs, :no_of_outputs, :outputs, :hash, :public_key, :lock_time, :signature]

  def create_new_tx(tx_input, tx_output, %Wallet{} = wallet) do

    transaction = %Transaction{
    ver: 1,
    lock_time: 0,
    inputs: tx_input,
    no_of_inputs: length(tx_input),
    outputs: tx_output,
    no_of_outputs: length(tx_output),
    public_key: Wallet.get_public_key_from_wallet(wallet)
    }

    signature_string = "#{string_to_be_signed(transaction)}#{transaction.public_key}"
    signature = Wallet.sign(signature_string, wallet)

    signed_transaction = %{transaction | signature: signature}
    %{signed_transaction|hash: "#{string_to_be_signed(transaction)}#{signature}"
                               |> Crypto.hash() |> Base.encode16()}
  end

  def string_to_be_signed(%Transaction{} = transaction) do
    "#{Enum.reduce(transaction.inputs ++ transaction.outputs, "",
      fn item, acc ->
        if Enum.count(item) == 2, do: acc <> Enum.at(item, 1) <> Integer.to_string(Enum.at(item, 0)),
                                  else: acc <> Enum.at(item, 0) <> Integer.to_string(Enum.at(item, 1)) <> Enum.at(item, 2) end)}"
  end

end
