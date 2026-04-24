defmodule Yuribot.Command.Ping do
  alias Nostrum.Api
  import Bitwise

  @discord_epoch 1_420_070_400_000

  def command_def() do
    %{
      name: "ping",
      description: "ping test"
    }
  end

  def command_fn(interaction) do
    created_at = (interaction.id >>> 22) + @discord_epoch
    now = System.system_time(:millisecond)

    ping = abs(now - created_at)

    Api.create_interaction_response(interaction, %{
      type: 4,
      data: %{
        content: "Hello buddy! That took #{ping}ms"
      }
    })
  end
end