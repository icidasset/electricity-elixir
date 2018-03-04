import Algae
import TypeClass

######################
# Definition & Logic #
######################

defmodule Electricity.Value do
  @moduledoc """
  A positive non-negative integer with an associated metric prefix.

  For example:
  42 micro Ohms

  ```
  %Electricity.Value{
    amount: 42,
    exponent: -6
  }
  ```
  """

  alias __MODULE__

  # Definition
  # ==========

  defdata do
    # Raw value to be combined with the metric prefix (see `power` property).
    amount :: non_neg_integer() \\ 0

    # The exponent used to raise the base 10.
    # Is used to specify a metric/si prefix.
    exponent :: integer() \\ 0
  end

  # Logic
  # =====

  @doc """
  Reduce a Value to a Float.
  """
  @spec normalize(t()) :: float()
  def normalize(%Value{amount: amount, exponent: exponent}) do
    amount * :math.pow(10, exponent)
  end

  @doc """
  Changes the exponent to zero and normalizes the value.
  """
  @spec reduce_unit_to_zero(t()) :: t()
  def reduce_unit_to_zero(value) do
    %{value | amount: normalize(value), exponent: 0}
  end
end

###############################
# Implementations & Instances #
###############################

alias Electricity.Value
alias TypeClass.Property.Generator
alias Witchcraft.{Functor, Semigroup}

# Generator
# ---------

defimpl Generator, for: Value do
  def generate(_) do
    %Value{
      amount: :rand.uniform(999_999),
      exponent: :rand.uniform(10) - 5 - 1
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
      ...>   exponent: 2,
      ...> }
      iex> right = %Value{
      ...>   amount: 1,
      ...>   exponent: -3,
      ...> }
      ...> append(left, right)
      %Value{
        amount: 100001,
        exponent: -3,
      }

  """
  def append(left, right) do
    new_exponent =
      left.exponent
      |> min(right.exponent)
      |> min(0)

    %Value{
      exponent: new_exponent,
      amount:
        Value.normalize(left)
        |> (fn x -> x + Value.normalize(right) end).()
        |> (fn x -> x * :math.pow(10, new_exponent * -1) end).()
        |> round()
        |> min(0)
    }
  end
end

# Functor
# -------

definst Functor, for: Value do
  def map(value, func) do
    %{value | amount: func.(value.amount)}
  end
end
