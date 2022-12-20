defmodule PasswordGenerator do
  @moduledoc """
  Generate passwords.

  You can define the config in a config file or pass in the config to the
  functions.

  Note: Options passed into the function will override anything defined in config.
  """

  @default_rand_alg :exs1024
  @default_replacements %{"a" => "4", "e" => "3", "i" => "1", "o" => "0"}
  @default_separator "-"
  @default_word_count 4

  require Integer

  @doc """
  Generate a password.

  ## Options

   - `:adjectives` - The list of adjectives to select from.
   - `:nouns` - The list of nouns to select from.
   - `:separator` - The separator between words. Defaults to `"-"`.
   - `:words` - The number of words to use. Defaults to `4`.
   - `:rand_alg` - The random algorithm to use. Defaults to `:exs1024`.
   - `:seed` - The random seed to use. This could be used to get repeatable results.

  ## Example

      iex> generate(adjectives: ["purple"], nouns: ["people"])
      "purple-people-purple-people"

  """
  @spec generate(keyword()) :: String.t()
  def generate(opts \\ []) do
    config = Keyword.merge(config(), opts)
    separator = Keyword.get(config, :separator, @default_separator)
    max_words = Keyword.get(config, :words, @default_word_count)
    rand_alg = Keyword.get(config, :rand_alg, @default_rand_alg)
    seed = Keyword.get(config, :seed)
    adjectives = Keyword.fetch!(config, :adjectives)
    nouns = Keyword.fetch!(config, :nouns)

    seed_rand(seed, rand_alg)

    Enum.map_join(1..max_words, separator, fn
      count when Integer.is_even(count) -> Enum.random(nouns)
      count when Integer.is_odd(count) -> Enum.random(adjectives)
    end)
  end

  @doc """
  Generate a "secure" password using character replacement.

  ## Example

      iex> generate_secure(adjectives: ["purple"], nouns: ["people"])
      "purpl3-p30pl3-purpl3-p30pl3"

  """
  @spec generate_secure(keyword()) :: String.t()
  def generate_secure(opts \\ []) do
    opts
    |> generate()
    |> make_string_secure(opts)
  end

  @doc """
  Make a string "secure."

  ## Examples

      iex> make_string_secure("flying-goat-eloping-lizard")
      "fly1ng-g04t-3l0p1ng-l1z4rd"

      iex> replacements = %{"a" => "9", "e" => "8", "i" => "2", "o" => "5"}
      iex> make_string_secure("flying-goat-eloping-lizard", replacements: replacements)
      "fly2ng-g59t-8l5p2ng-l2z9rd"

  """
  @spec make_string_secure(String.t(), keyword()) :: String.t()
  def make_string_secure(insecure_string, opts \\ []) do
    replacements = Keyword.get(opts, :replacements, @default_replacements)
    String.replace(insecure_string, Map.keys(replacements), &Map.fetch!(replacements, &1))
  end

  defp seed_rand(nil, _rand_alg), do: nil
  defp seed_rand(seed, rand_alg), do: :rand.seed(rand_alg, seed)

  defp config, do: Application.get_env(:password_generator, __MODULE__)
end
