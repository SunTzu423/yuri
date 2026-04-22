defmodule Yuribot.Command.Yaoi do
  require Logger

  def command_def() do
    %{
      name: "yaoi",
      description: "You sick pervert...",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
  tag = Enum.random(["yaoi", "yaoi", "yaoi", "2boys"])
  Yuribot.Command.Shared.Gelbooru.command_fn(interaction,[tag], "You fucking freak", "yaoi")
	end
end
