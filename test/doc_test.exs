defmodule DocTest do
  use ExUnit.Case

  doctest Electricity.Quantity, import: true

end
