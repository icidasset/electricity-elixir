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

  @doc """
  Turn a raw number into a `Value`.
  """
  @spec pack(float()) :: t()
  def pack(number) do
    semi_rounded_number =
      number
      |> (fn x -> x / 1 end).()
      |> abs()
      |> Float.round(15)

    split =
      semi_rounded_number
      |> to_string()
      |> String.split(".")

    case split do
      [_, stuff_after_the_comma] ->
        exponent = String.length(stuff_after_the_comma)
        amount = semi_rounded_number * :math.pow(10, exponent)

        %Value{
          amount: round(amount),
          exponent: -exponent
        }

      _ ->
        %Value{
          amount: number,
          exponent: 0
        }
    end
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
        |> max(0)
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
