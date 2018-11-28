defmodule Blockchain do
  use GenServer

  def start_blockchain(no_of_nodes) do
    GenServer.start_link(__MODULE__, no_of_nodes, name: :blockchain)
  end

  def init(no_of_nodes) do
    {:ok, [Block.genesis_block(no_of_nodes)]}
  end

  def get_blockchain do
    GenServer.call(:blockchain, {:get_blockchain})
  end

  def add(block) do
    GenServer.cast(:blockchain, {:add, block})
  end

  def inspect do
    GenServer.call(:blockchain, {:inspect})
  end

  def handle_call({:get_blockchain}, _from, blockchain) do
    {:reply, blockchain, blockchain}
  end

  def handle_cast({:add, block}, blockchain) do
    transactions = block.transaction_data
    #utxo_to_add = Enum.flat_map(transactions, fn tx -> Enum.map(tx.outputs, fn out -> [tx.hash, out] end) end)
    #IO.inspect(utxo_to_add)
    [latest_block | rest] = blockchain
    if latest_block.index < block.index do
      # Enum.map(1..Helper.miner_count(), fn node_id -> Utxo.add(utxo_to_add, node_id) end)
      {:noreply, [block | blockchain]}
    else
      {:noreply,blockchain}
    end
  end

  def handle_call({:inspect}, _from, state) do
    IO.inspect(state)
    {:reply, :ok, state}
  end

end
