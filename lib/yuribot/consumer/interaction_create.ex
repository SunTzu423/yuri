defmodule Yuribot.Consumer.InteractionCreate do
  use Nostrum.Consumer
  require Logger

  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    name = interaction.data.name |> :string.titlecase()

    Module.concat("Yuribot.Command", name)
    |> apply(:command_fn, [interaction])
  end
end
