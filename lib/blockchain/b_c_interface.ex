defmodule BCInterface do
  def find_credit_outputs(%Wallet{} = wallet) do
    #    IO.inspect(wallet.address)
    blockchain = Blockchain.get_blockchain()
    input = Enum.flat_map(blockchain, fn block -> extract_block_txs(block, wallet) end)
    #    IO.puts("*****FOUND THE TRANSACTION*****")
    {_, input} = Enum.at(input, 1)
  end

  defp extract_block_txs(block, wallet) do
    Enum.flat_map(block.transaction_data, fn tx ->
      #    Enum.map(tx.outputs, fn [recipient, value] -> if recipient == wallet.address, do: tx.hash end )
      Enum.reduce(tx.outputs, %{list: [], count: 0}, fn [value, recipient], acc ->
        if String.contains?(recipient, wallet.address) &&
             Enum.member?(Utxo.get_all_utxo(1), [tx.hash, [value, recipient]]),
           do: %{list: [[tx.hash, acc.count, value] | acc.list], count: acc.count + 1},
           else: %{list: acc.list, count: acc.count + 1}
      end)
    end)
  end

  def find_outputs(%Wallet{} = wallet) do
    utxos = Utxo.get_all_utxo(1)

    list =
      Enum.reduce(utxos, [], fn [tx_hash, [value, recipient]], acc ->
        if String.contains?(recipient, wallet.address),
          do: [[tx_hash, 1, Wallet.get_public_key_from_wallet(wallet), value] | acc],
          else: acc
      end)

    list
  end
end
