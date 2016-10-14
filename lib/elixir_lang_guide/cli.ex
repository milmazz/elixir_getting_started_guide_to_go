defmodule ElixirLangGuide.CLI do
  @shortdoc "CLI interface to convert Elixir Guides to EPUB format"

  @moduledoc """
  Uses `ElixirLangGuide.run/1` to generate an EPUB document from the given Elixir
  Guide, by default, this program takes the "Getting Started" guide as input.

  ## Command line options

    * `--guide`, `-g` - Guide that you want to process, options: `getting_started`,
      `meta` or `mix_otp`, default: `getting_started`
    * `--help`, `-h` - Show help
    * `--output`, `-o` - Output directory for the EPUB document, default: `doc`
    * `--scripts`, `-s` - List of custom JS files to include in the EPUB document
    * `--styles`, `-c` - List of custom CSS files to include in the EPUB document
    * `--version`, `-v` - Show version
  """

  @help_message """
  usage:

      elixir_lang_guide SITE_ROOT

  Convert the Elixir Lang Guides to EPUB format. By default the "Getting Started"
  is converted, but, you can pass parameter to choose the "Meta-programming with
  Elixir" or "Mix and OTP" guides.
  """

  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  defp parse_args(args) do
    switches = [help: :boolean, scripts: :keep, styles: :keep, version: :boolean]
    aliases = [g: :guide, h: :help, o: :output, v: :version]

    parse = OptionParser.parse(args, switches: switches, aliases: aliases)

    case parse do
      {[{opts, true}], _, _} -> opts
      {opts, [root_dir], []} -> {:run, root_dir, opts}
      _ -> :help
    end
  end

  defp process(:help) do
    IO.puts(@help_message)
  end

  defp process(:version) do
    IO.puts "ElixirLangGuide v#{ElixirLangGuide.version()}"
  end

  defp process({:run, root_dir, _opts}) do
    opts = %ElixirLangGuide.Config{
      root_dir: root_dir
    }
    ElixirLangGuide.to_epub(opts)
  end
end
