defmodule Yuribot.Command.Teto do
  def command_def() do
    %{
      name: "teto",
      description: "Teto, like from teto",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["kasane_teto"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "Baguette Girl", "teto")	
  end
end

