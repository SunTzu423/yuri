defmodule Yuribot.Board.Gelbooru do
  require Logger

  @base_url "https://safebooru.org/index.php?page=dapi&s=post&q=index&json=1&limit=300"
  @seen_file "seen_posts.json"
  @seen_limit 200
  @max_random_pid 50
  @max_attempts 5

  defp create_tags(user_tags) do
    case user_tags do
      [] -> ""
      _ -> Enum.join(user_tags, "+")
    end
  end

  defp create_url(user_tags, pid \\ nil) do
    tags = create_tags(user_tags)

    url =
      case tags do
        "" -> @base_url
        _ -> @base_url <> "&tags=" <> tags
      end

    case pid do
      nil -> url
      _ -> url <> "&pid=" <> Integer.to_string(pid)
    end
  end

  defp request(user_tags, pid \\ nil) do
    HTTPoison.get(create_url(user_tags, pid))
  end

  defp normalize_url(nil), do: nil

  defp normalize_url(url) when is_binary(url) do
    cond do
      String.starts_with?(url, "//") ->
        "https:" <> url

      String.starts_with?(url, "http://") ->
        "https://" <> String.replace_prefix(url, "http://", "")

      true ->
        url
    end
  end

  defp pick_image_url(post_content) do
    sample_url = normalize_url(post_content["sample_url"])
    file_url = normalize_url(post_content["file_url"])
    preview_url = normalize_url(post_content["preview_url"])

    cond do
      is_binary(sample_url) and sample_url != "" -> sample_url
      is_binary(file_url) and file_url != "" -> file_url
      is_binary(preview_url) and preview_url != "" -> preview_url
      true -> nil
    end
  end

  defp seen_file_path do
    Path.join(File.cwd!(), @seen_file)
  end

  defp load_seen_map do
    path = seen_file_path()

    case File.read(path) do
      {:ok, body} ->
        case Jason.decode(body) do
          {:ok, decoded} when is_map(decoded) -> decoded
          _ -> %{}
        end

      {:error, _} ->
        %{}
    end
  end

  defp save_seen_map(seen_map) do
    path = seen_file_path()

    case Jason.encode(seen_map, pretty: true) do
      {:ok, body} -> File.write(path, body)
      {:error, reason} -> {:error, reason}
    end
  end

  defp normalize_seen_ids(ids) when is_list(ids) do
    ids
    |> Enum.map(fn
      id when is_integer(id) -> id
      id when is_binary(id) ->
        case Integer.parse(id) do
          {parsed, ""} -> parsed
          _ -> nil
        end

      _ -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_seen_ids(_), do: []

  defp load_seen_ids(bucket_key) do
    load_seen_map()
    |> Map.get(bucket_key, [])
    |> normalize_seen_ids()
  end

  defp save_seen_id(bucket_key, id) when is_binary(bucket_key) and is_integer(id) do
    seen_map = load_seen_map()

    updated_ids =
      seen_map
      |> Map.get(bucket_key, [])
      |> normalize_seen_ids()
      |> Enum.reject(&(&1 == id))
      |> Kernel.++([id])
      |> Enum.take(-@seen_limit)

    save_seen_map(Map.put(seen_map, bucket_key, updated_ids))
  end

  defp filter_seen_posts(posts, bucket_key) do
    seen_ids = load_seen_ids(bucket_key)
    seen_set = MapSet.new(seen_ids)

    fresh_posts =
      Enum.reject(posts, fn post ->
        post_id = post["id"]
        is_integer(post_id) and MapSet.member?(seen_set, post_id)
      end)

    case fresh_posts do
      [] ->
        Logger.info("All posts in current batch were recently seen for #{bucket_key}, allowing repeats.")
        posts

      _ ->
        fresh_posts
    end
  end

  defp decode_posts(body) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        cond do
          is_list(decoded) ->
            {:ok, decoded}
  
          is_map(decoded) and is_list(Map.get(decoded, "post")) ->
            {:ok, Map.get(decoded, "post")}
  
          is_map(decoded) and is_map(Map.get(decoded, "post")) ->
            {:ok, [Map.get(decoded, "post")]}
 
          true ->
            {:ok, []}
        end
  
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_random_posts_page(user_tags, attempts_left) when attempts_left > 0 do
    pid = Enum.random(0..@max_random_pid)

    Logger.info("Trying random Safebooru page pid=#{pid}")

    case request(user_tags, pid) do
      {:ok, response} ->
        case decode_posts(response.body) do
          {:ok, []} ->
            fetch_random_posts_page(user_tags, attempts_left - 1)

          {:ok, posts} ->
            {:ok, posts}

          {:error, reason} ->
            {:error, {:json_fail, reason}}
        end

      {:error, reason} ->
        {:error, {:http_fail, reason}}
    end
  end

  defp fetch_random_posts_page(_user_tags, 0) do
    {:ok, []}
  end

  def image(user_tags, bucket_key) do
    case fetch_random_posts_page(user_tags, @max_attempts) do
      {:ok, []} ->
        Logger.info("No post found.")
        {:error, :no_post}

      {:ok, posts} ->
        filtered_posts = filter_seen_posts(posts, bucket_key)
        post_content = Enum.random(filtered_posts)

        image_url =
          case pick_image_url(post_content) do
            url when is_binary(url) -> url
            _ -> nil
          end

        post_id = post_content["id"]

        if is_integer(post_id) do
          save_seen_id(bucket_key, post_id)
        end

        Logger.info("Post found.")
        IO.inspect(post_id, label: "SELECTED_POST_ID")
        IO.inspect(bucket_key, label: "SEEN_BUCKET")
        IO.inspect(image_url, label: "SAFEBOORU_IMAGE_URL")

        {:ok,
         %Yuribot.Struct.Image{
           id: post_id,
           url: image_url,
           source: post_content["source"]
         }}

      {:error, {:http_fail, reason}} ->
        Logger.error("HTTP request failed, reason: " <> inspect(reason))
        {:error, :http_fail}

      {:error, {:json_fail, reason}} ->
        Logger.error("JSON decode failed, reason: " <> inspect(reason))
        {:error, :json_fail}
    end
  end
end