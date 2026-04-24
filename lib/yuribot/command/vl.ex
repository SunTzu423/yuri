defmodule Yuribot.Command.Vl do
  def command_def() do
    %{
      name: "vl",
      description: "Just general vocaloid",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["vocaloid"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "The oid", "vl")	
  end
end

