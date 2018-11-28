defmodule Block do

  defstruct [:index, :prev_hash, :timestamp, :transaction_data, :nonce, :block_hash]

  def genesis_block(no_of_nodes) do
    block = %Block{
      index: 0,
      prev_hash: "0",
      timestamp: System.system_time(:second),
      transaction_data: ["genesis_block"],
      nonce: 1,
      block_hash: "not_computed"
    }
    init_wallet = Wallet.create_wallet()
    output = Enum.map(1..no_of_nodes, fn a_node -> [10, Pnode.create_script_pub_key(a_node)] end)
    input = []
    tx = Transaction.create_new_tx(input, output, init_wallet)
    utxo_to_add = Enum.map(output, fn out -> [tx.hash, out] end)
    Enum.map(1..Helper.miner_count(), fn node_id -> Utxo.add(utxo_to_add, node_id) end)
    block = %{block | transaction_data: [tx]}
    block = Miner.mine_for_nonce(block, "Genesis")

  end

  def create_new_block(data) do
    [latest_block | _] = Blockchain.get_blockchain()
    block = %Block{
      index: latest_block.index + 1,
      prev_hash: latest_block.block_hash,
      timestamp: System.system_time(:second),
      transaction_data: data,
      nonce: 1,
      block_hash: "not_computed"
    }
  end

end
