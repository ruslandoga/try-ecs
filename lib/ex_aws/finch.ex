defmodule ExAws.Request.Finch do
  @moduledoc false
  @behaviour ExAws.Request.HttpClient

  @impl true
  def request(method, url, body \\ nil, headers \\ [], http_opts \\ []) do
    req = Finch.build(method, url, headers, body)

    case Finch.request(req, E.Finch, http_opts) do
      {:ok, %Finch.Response{status: status, headers: headers, body: body}} ->
        {:ok, %{status_code: status, headers: headers, body: body}}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end
end
