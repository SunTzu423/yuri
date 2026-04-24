defmodule Yuribot.Command.Shared.Safebooru do
  alias Yuribot.Board.Safebooru

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
    embeds: [image_embed],
    components: [
      %{
        type: 1,
        components: [
          %{
            type: 2,
            style: 4,
            label: "Delete",
            custom_id: "delete_image"
          }
        ]
      }
    ]
  }
}
  end

  defp maybe_put_image(embed, nil), do: embed
  defp maybe_put_image(embed, ""), do: embed

  defp maybe_put_image(embed, image_url) when is_binary(image_url) do
    Map.put(embed, :image, %{url: image_url})
  end

  defp maybe_put_image(embed, _), do: embed

  defp source_or_post_url(source, post_id) do
    cond do
      is_nil(source) or source == "" ->
        safebooru_post_url(post_id)

      String.starts_with?(source, "https://i.pximg.net") ->
        safebooru_post_url(post_id)

      true ->
        source
    end
  end

  defp safebooru_post_url(post_id) do
    "https://safebooru.org/index.php?page=post&s=view&id=#{post_id}"
  end

  defp source_label(source) do
  cond do
    is_nil(source) or source == "" ->
      "Safebooru"

    String.starts_with?(source, "https://i.pximg.net") ->
      "Safebooru"

    true ->
      "Source"
    end
  end

  def command_fn(interaction, tags, title \\ nil, bucket_key \\ nil) do
    resolved_bucket =
      case bucket_key do
        nil -> Enum.join(tags, "|")
        _ -> bucket_key
      end

    response =
      case Safebooru.image(tags, resolved_bucket) do
        {:ok, image} ->
          make_reply(%Yuribot.Command.Shared.Safebooru{
            title: title,
            image_url: image.url,
            description:
  "[#{source_label(image.source)}](#{source_or_post_url(image.source, image.id)})",
            footer: "id: " <> Integer.to_string(image.id)
          })

        {:error, :no_post} ->
          make_reply(%Yuribot.Command.Shared.Safebooru{
            title: "Error!",
            description: "No post found! Perhaps no post with these tags exists.",
            ephemeral?: true
          })

        {:error, :http_fail} ->
          make_reply(%Yuribot.Command.Shared.Safebooru{
            title: "Error!",
            description: "HTTP failure while contacting Safebooru.",
            ephemeral?: true
          })

        {:error, :json_fail} ->
          make_reply(%Yuribot.Command.Shared.Safebooru{
            title: "Error!",
            description: "Failed to parse Safebooru response.",
            ephemeral?: true
          })

      end

    Nostrum.Api.create_interaction_response(interaction, response)
  end
end