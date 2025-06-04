defmodule KumaSanKanji.Accounts.User do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshSqlite.DataLayer

  attributes do
    uuid_primary_key :id
    attribute :email, :ci_string, allow_nil?: false
    attribute :hashed_password, :string, allow_nil?: false, sensitive?: true
    attribute :username, :string, allow_nil?: false
    attribute :joined_at, :utc_datetime, default: &DateTime.utc_now/0
  end

  actions do
    defaults [:create, :read, :update, :destroy]

    create :sign_up do
      accept [:email, :username]
      argument :password, :string, allow_nil?: false, sensitive?: true

      change &__MODULE__.validate_password_length/2
      change &__MODULE__.hash_password/2
    end

    action :login, :struct do
      constraints instance_of: __MODULE__
      argument :email, :ci_string, allow_nil?: false
      argument :password, :string, allow_nil?: false, sensitive?: true

      run fn input, _context ->
        require Ash.Query
        query = Ash.Query.filter(__MODULE__, email: input.arguments.email)
        case Ash.read_one(query) do
          {:ok, user} when not is_nil(user) ->
            if Pbkdf2.verify_pass(input.arguments.password, user.hashed_password) do
              {:ok, user}
            else
              {:error, :invalid_password}
            end
          _ ->
            {:error, :invalid_email}
        end
      end
    end
  end

  code_interface do
    define :get_by_email, args: [:email], action: :read
    define :sign_up, args: [:email, :username, :password], action: :sign_up
    define :login, args: [:email, :password], action: :login
  end

  # Custom validation function
  def validate_password_length(changeset, _context) do
    password = Ash.Changeset.get_argument(changeset, :password)

    if password && String.length(password) < 8 do
      Ash.Changeset.add_error(changeset, :password, "must be at least 8 characters")
    else
      changeset
    end
  end

  # Custom validation function for login
  def validate_password(changeset, _context) do
    password = Ash.Changeset.get_argument(changeset, :password)
    hashed_password = Ash.Changeset.get_attribute(changeset, :hashed_password)

    if Pbkdf2.verify_pass(password, hashed_password) do
      changeset
    else
      changeset = Ash.Changeset.add_error(changeset, :password, "is incorrect")
      %{changeset | valid?: false}
    end
  end

  # Custom change function
  def hash_password(changeset, _context) do
    password = Ash.Changeset.get_argument(changeset, :password)

    if password do
      hashed_password = Pbkdf2.hash_pwd_salt(password)
      Ash.Changeset.change_attribute(changeset, :hashed_password, hashed_password)
    else
      changeset
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  sqlite do
    table "users"
    repo KumaSanKanji.Repo
  end
end
