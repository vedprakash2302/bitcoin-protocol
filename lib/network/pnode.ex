defmodule Pnode do
  use GenServer

  def start(node_id) do
    #    IO.puts("****Node #{node_id} started****")
    GenServer.start_link(__MODULE__, nil, name: :"#{node_id}node")
  end

  def init(_state) do
    new_state = Wallet.create_wallet()
    #    IO.inspect(Wallet.get_public_key_from_wallet(new_state))
    {:ok, new_state}
  end

  def get_wallet(node_id) do
    GenServer.call(Helper.convert_to_atom(node_id, "node"), {:get_wallet})
  end

  def get_address(node_id) do
    GenServer.call(Helper.convert_to_atom(node_id, "node"), {:get_address})
  end

  def send_bitcoin(source_node, dest_node, amount) do
    GenServer.call(Helper.convert_to_atom(source_node, "node"), {:send, dest_node, amount})
  end

  def handle_call({:send, dest_node, amount}, _from, wallet) do
    # {_, credit_outputs} = BCInterface.find_credit_outputs(wallet)
    credit_outputs = BCInterface.find_outputs(wallet)
    tx_input = create_input(credit_outputs, wallet)
    #    IO.inspect(credit_outputs)
    tx_output =
      create_change_output(credit_outputs, wallet, amount) ++ create_output(dest_node, amount)

    #    IO.inspect(tx_output)
    transaction = Transaction.create_new_tx(tx_input, tx_output, wallet)
    #    IO.inspect(transaction)
    Network.post_transaction_to_be_verified(transaction, wallet)
    {:reply, wallet, wallet}
  end

  def handle_call({:get_wallet}, _from, wallet) do
    {:reply, wallet, wallet}
  end

  def handle_call({:get_address}, _from, wallet) do
    {:reply, wallet.address, wallet}
  end

  defp create_input(credit_outputs, wallet) do
    Enum.map(credit_outputs, fn [prev_hash, index, address, value] ->
      [prev_hash, index, address]
    end)
  end

  def create_output(dest_node, amount) do
    [[amount, create_script_pub_key(dest_node)]]
  end

  defp create_change_output(credit_outputs, wallet, amount) do
    sum = calculate_credit(credit_outputs)
    if sum - amount == 0 do
      []
    else
      [[sum - amount, create_script_pub_key(wallet)]]
    end
  end

  def create_script_pub_key(wallet = %Wallet{}) do
    "OP_DUP OP_HASH160 #{wallet.address} OP_EQUALVERIFY"
  end

  def create_script_pub_key(dest_node) do
    "OP_DUP OP_HASH160 #{Pnode.get_address(dest_node)} OP_EQUALVERIFY"
  end

  defp calculate_credit(credit_outputs) do
    Enum.reduce(credit_outputs, 0, fn [_, _, _, value], acc -> acc + value end)
  end
end
