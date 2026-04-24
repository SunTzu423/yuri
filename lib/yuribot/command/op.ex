defmodule Yuribot.Command.Op do
  def command_def() do
    %{
      name: "op",
      description: "Luffy D. Monkey!",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["one_piece"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "One Piece!", "op")	
  end
end

