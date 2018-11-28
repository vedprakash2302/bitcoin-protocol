defmodule MinerList do

  use Agent

  def start_link() do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add(new_miner) do
    Agent.update(__MODULE__, fn miners_list -> [new_miner|miners_list] end)
  end

  def get_all_miners do
    Agent.get(__MODULE__, fn miners_list -> miners_list end)
  end

end
