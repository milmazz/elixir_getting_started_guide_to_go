defmodule ElixirGettingStartedGuide do
  require EEx

  @app Mix.Project.config[:app]
  @docs "doc"
  @homepage "http://elixir-lang.org"
  @scripts Path.wildcard(Application.app_dir(@app, "priv/dist/app-*.js"))
  @styles Path.wildcard(Application.app_dir(@app, "priv/dist/app-*.css"))
  @submodule "priv/elixir-lang.github.com"

  def run(options \\ [guide: :getting_started]) do
    if File.exists?(@docs) do
      File.rm_rf(@docs)
      File.mkdir_p(@docs)
    end

    nav =
      @app
      |> Application.app_dir("#{@submodule}/_data/getting-started.yml")
      |> YamlElixir.read_from_file()
      |> generate_nav(options)

    nav |> convert_markdown_pages() |> to_epub(nav, options)
  end

  defp generate_nav(yaml, options) do
    yaml =
      case options[:guide] do
        :mix_otp -> Enum.at(yaml, 1)
        :meta -> List.last(yaml)
        _ -> List.first(yaml)
      end

    Enum.flat_map(List.wrap(yaml), fn(section) ->
      Enum.map(section["pages"], fn(%{"slug" => slug, "title" => title}) ->
        %{id: slug, label: title, content: "#{slug}.xhtml", dir: section["dir"],
          scripts: @scripts, styles: @styles}
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
    content =
      "#{@submodule}#{dir}#{path}"
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

  defp to_epub(files, nav, options) do
    title =
      case options[:guide] do
        :mix_otp -> "Mix and OTP"
        :meta -> "Meta-programming in Elixir"
        _ -> "Elixir Getting Started Guide"
      end

    config = %BUPE.Config{
      title: title,
      creator: "Plataformatec",
      unique_identifier: title_to_filename(title),
      source: "#{@homepage}/getting-started/",
      files: files,
      scripts: @scripts,
      styles: @styles,
      nav: nav
    }

    BUPE.build(config, "#{title_to_filename(title)}.epub")
  end

  defp title_to_filename(title) do
    title |> String.replace(" ", "-") |> String.downcase()
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
