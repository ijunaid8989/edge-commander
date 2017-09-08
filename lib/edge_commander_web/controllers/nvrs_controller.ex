defmodule EdgeCommanderWeb.NvrsController do
  use EdgeCommanderWeb, :controller
  alias EdgeCommander.Devices.Nvr
  alias EdgeCommander.Repo
  alias EdgeCommander.Util
  import EdgeCommander.Devices, only: [update_nvr_ISAPI: 1]
  require IEx

  def create(conn, params) do
    changeset = Nvr.changeset(%Nvr{}, params)
    case Repo.insert(changeset) do
      {:ok, nvr} ->
        %EdgeCommander.Devices.Nvr{
          name: name,
          username: username,
          password: password,
          ip: ip,
          port: port,
          is_monitoring: is_monitoring
        } = nvr

        spawn(fn -> update_nvr_ISAPI(nvr) end)

        conn
        |> put_status(:created)
        |> json(%{
          "name" => name,
          "username" => username,
          "password" => password,
          "ip" => ip,
          "port" => port,
          "is_monitoring" => is_monitoring
        })
      {:error, changeset} ->
        errors = Util.parse_changeset(changeset)
        traversed_errors = for {_key, values} <- errors, value <- values, do: "#{value}"
        conn
        |> put_status(400)
        |> json(%{ errors: traversed_errors })
    end
  end
end
