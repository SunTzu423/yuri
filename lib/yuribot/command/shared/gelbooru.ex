defmodule Yuribot.Command.Shared.Gelbooru do
  alias Yuribot.Board.Gelbooru

  defstruct [:title, :description, :image_url, :footer, ephemeral?: false]

  defp make_reply(reply_data) do
    title =
      if reply_data.title == nil,
        do: "Safebooru!",
        else: reply_data.title

    flags = if reply_data.ephemeral?, do: 64, else: nil

    image_embed =
      %{
        title: title,
        description: reply_data.description,
        footer: %{
          text: reply_data.footer
        }
      }
      |> maybe_put_image(reply_data.image_url)

    %{
      type: 4,
      data: %{
        flags: flags,
        embeds: [image_embed]
      }
    }
  end

  defp maybe_put_image(embed, nil), do: embed
  defp maybe_put_image(embed, ""), do: embed

  defp maybe_put_image(embed, image_url) when is_binary(image_url) do
    Map.put(embed, :image, %{url: image_url})
  end

  defp maybe_put_image(embed, _), do: embed

  def command_fn(interaction, tags, title \\ nil, bucket_key \\ nil) do
    resolved_bucket =
      case bucket_key do
        nil -> Enum.join(tags, "|")
        _ -> bucket_key
      end

    response =
      case Gelbooru.image(tags, resolved_bucket) do
        {:ok, image} ->
          make_reply(%Yuribot.Command.Shared.Gelbooru{
            title: title,
            image_url: image.url,
            description:
              case image.source do
                nil -> "[Source unavailable]"
                _ -> "[Source](#{image.source})"
              end,
            footer: "id: " <> Integer.to_string(image.id)
          })

        {:error, :no_post} ->
          make_reply(%Yuribot.Command.Shared.Gelbooru{
            title: "Error!",
            description: "No post found! Perhaps no post with these tags exists.",
            ephemeral?: true
          })

        {:error, :http_fail} ->
          make_reply(%Yuribot.Command.Shared.Gelbooru{
            title: "Error!",
            description: "HTTP failure while contacting Safebooru.",
            ephemeral?: true
          })

        {:error, :json_fail} ->
          make_reply(%Yuribot.Command.Shared.Gelbooru{
            title: "Error!",
            description: "Failed to parse Safebooru response.",
            ephemeral?: true
          })

        {:error, :no_auth_key} ->
          make_reply(%Yuribot.Command.Shared.Gelbooru{
            title: "Error!",
            description: "This source does not require an auth key anymore, so something is misconfigured.",
            ephemeral?: true
          })
      end

    Nostrum.Api.create_interaction_response(interaction, response)
  end
end