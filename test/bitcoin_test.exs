defmodule BitcoinTest do
  use ExUnit.Case
  doctest Bitcoin

  test "validate genesis blocks generation" do
    IO.inspect("Running test: validate genesis blocks generation")
    no_of_nodes = 1
    Network.create_network(no_of_nodes)
    Blockchain.start_blockchain(no_of_nodes)
    blockchain = Blockchain.get_blockchain()
    block_count = Enum.count(blockchain)
    transaction_count = Enum.count(Enum.at(blockchain, 0).transaction_data)
    assert block_count == 1 and transaction_count == no_of_nodes
  end

  test "verify btc transfer" do
    IO.inspect("Running test: verify btc transfer")
    no_of_nodes = 2
    initial_amount = 10
    transfer_amt = 5
    Network.create_network(no_of_nodes)
    Blockchain.start_blockchain(no_of_nodes)

    # Transfer 5 BTC from node 1 to node 2
    Pnode.send_bitcoin(1, 2, transfer_amt)
    Process.sleep(1000)
    node1_outputs = Utxo.get_credit_outputs_utxo(Pnode.get_wallet(1), 1)
    balance1 = Enum.reduce(node1_outputs, 0, fn [_, [value, _]], acc -> acc + value end)

    node2_outputs = Utxo.get_credit_outputs_utxo(Pnode.get_wallet(2), 1)
    balance2 = Enum.reduce(node2_outputs, 0, fn [_, [value, _]], acc -> acc + value end)
    assert balance1 == initial_amount - transfer_amt && balance2 == initial_amount + transfer_amt
  end

  test "verify nonce and block addition" do
    IO.inspect("Running test: verify nonce and block addition")
    no_of_nodes = 2
    transfer_amt = 10
    Network.create_network(no_of_nodes)
    Blockchain.start_blockchain(no_of_nodes)

    # Transfer 5 BTC from node 1 to node 2
    Pnode.send_bitcoin(1, 2, transfer_amt)
    Process.sleep(1000)

    # Transfer 5 BTC from node 1 to node 2
    Pnode.send_bitcoin(2, 1, transfer_amt)
    Process.sleep(1000)

    Process.sleep(1000)
    blockchain = Blockchain.get_blockchain()
    block_head = Enum.at(blockchain, 0)
    block_count = Enum.count(blockchain)
    transaction_count = Enum.count(block_head.transaction_data)

    assert block_count == 2 and transaction_count == 2 and
             String.starts_with?(
               block_head.block_hash,
               String.duplicate("0", Helper.difficulty())
             )
  end

  test "validate ownership of bitcoins" do
    IO.inspect("Running test: validate ownership of bitcoins")
    no_of_nodes = 1
    Network.create_network(no_of_nodes)
    Blockchain.start_blockchain(no_of_nodes)

    wallet = Pnode.get_wallet(1)
    credit_outputs = BCInterface.find_outputs(wallet)
    tx_input = create_input(credit_outputs)
    transaction = Transaction.create_new_tx(tx_input, [], wallet)

    is_authorized =
      Enum.reduce(transaction.inputs, true, fn [_, _, pub_key], acc ->
        if acc == true && Crypto.generate_address_from_public_key(pub_key) == wallet.address,
          do: true,
          else: false
      end)

    assert is_authorized
  end

  defp create_input(credit_outputs) do
    Enum.map(credit_outputs, fn [prev_hash, index, address, _] ->
      [prev_hash, index, address]
    end)
  end
end
