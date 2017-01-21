defmodule Filterable.ParamFilters do
  use Filterable.DSL
  alias Filterable.Utils

  @options param: :params, allow_nil: true
  filter fetch_params(params, value) do
    Utils.get_indifferent(params, value) || params
  end

  @options param: :param, allow_nil: true
  filter fetch_value(params, value) do
    Utils.get_indifferent(params, value)
  end

  @options param: :trim, default: true, allow_nil: true
  filter trim_value(param, value) when value == true and is_bitstring(param) do
    String.trim(param)
  end

  @options param: :allow_blank, default: false, trim: false, allow_nil: true
  filter nilify_value(param, value) when value == false do
    not param in ["", [], {}, %{}] && param || nil
  end

  @options param: :default, allow_nil: true
  filter set_default_value(param, value) do
    case is_nil(param) do
      true -> value
      false -> param
    end
  end

  @options param: :cast, allow_nil: true
  filter cast_value(param, value) when is_function(value) do
    value.(param)
  end
  filter cast_value(param, value) when is_list(value) do
    Enum.reduce(value, param, fn (cast_fn, param) -> cast_fn.(param) end)
  end
end

ExUnit.start()
