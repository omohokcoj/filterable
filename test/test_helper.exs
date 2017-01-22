defmodule ParamFilters do
  use Filterable.DSL

  alias Filterable.Utils

  @options param: :params
  filter fetch_params(params, value),
    do: Utils.get_indifferent(params, value, params)

  @options param: :param
  filter fetch_value(params, value),
    do: Utils.get_indifferent(params, value)

  @options param: :trim, default: true
  filter trim_value(param, value) when value == true and is_bitstring(param),
    do: String.trim(param)

  @options param: :allow_blank, default: false, trim: false
  filter nilify_value(param, value) when value == false and param in ["", [], {}, %{}],
    do: nil

  @options param: :default
  filter set_default_value(param, value) when is_nil(param),
    do: value
  filter set_default_value(param, _),
    do: param

  @options param: :cast
  filter cast_value(param, value) when is_function(value),
    do: value.(param)
  filter cast_value(param, value) when is_list(value),
    do: Enum.reduce(value, param, &(&1.(&2)))

  @options share: "shared", allow_nil: false
  filter share(_, _, share),
    do: share
end

ExUnit.start()
