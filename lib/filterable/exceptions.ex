defmodule Filterable.FilterError do
  @moduledoc """
  Raises when filter can't be applied.
  """
  defexception [:message]
end
