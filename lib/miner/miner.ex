defmodule Miner do
  use GenServer

  def start_link(node_id) do
    GenServer.start_link(__MODULE__, nil, name: :"#{node_id}miner")
    Utxo.start_link(node_id)
  end

  def init(_state) do
    {:ok, []}
  end

  def verify_transaction(node_id, transaction, wallet) do
    GenServer.cast(
      Helper.convert_to_atom(node_id, "miner"),
      {:verify_transaction, transaction, wallet, node_id}
    )
  end

  def add(node_id, transaction) do
    GenServer.call(Helper.convert_to_atom(node_id, "miner"), {:add, node_id, transaction})
  end

  def mine_from_pool(node_id, pool) do
    GenServer.cast(Helper.convert_to_atom(node_id, "miner"), {:mine_from_pool, pool})
  end

  def handle_cast({:verify_transaction, transaction, wallet, node_id}, pool) do
    inputs = transaction.inputs
    is_authorized = is_authorized_to_spend?(inputs, wallet)
    is_output_greater = is_output_greater_than_input?(wallet, transaction.outputs, node_id)

    utxo_to_delete =
      Enum.map(Utxo.get_all_utxo(node_id), fn [a, [b, wal_add]] ->
        if String.contains?(wal_add, wallet.address), do: [a, [b, wal_add]], else: nil
      end)

    if is_authorized && !is_output_greater do
      utxo_to_delete = Enum.filter(utxo_to_delete, fn utxo -> utxo != nil end)
      Utxo.delete(utxo_to_delete, node_id)
      utxo_to_add = Enum.map(transaction.outputs, fn out -> [transaction.hash, out] end)
      Utxo.add(utxo_to_add, node_id)
      pool = [transaction | pool]

      if length(pool) == Helper.block_size() do
        start_mining_for_new_block(pool)
        {:noreply, []}
      else
        {:noreply, pool}
      end
    else
      {:noreply, pool}
    end
  end

  def handle_call({:add, node_id, data}, _from, pool) do
    pool = pool ++ [data]

    case length(pool) < 10 do
      true ->
        {:reply, :ok, pool}

      false ->
        mine_from_pool(node_id, pool)
        {:reply, :ok, [data]}
    end
  end

  def handle_cast({:mine_from_pool, pool}, _state) do
    block = Block.create_new_block(pool)
    block = mine_for_nonce(block, "IGNORE")
    Blockchain.add(block)
  end

  def mine_for_nonce(block, from) do
    block_hash = compute_block_hash(block)

    case String.slice(block_hash, 0, Helper.difficulty()) ===
           String.duplicate("0", Helper.difficulty()) do
      true ->
        block = %{block | block_hash: block_hash}

      _ ->
        #        IO.inspect("NOOOOPPPEEEE#{from}")
        temp_block = %{block | nonce: :rand.uniform(4_294_967_296)}
        #        if from="POOL" do
        #          IO.inspect(temp_block)
        #        end
        mine_for_nonce(temp_block, from)
    end
  end

  def mine_the_block(block) do
    block_hash = compute_block_hash(block)

    case String.slice(block_hash, 0, Helper.difficulty()) ===
           String.duplicate("0", Helper.difficulty()) do
      true ->
        block = %{block | block_hash: block_hash}

      _ ->
        temp_block = %{block | nonce: :rand.uniform(4_294_967_296)}
        mine_the_block(temp_block)
    end
  end

  def start_mining_for_new_block(pool) do
    block = Block.create_new_block(pool)
    block = mine_the_block(block)
    block = %{block | timestamp: System.system_time(:second)}
    Blockchain.add(block)
  end

  defp compute_block_hash(%Block{
         index: i,
         prev_hash: ph,
         timestamp: ts,
         transaction_data: td,
         nonce: n
       }) do
    Crypto.hash("#{i}#{ph}#{ts}#{inspect(td)}#{n}") |> Base.encode16()
  end

  def is_authorized_to_spend?(inputs, wallet) do
    Enum.reduce(inputs, true, fn [_, _, pub_key], acc ->
      if acc == true && Crypto.generate_address_from_public_key(pub_key) == wallet.address,
        do: true,
        else: false
    end)
  end

  def is_output_greater_than_input?(wallet, outputs, node_id) do
    credit_outputs = Utxo.get_credit_outputs_utxo(wallet, node_id)
    input_sum = Enum.reduce(credit_outputs, 0, fn [_, [value, _]], acc -> acc + value end)

    output_sum =
      Enum.reduce(outputs, 0, fn [value, _], acc ->
        if value >= 0 && acc != false, do: acc + value, else: false
      end)

    if output_sum == false do
      true
    else
      output_sum > input_sum
    end
  end

  def verify_if_unspent(inputs, node_id) do
    utxo = Utxo.get_all_utxo(node_id)

    fil =
      Enum.reduce(inputs, 0, fn inp, acca ->
        Enum.reduce(utxo, 0, fn utx, accb ->
          if Crypto.hash(utx) == Crypto.hash(inp), do: true, else: false
        end)
      end)
  end
end
