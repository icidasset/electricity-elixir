defmodule ElectricalCalculations.Capacitance do

  @doc """
  Calculating the (parasitic) capacitance of a single-layer air coil,
  using the formulae of Medhurst.

  C = p * coil_diameter
  ~> in Farads

  Where:
  r = coil radius
  n = number of turns
  l = length of coil
  """
  @spec single_layer_air_coil(map()) :: float()
  def single_layer_air_coil(%{radius: r, number_of_turns: _, length: l}) do
    form_factor =
      l / (r * 2)

    p =
      cond do
        form_factor > 0     -> 0.96
        form_factor > 0.15  -> 0.79
        form_factor > 0.20  -> 0.70
        form_factor > 0.25  -> 0.64

        form_factor > 0.30  -> 0.60
        form_factor > 0.35  -> 0.57
        form_factor > 0.40  -> 0.54
        form_factor > 0.45  -> 0.52
        form_factor > 0.50  -> 0.50
        form_factor > 0.60  -> 0.48
        form_factor > 0.70  -> 0.47
        form_factor > 0.80  -> 0.46
        form_factor > 0.90  -> 0.46
        form_factor > 1.00  -> 0.46
        form_factor > 1.50  -> 0.47
        form_factor > 2.00  -> 0.50
        form_factor > 2.50  -> 0.56
        form_factor > 3.00  -> 0.61
        form_factor > 3.50  -> 0.67
        form_factor > 4.00  -> 0.72
        form_factor > 4.50  -> 0.77
        form_factor > 5.00  -> 0.81
        form_factor > 6.00  -> 0.92
        form_factor > 7.00  -> 1.01
        form_factor > 8.00  -> 1.12
        form_factor > 9.00  -> 1.22
        form_factor > 10    -> 1.32
        form_factor > 15    -> 1.86
        form_factor > 20    -> 2.36
        form_factor > 25    -> 2.9
        form_factor > 30    -> 3.4
        form_factor > 40    -> 4.6
        form_factor > 50    -> 5.8
      end

    # Return
    p * r * :math.pow(10, -12)
  end

end
