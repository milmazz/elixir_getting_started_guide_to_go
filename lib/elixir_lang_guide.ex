defmodule ElixirLangGuide do

  @vsn Mix.Project.config[:version]

  defmodule Config do
    @moduledoc """
    Configuration structure with all the available options for `ElixirLangGuide`

    You can find more information about this options in the `ElixirLangGuide.CLI` module.
    """
    @homepage "http://elixir-lang.org"
    @scripts Path.expand(Path.wildcard("../assets/dist/app-*.js"))
    @styles Path.expand(Path.wildcard("../assets/dist/app-*.css"))

    defstruct [
      guide: "getting_started",
      homepage: @homepage,
      output: "doc",
      root_dir: nil,
      scripts: @scripts,
      styles: @styles
    ]

    @type t :: %__MODULE__{
      guide: String.t,
      homepage: String.t,
      output: Path.t,
      root_dir: Path.t,
      scripts: [Path.t],
      styles: [Path.t]
    }
  end

  @spec to_epub(Config.t) :: String.t
  def to_epub(options) do
    ElixirLangGuide.EPUB.run(%Config{})
  end

  @spec version :: String.t
  def version, do: @vsn
end
