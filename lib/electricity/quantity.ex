defmodule Electricity.Quantity do
  @moduledoc """
  A positive non-negative integer with an associated metric prefix.

  For example:
  42 micro Ohms

  ```
  %Electricity.Quantity{
    amount: 42,
    exponent: -6
  }
  ```

  ## Examples

      iex> v = new(2, 1)
      iex> multiply(v, v)
      %Electricity.Quantity{amount: 4, exponent: 2}

      iex> v = new(1, 1)
      iex> multiply(v, v)
      %Electricity.Quantity{amount: 1, exponent: 2}

      iex> a = new(1, 1)
      iex> b = new(1, 2)
      iex> multiply(a, b)
      %Electricity.Quantity{amount: 1, exponent: 3}

      iex> v = new(1, -1)
      iex> multiply(v, v)
      %Electricity.Quantity{amount: 1, exponent: -2}

      iex> a = new(1, -2)
      iex> b = new(1, -3)
      iex> multiply(a, b)
      %Electricity.Quantity{amount: 1, exponent: -5}

      iex> a = new(1, -2)
      iex> b = new(10, -3)
      iex> run(a) == run(b)
      true

  """

  import Algae
  import TypeClass

  alias __MODULE__


  # 🌳


  defdata do

    # Raw value to be combined with the metric prefix (see `exponent` property).
    amount :: non_neg_integer() \\ 0

    # The exponent used to raise the base 10.
    # Is used to specify a metric/si prefix.
    exponent :: integer() \\ 0

  end



  # Logic
  # =====

  @doc """
  Scale a raw number.
  Multiply by `10 ^ x`.

  NOTE:
  Uses `Float.round` to remove the weird float-rounding errors.

    iex> scale(1, 1)
    10.0

    iex> scale(2, 3)
    2000.0

  """
  @spec scale(float() | integer(), integer()) :: float()
  def scale(number, exponent) do
    Float.round(
      number * :math.pow(10, exponent),
      max(0, -exponent)
    )
  end


  @spec scale_and_round(float() | integer(), integer()) :: integer()
  def scale_and_round(number, exponent) do
    number
    |> scale(exponent)
    |> round()
  end


  @spec ensure_float(float() | integer()) :: float()
  def ensure_float(x), do: x / 1



  # Rays
  # ====

  @doc """
  Remove zeros from the number.
  """
  @spec shrink_ray(float()) :: t()
  def shrink_ray(float) do
    str =
      float
      |> round()
      |> to_string()

    how_many_zeros =
      str
      |> String.trim_trailing("0")
      |> String.length()
      |> (fn x -> String.length(str) - x end).()

    %Quantity{
      amount: scale_and_round(float, -how_many_zeros),
      exponent: how_many_zeros
    }
  end


  @doc """
  Ensure a natural number.
  """
  @spec expand_ray(float()) :: t()
  def expand_ray(float) do
    amount_of_stuff_after_comma =
      float
      |> Float.to_string()
      |> (fn str ->
            if String.contains?(str, "e"),
              do: :erlang.float_to_binary(float, [{:decimals, 15}, :compact]),
              else: str
          end).()
      |> String.split(".")
      |> Enum.at(1)
      |> String.length()

    %Quantity{
      amount: scale_and_round(float, amount_of_stuff_after_comma),
      exponent: -amount_of_stuff_after_comma
    }
  end



  # Structs
  # =======

  @doc """
  Turn a raw number into a `Quantity`.

  Remove as many zeros as possible.
  Or in other words, get as close as possible to the amount `1`.
  """
  @spec pack(integer() | float()) :: t()
  def pack(number) do
    semi_rounded_number =
      number
      |> abs()
      |> ensure_float()
      |> Float.round(15)

    # shrink or expand
    if semi_rounded_number >= 1 &&
         (String.contains?("#{semi_rounded_number}", "e") ||
          String.ends_with?("#{semi_rounded_number}", ".0")),
       do: shrink_ray(semi_rounded_number),
       else: expand_ray(semi_rounded_number)
  end


  @doc """
  Reduce a `Quantity` to a float.

    iex> v = new(1, 1)
    iex> run(v)
    10.0

    iex> v = new(1, 1)
    iex> run(%{v | exponent: 0})
    1.0

  """
  @spec run(t()) :: float()
  def run(%Quantity{amount: amount, exponent: exponent}) do
    scale(amount, exponent)
  end


  defalias(unpack(quantity), as: :run)
  defalias(to_float(quantity), as: :run)



  # Operations
  # ==========

  @spec operation((Decimal.t(), Decimal.t() -> Decimal.t()), t(), t()) :: t()
  def operation(func, left, right) do
    func.(
      left |> run() |> Decimal.new(),
      right |> run() |> Decimal.new()
    )
    |> Decimal.to_float()
    |> Quantity.pack()
  end


  def add(left, right), do: operation(&Decimal.add/2, left, right)
  def subtract(left, right), do: operation(&Decimal.sub/2, left, right)
  def multiply(left, right), do: operation(&Decimal.mult/2, left, right)
  def divide(left, right), do: operation(&Decimal.div/2, left, right)

end



###############################
# Implementations & Instances #
###############################


import TypeClass

alias Electricity.Quantity
alias TypeClass.Property.Generator
alias Witchcraft.{Functor, Semigroup}


# Generator
# ---------

defimpl Generator, for: Quantity do

  def generate(_) do
    %Quantity{
      amount: :rand.uniform(999_999),
      exponent: :rand.uniform(10) - 5 - 1
    }
  end

end



# Semigroup
# ---------

definst Semigroup, for: Quantity do

  @doc """
  Append two quantities.

    iex> left = %Quantity{
    ...>   amount: 1,
    ...>   exponent: 2,
    ...> }
    iex> right = %Quantity{
    ...>   amount: 1,
    ...>   exponent: -3,
    ...> }
    ...> append(left, right)
    %Quantity{
      amount: 100001,
      exponent: -3,
    }

  """
  def append(left, right), do: Quantity.add(left, right)

end



# Functor
# -------

definst Functor, for: Quantity do

  def map(quantity, func) do
    %{quantity | amount: func.(quantity.amount)}
  end

end
