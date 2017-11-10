defmodule ElectricalCalculations.Frequency do

  @doc """
  In Hz.
  """
  def generic([inductance: l, capacitance: c]) do
    1 / (2 * :math.pi() * :math.sqrt(l * c))
  end

  def resonant_frequency_single_layer_air_coil(coil) do
    l = ElectricalCalculations.Inductance.single_layer_air_coil(coil)
    c = ElectricalCalculations.Capacitance.single_layer_air_coil(coil)

    generic [inductance: l, capacitance: c]
  end

end
