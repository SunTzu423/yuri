defmodule Yuribot.Command.Miku do
  def command_def() do
    %{
      name: "miku",
      description: "Ratsatsaa ja ripidabi dilla beritstan dillan dellan doo",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["hatsune_miku"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "Leek Girl", "miku")	
  end
end

