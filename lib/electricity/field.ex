defmodule Electricity.Field do
  @moduledoc """
  A component of electricity.
  """

  import Algae


  # 🌳


  defsum do
    defdata(Magnetic :: none())
    defdata(Dielectric :: none())
  end

end
