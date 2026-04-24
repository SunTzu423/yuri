defmodule Yuribot.Command.Cirno do
  def command_def() do
    %{
      name: "cirno",
      description: "Funky!",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["cirno"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "9", "cirno")	
  end
end

