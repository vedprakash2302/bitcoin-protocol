defmodule Helper do
  def difficulty do
    3
  end

  def convert_to_atom(node_id, suffix) do
    :"#{node_id}#{suffix}"
  end

  def miner_count do
    3
  end

  def block_size do
    2
  end
end
