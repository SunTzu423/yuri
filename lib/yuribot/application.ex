defmodule Yuribot.Application do
  use Application

  def start(_type, _args) do
    children = [
      Yuribot.Consumer.Ready,
      Yuribot.Consumer.InteractionCreate
    ]

    opts = [strategy: :one_for_one, name: Yuribot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
