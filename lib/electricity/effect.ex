defmodule Electricity.Effect do
  @moduledoc """
  """

  import Algae

  alias Electricity.{Effect, Quantity}
  alias Electricity.Direction.{Assisting, Resisting}


  # 🌳


  defdata do
    direction :: Electricity.Direction.t()
    field :: Electricity.Field.t()
    quantity :: Electricity.Quantity.t()
  end



  # ⚡️


  @doc """
  Append two effects.
  """
  def append(left, right) do
    if left.field != right.field do
      raise "Cannot add effects together that don't have the same field."
    end

    new_quantity =
      case {left.direction, right.direction} do
        {%Assisting{}, %Assisting{}} ->
          Quantity.add(left.quantity, right.quantity)

        {%Assisting{}, %Resisting{}} ->
          Quantity.subtract(left.quantity, right.quantity)

        {%Resisting{}, %Assisting{}} ->
          Quantity.subtract(left.quantity, right.quantity)

        {%Resisting{}, %Resisting{}} ->
          Quantity.add(left.quantity, right.quantity)
      end

    %Effect{
      direction: left.direction,
      field: left.field,
      quantity: new_quantity
    }
  end

end



###############################
# Implementations & Instances #
###############################

alias Electricity.{Direction, Effect, Field, Quantity}
alias Electricity.Direction.{Assisting, Resisting}
alias TypeClass.Property.Generator


# Generator
# ---------

defimpl Generator, for: Effect do

  def generate(_) do
    %Effect{
      direction: Enum.random([%Direction.Assisting{}, %Direction.Resisting{}]),
      field: %Field.Magnetic{},
      quantity: Generator.generate(%Quantity{})
    }
  end

end
