defmodule Yuribot.Command.Yuri do
  def command_def() do
    %{
      name: "yuri",
      description: "Yuri! Yuri! Yuri! Yuri! Yuri! Yuri! Yuri!",
      integration_types: [0, 1],
      contexts: [0, 1, 2]
    }
  end

  def command_fn(interaction) do
    tag = Enum.random(["yuri", "yuri", "yuri", "yuri", "yuri", "yuri", "yuri", "2girls"])
    Yuribot.Command.Shared.Safebooru.command_fn(interaction,[tag], "Yuri! Woohoo!", "yuri")	
  end
end