defmodule Yuribot.Consumer.Ready do
  require Logger
  use Nostrum.Consumer
  alias Nostrum.Struct.Event
  alias Nostrum.Api

  def register_commands() do
    {:ok, modules} = :application.get_key(:yuribot, :modules)

    modules
    |> Enum.map(&Module.split/1)
    |> Enum.filter(fn module ->
      case module do
        [_, "Command", _] -> true
        _ -> false
      end
    end)
    |> Enum.map(fn module ->
      command_def =
        module
        |> Module.concat()
        |> apply(:command_def, [])

      case command_def |> Api.create_global_application_command() do
        {:ok, _} ->
          Logger.info("Registered command /" <> command_def.name)

        {:error, reason} ->
          Logger.error(
            "Failed to register command /" <>
              command_def.name <> "\n Error code: " <> reason.code <> "\n" <> reason.message
          )
      end
    end)
  end

  def handle_event({:READY, %Event.Ready{user: user}, _}) do
    username = user.username
    discriminator = user.discriminator
    Logger.info("Connected as " <> username <> "#" <> discriminator)

    register_commands()
  end
end