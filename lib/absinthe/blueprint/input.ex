defmodule Absinthe.Blueprint.Input do

  @moduledoc false

  alias Absinthe.Blueprint
  alias __MODULE__

  import Kernel, except: [inspect: 1]

  @type leaf ::
      Input.Integer.t
    | Input.Float.t
    | Input.Enum.t
    | Input.String.t
    | Input.Variable.t
    | Input.Boolean.t

  @type collection ::
      Blueprint.Input.List.t
    | Input.Object.t

  @type t :: leaf | collection | Input.Value.t | Input.Argument.t

  @parse_types [
    Input.Boolean,
    Input.Enum,
    Input.Field,
    Input.Float,
    Input.Integer,
    Input.List,
    Input.Object,
    Input.String,
  ]

  @spec parse(any) :: nil | t
  def parse(%struct{} = value) when struct in @parse_types do
    value
  end
  def parse(value) when is_integer(value) do
    %Input.Integer{value: value}
  end
  def parse(value) when is_float(value) do
    %Input.Float{value: value}
  end
  # Note: The value may actually be an Enum value and may
  # need to be manually converted, based on the schema.
  def parse(value) when is_binary(value) do
    %Input.String{value: value}
  end
  def parse(value) when is_boolean(value) do
    %Input.Boolean{value: value}
  end
  def parse(value) when is_list(value) do
    %Input.List{
      items: Enum.map(value, fn item ->
        %Input.Value{literal: parse(item)}
      end)
    }
  end
  def parse(value) when is_map(value) do
    %Input.Object{
      fields: Enum.map(value, fn
        {name, field_value} ->
          %Input.Field{
            name: name,
            input_value: %Input.Value{literal: parse(field_value)}
          }
      end)
    }
  end
  def parse(nil) do
    nil
  end

  @simple_inspect_types [
    Input.Boolean,
    Input.Float,
    Input.Integer,
    Input.String
  ]

  @spec inspect(t) :: String.t
  def inspect(%str{} = node) when str in @simple_inspect_types do
    Kernel.inspect(node.value)
  end
  def inspect(%Input.Enum{} = node) do
    node.value
  end
  def inspect(%Input.List{} = node) do
    contents =
      node.items
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")
    "[#{contents}]"
  end
  def inspect(%Input.Object{} = node) do
    contents =
      node.fields
      |> Enum.filter(&(&1.input_value.literal))
      |> Enum.map(&inspect/1)
      |> Enum.join(", ")
    "{#{contents}}"
  end
  def inspect(%Input.Field{} = node) do
    node.name <> ": " <> inspect(node.input_value)
  end
  def inspect(%Input.Value{} = node) do
    inspect(node.literal)
  end
  def inspect(%Input.Variable{} = node) do
    "$" <> node.name
  end
  def inspect(nil) do
    "null"
  end
  def inspect(other) do
    Kernel.inspect(other)
  end

end
