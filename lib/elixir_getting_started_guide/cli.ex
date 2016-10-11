defmodule ElixirGettingStartedGuide.CLI do
  @help_message """
  usage:

      elixir_getting_started_guide

  Convert Elixir Started Guide to EPUB.
  """

  def main(args) do
    args
    |> parse_args()
    |> process()
  end

  defp parse_args(args) do
    switches = [help: :boolean, version: :boolean]
    aliases = [h: :help, v: :version]

    parse = OptionParser.parse(args, switches: switches, aliases: aliases)
    case parse do
      {[{switch, true}], _, _} -> switch
      {[], [], []} -> :run
      _ -> :help
    end
  end

  defp process(:help) do
    IO.puts(@help_message)
  end

  defp process(:version) do
    {:ok, version} = :application.get_key(:elixir_getting_started_guide, :vsn)
    IO.puts(version)
  end

  defp process(:run) do
    ElixirGettingStartedGuide.run()
  end
end
