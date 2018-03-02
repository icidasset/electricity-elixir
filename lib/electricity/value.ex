import Algae
import TypeClass

######################
# Definition & Logic #
######################

defmodule Electricity.Value do
  @moduledoc """
  A positive non-negative integer with an associated SI unit.

  For example:
  42 micro Ohms

      %Electricity.Value{
        amount: 42,
        unit: -6
      }
  """

  alias __MODULE__

  # Definition
  # ==========

  defdata do
    # Raw value to be multiplied with the unit
    amount :: non_neg_integer() \\ 0

    # SI Unit: 10 ^ x
    unit :: integer() \\ 0
  end

  # Logic
  # =====

  @doc """
  Reduce a Value to a Float.
  """
  @spec normalize(t()) :: float()
  def normalize(%Value{amount: amount, unit: unit}) do
    amount * :math.pow(10, unit)
  end

  @doc """
  Changes the unit to zero and normalizes the value.
  """
  @spec reduce_unit_to_zero(t()) :: t()
  def reduce_unit_to_zero(value) do
    %{value | amount: normalize(value), unit: 0}
  end
end

###############################
# Implementations & Instances #
###############################

alias Electricity.Value
alias TypeClass.Property.Generator
alias Witchcraft.Semigroup

# Generator
# ---------

defimpl Generator, for: Value do
  def generate(_) do
    %Value{
      amount: :rand.uniform(999_999),
      unit: :rand.uniform(10) - 5 - 1
    }
  end
end

# Semigroup
# ---------

definst Semigroup, for: Value do
  @doc """
  Append two values.

      iex> left = %Value{
      ...>   amount: 1,
      ...>   unit: 2,
      ...> }
      iex> right = %Value{
      ...>   amount: 1,
      ...>   unit: -3,
      ...> }
      ...> append(left, right)
      %Value{
        amount: 100001,
        unit: -3,
      }

  """
  def append(left, right) do
    new_unit =
      left.unit
      |> min(right.unit)
      |> min(0)

    %Value{
      unit: new_unit,
      amount:
        Value.normalize(left)
        |> (fn x -> x + Value.normalize(right) end).()
        |> (fn x -> x * :math.pow(10, new_unit * -1) end).()
        |> round()
        |> min(0)
    }
  end
end
