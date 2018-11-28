defmodule Utxo do
  use Agent

  def start_link(node_id) do
    Agent.start_link(fn -> [] end, name: :"#{node_id}utx")
  end

  def add(tx_output, node_id) do
    Agent.update(Helper.convert_to_atom(node_id, "utx"), fn utxo_pool ->
      utxo_pool ++ tx_output
    end)
  end

  def delete(outputs, node_id) do
    Agent.update(Helper.convert_to_atom(node_id, "utx"), fn utxo_pool -> utxo_pool -- outputs end)
  end

  def get_all_utxo(node_id) do
    Agent.get(Helper.convert_to_atom(node_id, "utx"), fn utxo_pool -> utxo_pool end)
  end

  def get_credit_outputs_utxo(wallet, node_id) do
    utxos = get_all_utxo(node_id)

    list =
      Enum.filter(utxos, fn [_, [_, recipient]] -> String.contains?(recipient, wallet.address) end)

    list
  end
end
