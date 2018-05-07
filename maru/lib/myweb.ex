#

defmodule Myweb.Repo do
  use Ecto.Repo, otp_app: :myweb
end

defmodule Myweb.Item do
  use Ecto.Schema

  import Ecto.Changeset

  schema "items" do
    field :title, :string
  end

  def changeset(person, params \\ %{}) do
    person
    |> cast(params, [:title])
  end
end

defmodule Myweb do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(Myweb.Repo, []),
      worker(Cachex, [:my_cache, []])
    ]

    opts = [strategy: :one_for_one, name: Myweb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Myweb.Apiv1 do
  alias Myweb.Repo
  alias Myweb.Item

  alias Plug.Conn

  use Maru.Router
  version 'v1'

  get "/json" do
    json(conn, %{hello: :world})
  end

  get "/get" do
    {_, v} = RedisPool.q({:global, :rds}, ["GET", "mydata"])
    text(conn, v)
  end

  get "/set" do
    {_, v} = RedisPool.q({:global, :rds}, ["SET", "uid", Conn.get_req_header(conn, "x-request-id")])
    text(conn, "world")
  end

  get "/ets_set" do
    {_, v} = Cachex.set(:my_cache, "testkey", "hello,world.")
    text(conn, v)
  end

  get "/ets" do
    {_, v} = Cachex.get(:my_cache, "testkey")
    text(conn, v)
  end

  # get "/mc_set" do
  # {ok} = Memcachir.set("mykey", "hello,world.")
  # text(conn, "#{ok}")
  # end

  # get "/mc_get" do
  # {_, v} = Memcachir.get("mykey")
  # text(conn, "#{v}")
  # end

  get "/rest" do
    res = HTTPotion.get("http://twitter.com", [timeout: 60000])
    json(conn, %{size: String.length(res.body)})
  end

  get "/select" do
    item = Repo.get(Item, 1)
    json(conn, %{id: item.id, title: item.title})
  end

  get "/update" do
    item = Repo.get!(Item, 1)
    changeset = Item.changeset(item, %{title: String.reverse(item.title)})
    case Repo.update(changeset) do
      {:ok, item} ->
        json(conn, %{id: item.id, title: item.title})
      {:error, _result} ->
        conn
        |> put_status(404)
        |> text("not found, something error")
    end
  end
end
