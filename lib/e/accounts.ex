defmodule E.Accounts do
  @moduledoc "User accounts context."

  defmodule User do
    @moduledoc false
    use Ecto.Schema

    @type t :: %__MODULE__{
            name: String.t(),
            email: String.t(),
            inserted_at: NaiveDateTime.t(),
            updated_at: NaiveDateTime.t()
          }

    @primary_key false
    schema "users" do
      field(:name, :string)
      field(:email, :string)

      timestamps()
    end
  end

  import E.Cluster, only: [primary_rpc: 3]

  alias E.Repo
  alias Ecto.Changeset

  @doc "Saves user to DB in primary region"
  @spec save_user(%{name: String.t(), email: String.t()}) ::
          {:ok, User.t()} | {:error, Changeset.t()}
  def save_user(params) do
    primary_rpc(__MODULE__, :local_save_user, [params])
  end

  @doc false
  @spec local_save_user(%{name: String.t(), email: String.t()}) ::
          {:ok, User.t()} | {:error, Changeset.t()}
  def local_save_user(params) do
    %User{}
    |> Changeset.cast(params, [:name, :email])
    |> Repo.insert()
  end

  @doc "Lists all users from local DB"
  @spec list_users :: [User.t()]
  def list_users do
    Repo.all(User)
  end
end
