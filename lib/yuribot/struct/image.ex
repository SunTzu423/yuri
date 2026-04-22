defmodule Yuribot.Struct.Image do
  @type t() :: %Yuribot.Struct.Image{
          id: integer(),
          url: String.t(),
          source: String.t()
        }
  @enforce_keys [:id, :url]
  defstruct [:id, :url, :source]
end
