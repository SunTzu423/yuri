defmodule Yuribot.Consumer.InteractionCreate do
  use Nostrum.Consumer
  require Logger

  def handle_event({:INTERACTION_CREATE, interaction, _}) do
    custom_id = Map.get(interaction.data, :custom_id)

    cond do
      custom_id == "delete_image" ->
        Nostrum.Api.delete_message(interaction.channel_id, interaction.message.id)

        Nostrum.Api.create_interaction_response(interaction, %{
          type: 6
        })

      true ->
        name = interaction.data.name |> :string.titlecase()

        Module.concat("Yuribot.Command", name)
        |> apply(:command_fn, [interaction])
    end
  end
end