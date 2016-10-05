defmodule ElixirGettingStartedGuide do
  require EEx

  @docs "doc"
  @homepage "http://elixir-lang.org"
  @submodule "priv/elixir-lang.github.com"

  def run do
    if File.exists?(@docs) do
        File.rm_rf(@docs)
        File.mkdir_p(@docs)
    end

    nav = Mix.Project.config[:app]
    |> Application.app_dir("#{@submodule}/_data/getting-started.yml")
    |> YamlElixir.read_from_file()
    |> generate_nav()

    nav
    |> convert_markdown_pages()
    |> to_epub(nav)
  end

  defp generate_nav(yaml) do
    # Take the "getting started" section for now
    yaml = yaml |> List.first() |> List.wrap()
    Enum.flat_map(yaml, fn(section) ->
      Enum.map(section["pages"], fn(%{"slug" => slug, "title" => title}) ->
        %{id: slug, label: title, content: "#{slug}.xhtml", dir: section["dir"]}
      end)
    end)
  end

  defp convert_markdown_pages(config) do
    config
    |> Enum.map(&Task.async(fn ->
          to_xhtml(&1)
       end))
    |> Enum.map(&Task.await(&1, :infinity))
  end

  defp to_xhtml(%{content: path, dir: dir} = nav) do
    content = "#{@submodule}#{dir}#{path}"
    |> String.replace(~r/(.*)\.xhtml/, "\\1.markdown")
    |> File.read!()
    |> clean_markdown()
    |> Markdown.to_html(autolink: true, fenced_code: true, tables: true)
    |> wrap_html(nav)

    unless File.exists?(Path.join(@docs, dir)) do
      File.mkdir_p(Path.join(@docs, dir))
    end

    file_path = "#{@docs}#{dir}#{path}"
    File.write!(file_path, content)
    file_path
  end

  defp to_epub(files, nav) do
    config = %BUPE.Config{
      title: "Elixir Getting Started Guide",
      creator: "Plataformatec",
      unique_identifier: "Elixir",
      files: files,
      nav: nav
    }

    BUPE.build(config, "elixir-getting-started.epub")
  end

  defp clean_markdown(content) do
    content
    |> String.replace("{% include toc.html %}", "")
    |> String.replace(~r/# {{ page.title }}(<span hidden>.<\/span>)?/, "") # The <span hidden>.</span> is a hack used in pattern-matching.md
    |> remove_frontmatter()
    |> map_links()
  end

  defp remove_frontmatter(content) do
    [_frontmatter, content] = String.split(content, ~r/\r?\n---\r?\n/, parts: 2)
    content
  end

  defp map_links(content) do
    Regex.replace(~r/\[([^\]]+)\]\(([^\)]+)\)/, content, fn(_, text, href) ->
      case URI.parse(href) do
        %URI{scheme: nil, path: "/getting-started/meta/" <> path } ->
          "[#{text}](#{@homepage}/getting-started/meta/#{path})"
        %URI{scheme: nil, path: "/getting-started/mix-otp/" <> path } ->
          "[#{text}](#{@homepage}/getting-started/mix-otp/#{path})"
        %URI{scheme: nil, path: "/getting-started/" <> path } ->
          "[#{text}](#{String.replace(path, "html", "xhtml")})"
        %URI{scheme: nil, path: "/" <> path } ->
          "[#{text}](#{@homepage}/#{path})"
        _ ->
          "[#{text}](#{href})"
      end
    end)
  end

  EEx.function_from_file(:defp, :wrap_html,
                         Path.expand("elixir_getting_started_guide/templates/page.eex", __DIR__),
                         [:content, :config])
end
