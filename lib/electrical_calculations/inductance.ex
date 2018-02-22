defmodule ElectricalCalculations.Inductance do
  @doc """
  Calculate the inductance of a single-layer air coil.

  L = (r ^ 2 * n ^ 2) / (9r + 10l)
  ~> in Henries

  Where:
  r = coil radius (in cm)
  n = number of turns
  l = length of coil (in cm)
  """
  @spec single_layer_air_coil(map()) :: float()
  def single_layer_air_coil(%{radius: r, number_of_turns: n, length: l}) do
    :math.pow(r, 2) * :math.pow(n, 2) / (r * 9 + l * 10)
  end
end
