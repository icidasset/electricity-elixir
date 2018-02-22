defmodule ElectricalCalculations.Frequency do
  @moduledoc """
  Frequency calculations.
  """

  @doc """
  Calculate frequency in Hz based on inductance and capacitance.
  """
  def generic(inductance: l, capacitance: c) do
    1 / (2 * :math.pi() * :math.sqrt(l * c))
  end

  @doc """
  Calculate the resonant frequency of a single-layer air coil.
  """
  def resonant_frequency_single_layer_air_coil(coil) do
    l = ElectricalCalculations.Inductance.single_layer_air_coil(coil)
    c = ElectricalCalculations.Capacitance.single_layer_air_coil(coil)

    generic(inductance: l, capacitance: c)
  end
end
