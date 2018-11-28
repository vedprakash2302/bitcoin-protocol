defmodule Network do

  def create_network(no_of_nodes) do
    MinerList.start_link()
    Enum.map(1..Helper.miner_count(), fn miner -> create_miner_and_add_to_peers_list(miner) end)
    Enum.map(1..no_of_nodes, fn a_node -> Pnode.start(a_node) end)

  end

  def post_transaction_to_be_verified(transaction, wallet) do
    Enum.reduce(MinerList.get_all_miners(), 0,
      fn miner, _ -> Miner.verify_transaction(miner, transaction, wallet) end)
  end

  defp create_miner_and_add_to_peers_list(miner) do
    Miner.start_link(miner)
    MinerList.add(miner)
  end

end
