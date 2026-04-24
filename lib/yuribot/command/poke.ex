defmodule Yuribot.Command.Poke do
  def command_def() do
    %{
      name: "poke",
      description: "I wanna be the very best",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["pokemon"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "Gotta Catch Em' All", "poke")	
  end
end

