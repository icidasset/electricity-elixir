defmodule DocTest do
  use ExUnit.Case
  doctest Electricity.Value, import: true
end
