defmodule Absinthe.Type.BuiltIns.ScalarsTest do
  use Absinthe.Case, async: true

  alias Absinthe.Type

  defmodule TestSchema do
    use Absinthe.Schema

    query do
      #Query type must exist
    end
  end

  @max_int 9007199254740991
  @min_int -9007199254740991

  defp serialize(type, value) do
    TestSchema.__absinthe_type__(type)
    |> Type.Scalar.serialize(value)
  end

  defp parse(type, value) do
    TestSchema.__absinthe_type__(type)
    |> Type.Scalar.parse(value)
  end

  context ":integer" do
    it "serializes as an integer" do
      assert 1 == serialize(:integer, 1)
    end

    it "can be parsed from an integer within the valid range" do
      assert {:ok, 0} == parse(:integer, 0)
      assert {:ok, 1} == parse(:integer, 1)
      assert {:ok, -1} == parse(:integer, -1)
      assert {:ok, @max_int} == parse(:integer, @max_int)
      assert {:ok, @min_int} == parse(:integer, @min_int)
      assert :error == parse(:integer, @max_int + 1)
      assert :error == parse(:integer, @min_int - 1)
    end

    it "cannot be parsed from a float" do
      assert :error == parse(:integer, 0.0)
    end

    it "cannot be parsed from a binary" do
      assert :error == parse(:integer, "")
      assert :error == parse(:integer, "0")
    end
  end

  context ":float" do
    it "serializes as a float" do
      assert 1.0 == serialize(:float, 1.0)
    end

    it "can be parsed from an integer" do
      assert {:ok, 0.0} == parse(:float, 0)
      assert {:ok, 1.0} == parse(:float, 1)
      assert {:ok, -1.0} == parse(:float, -1)
    end

    it "can be parsed from a float" do
      assert {:ok, 0.0} == parse(:float, 0.0)
      assert {:ok, 1.9} == parse(:float, 1.9)
      assert {:ok, -1.9} == parse(:float, -1.9)
    end

    it "cannot be parsed from a binary" do
      assert :error == parse(:float, "")
      assert :error == parse(:float, "0.0")
    end
  end

  context ":string" do
    it "serializes as a string" do
      assert "" == serialize(:string, "")
      assert "string" == serialize(:string, "string")
    end

    it "can be parsed from a binary" do
      assert {:ok, ""} == parse(:string, "")
      assert {:ok, "string"} == parse(:string, "string")
    end

    it "cannot be parsed from an integer" do
      assert :error == parse(:string, 0)
    end

    it "cannot be parsed from a float" do
      assert :error == parse(:string, 1.9)
    end
  end

  context ":id" do
    it "serializes as a string" do
      assert "1" == serialize(:id, 1)
      assert "1" == serialize(:id, "1")
    end

    it "can be parsed from a binary" do
      assert {:ok, ""} == parse(:id, "")
      assert {:ok, "abc123"} == parse(:id, "abc123")
    end

    it "can be parsed from an integer" do
      assert {:ok, "0"} == parse(:id, 0)
      assert {:ok, Integer.to_string(@max_int)} == parse(:id, @max_int)
      assert {:ok, Integer.to_string(@min_int)} == parse(:id, @min_int)
    end

    it "cannot be parsed from a float" do
      assert :error == parse(:id, 1.9)
    end
  end

  context ":boolean" do
    it "serializes as a boolean" do
      assert true == serialize(:boolean, true)
      assert false == serialize(:boolean, false)
    end

    it "can be parsed from a boolean" do
      assert {:ok, true} == parse(:boolean, true)
      assert {:ok, false} == parse(:boolean, false)
    end

    it "cannot be parsed from a number" do
      assert :error == parse(:boolean, 0)
      assert :error == parse(:boolean, 0.0)
    end

    it "cannot be parsed from a binary" do
      assert :error == parse(:boolean, "true")
      assert :error == parse(:boolean, "false")
    end
  end
end
