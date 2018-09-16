defmodule Electricity.Direction do
  @moduledoc """
  Not an actual physical direction,
  but more like "going with the flow" or against the flow.
  """

  import Algae


  # 🌳


  defsum do
    defdata(Assisting :: none())
    defdata(Resisting :: none())
  end

end
