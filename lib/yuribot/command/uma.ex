defmodule Yuribot.Command.Uma do
  def command_def() do
    %{
      name: "uma",
      description: "Hashire hashire uma musume",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tags = ["umamusume"]
    Yuribot.Command.Shared.Safebooru.command_fn(interaction, tags, "Umazing!", "umamusume")	
  end
end

