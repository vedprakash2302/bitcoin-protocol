defmodule Bitcoin do
  def main(args) do
    args |> parse_args |> handle
  end

  defp parse_args(args) do
    {_, arguments, _} =
      OptionParser.parse(args,
        switches: [name: :string]
      )

    arguments
  end

  def handle([]) do
    IO.puts("No argument given")
  end

  def handle(parameter) do
    Network.create_network(parameter)
    IO.puts("*****Starting the Blockchain*****")
    Blockchain.start_blockchain(parameter)
    IO.puts("*****THIS IS GENESIS*****")
    # Blockchain.inspect()
    Pnode.send_bitcoin(1, 2, 5)
    Process.sleep(10000)
    Pnode.send_bitcoin(1, 2, 5)
    Process.sleep(5000)
    Pnode.send_bitcoin(2, 1, 10)
    Process.sleep(5000)
    IO.inspect(Utxo.get_all_utxo(1))
    IO.inspect(Utxo.get_all_utxo(2))
    IO.inspect(Utxo.get_all_utxo(3))

    #IO.inspect(Utxo.get_all_utxo(3))
    #Blockchain.inspect()

  end
end
