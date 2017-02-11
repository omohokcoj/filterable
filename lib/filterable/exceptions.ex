defmodule Filterable.InvalidParamError do
  @moduledoc """
  Raises when filter param is invalid.
  """
  defexception [:message]
end

defmodule Filterable.CastError do
  @moduledoc """
  Raises when value cannot be cast.
  """
  defexception [:type, :value, :message]

  def exception(opts) do
    value = Keyword.fetch!(opts, :value)
    type  = Keyword.fetch!(opts, :type)
    msg   = Keyword.get(opts, :message, "Unable to cast #{inspect(value)} to #{type}")
    %__MODULE__{value: value, type: type, message: msg}
  end
end
