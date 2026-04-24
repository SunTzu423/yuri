defmodule Yuribot.Command.Cirno do
  def command_def() do
    %{
      name: "cirno",
      description: "9",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["cirno"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "Funky!", "cirno")	
  end
end

