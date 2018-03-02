import Algae
import TypeClass

defmodule Electricity.Magnetism do
  @moduledoc """
  """

  # Definition
  # ==========

  defdata do
    value :: Electricity.Value.t()
  end
end

###############################
# Implementations & Instances #
###############################

alias Electricity.{Magnetism}
alias TypeClass.Property.Generator
alias Witchcraft.Semigroup

# Generator
# ---------

defimpl Generator, for: Magnetism do
  def generate(_) do
    %Magnetism{
      value: Generator.generate(%Electricity.Value{})
    }
  end
end
