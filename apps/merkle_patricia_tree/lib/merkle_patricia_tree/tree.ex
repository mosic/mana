defmodule MerklePatriciaTree.Tree do
  defstruct [:db, :root]
  alias MerklePatriciaTree.{Tree, Nibbles}

  def new(db, root \\ "") do
    %Tree{db: db, root: root}
  end

  def update(%Tree{db: db, root: root}, key, value) do
    new_root = update_and_delete_storage(root, key, value, db)

    %Tree{db: db, root: new_root}
  end

  defp update_and_delete_storage(node, key, value, db) do
    type = node |> node_type

    update_node(node, type, key, value)
  end

  defp update_node(_node, :blank, key, value) do
    binary_key =
      key
      |> Nibbles.from_binary
      |> Nibbles.add_terminator
      |> Nibbles.hex_prefix

    [binary_key, value]
  end

  defp node_type("") do
    :blank
  end

  defp node_type([key, _]) do
    last_nibble =
      key
      |> Nibbles.from_binary
      |> List.last

    node_type(last_nibble)
  end

  defp node_type(16) do
    :leaf
  end

  defp node_type(num) when is_integer(num) do
    :extension
  end

  defp node_type(list) when length(list) == 17 do
    :branch
  end
end
