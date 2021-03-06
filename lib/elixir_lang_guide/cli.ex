defmodule ElixirLangGuide.CLI do
  @shortdoc "CLI interface to convert Elixir Guides to EPUB format"

  @moduledoc """
  Convert the Elixir Lang Guides to EPUB format. By default the "Getting
  Started" is converted, but, you can pass parameter to choose the
  "Meta-programming with Elixir" or "Mix and OTP" guides.

  ## Command line options

    * `-g`, `--guide` - Guide that you want to convert, options:
      `getting_started`, `meta` or `mix_otp`, default: `getting_started`
    * `-h`, `--help` - Show help
    * `-o`, `--output` - Output directory for the EPUB document, default: `doc`
    * `-s`, `--scripts` - List of custom JS files to include in the EPUB
      document
    * `-c`, `--styles` - List of custom CSS files to include in the EPUB
      document
    * `-v`, `--version` - Show version
  """

  @spec main(OptionParser.argv) :: String.t
  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  defp parse_args(args) do
    switches = [help: :boolean, scripts: :keep, styles: :keep,
                version: :boolean]
    aliases = [g: :guide, h: :help, o: :output, v: :version]

    parse = OptionParser.parse(args, switches: switches, aliases: aliases)

    case parse do
      {[{opts, true}], _, _} -> opts
      {opts, [root_dir], []} -> {:run, root_dir, opts}
      _ -> :help
    end
  end

  defp process(:help) do
    {_, more_info} = Code.get_docs(__MODULE__, :moduledoc)
    usage = ~S"""
    Usage:
      elixir_lang_guide SITE_ROOT [OPTIONS]

    Examples:
      elixir_lang_guide ../elixir-lang.github.com
      elixir_lang_guide ../elixir-lang.github.com --guide "meta"

    """
    IO.puts usage <> more_info
  end

  defp process(:version) do
    IO.puts "ElixirLangGuide v#{ElixirLangGuide.version()}"
  end

  defp process({:run, root_dir, opts}) when is_binary(root_dir) and is_list(opts) do
    opts
    |> process_keep(:styles)
    |> process_keep(:scripts)
    |> Keyword.put(:root_dir, root_dir)
    |> ElixirLangGuide.to_epub()
    |> IO.puts()
  end

  defp process_keep(options, key) do
    values = Keyword.get_values(options, key)
    if values == [], do: options, else: Keyword.put(options, key, values)
  end
end
