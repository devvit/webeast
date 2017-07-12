#

defmodule Myweb.Repo do
  use Ecto.Repo, otp_app: :myweb
end

defmodule Myweb.Item do
  use Ecto.Schema

  schema "items" do
    field :title, :string
  end

  def changeset(person, params \\ %{}) do
    person
    |> Ecto.Changeset.cast(params, [:title])
  end
end

defmodule Myweb do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Myweb.Repo, []),
    ]

    opts = [strategy: :one_for_one, name: Myweb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Myweb.Apiv1 do
  alias RedixPool, as: Redis
  alias Myweb.Repo
  alias Myweb.Item
  use Maru.Router
  version 'v1'

  get "/json" do
    json(conn, %{hello: :world})
  end

  get "/redis" do
    text(conn, elem(Redis.command(["GET", "mydata"]), 1))
  end

  get "/select" do
    item = Item |> Repo.get(1)
    json(conn, %{id: item.id, title: item.title})
  end

  get "/update" do
    item = Item |> Repo.get(1)
    changeset = Item.changeset(item, %{title: String.reverse(item.title)})
    Repo.update(changeset)
    json(conn, %{id: item.id, title: item.title})
  end
end
