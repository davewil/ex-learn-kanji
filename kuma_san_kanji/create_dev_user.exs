# Create development user for testing
# This script creates a test user for development and testing purposes

alias KumaSanKanji.Accounts.User
require Ash.Query

# Development user credentials
dev_email = "test@example.com"
dev_username = "testuser"
dev_password = "password123"

IO.puts("Creating development user...")
IO.puts("Email: #{dev_email}")
IO.puts("Username: #{dev_username}")
IO.puts("Password: #{dev_password}")

# Check if user already exists using proper Ash query
query = User |> Ash.Query.filter(email == ^dev_email)

case Ash.read(query) do
  {:ok, []} ->
    # User doesn't exist, create new one
    case User.sign_up(dev_email, dev_username, dev_password) do
      {:ok, user} ->
        IO.puts("✅ Development user created successfully!")
        IO.puts("User ID: #{user.id}")
        IO.puts("Email: #{user.email}")
        IO.puts("Username: #{user.username}")
        IO.puts("Joined at: #{user.joined_at}")
        IO.puts("")
        IO.puts("🔑 LOGIN CREDENTIALS:")
        IO.puts("Email: #{dev_email}")
        IO.puts("Password: #{dev_password}")

      {:error, error} ->
        IO.puts("❌ Failed to create development user:")
        IO.inspect(error)
    end

  {:ok, [existing_user]} ->
    IO.puts("ℹ️  Development user already exists!")
    IO.puts("User ID: #{existing_user.id}")
    IO.puts("Email: #{existing_user.email}")
    IO.puts("Username: #{existing_user.username}")
    IO.puts("")
    IO.puts("🔑 LOGIN CREDENTIALS:")
    IO.puts("Email: #{dev_email}")
    IO.puts("Password: #{dev_password}")

  {:error, error} ->
    IO.puts("❌ Error checking for existing user:")
    IO.inspect(error)
end
