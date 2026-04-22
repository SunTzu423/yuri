defmodule Yuribot.Command.Ping do
  require Logger
  alias Nostrum.Api

  def command_def() do
    %{
      name: "ping",
      description: "ping test"
    }
  end

  def command_fn(interaction) do
    message = %{
      type: 4,
      data: %{
        content: "Hello buddy!"
      }
    }

    Api.create_interaction_response(interaction, message)
  end
end
