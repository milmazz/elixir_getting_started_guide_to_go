# Elixir Lang Guides (EPUB format)

The idea behind this application is to offer an efficient way to transform
the [Elixir Lang guides][getting_started] into an EPUB document.

## How to start

```console
$ git clone https://github.com/milmazz/elixir_getting_started_guide_to_go
$ cd elixir_getting_started_guide_to_go
$ mix deps.get
$ mix escript.build
$ ./elixir_lang_guide path/to/elixir-lang.github.com
```

## More options via command line

If you need more information about the command line options, please use the
`./elixir_lang_guide --help`:

  * `-g`, `--guide` - Guide that you want to convert, options:
    `getting_started`, `meta` or `mix_otp`, default: `getting_started`
  * `-h`, `--help` - Show help information
  * `-o`, `--output` - Output directory for the EPUB document, default: `doc`
  * `-s`, `--scripts` - List of custom JS files to include in the EPUB
    document
  * `-c`, `--styles` - List of custom CSS files to include in the EPUB
    document
  * `-v`, `--version` - Show version

[getting_started]: http://elixir-lang.org/getting-started/
