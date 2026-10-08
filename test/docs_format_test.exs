defmodule ColorWheel.DocsFormatTest do
  use ExUnit.Case, async: true

  # Every public module, so a new one only has to be added here.
  @modules [ColorWheel, ColorWheel.Color, ColorWheel.Palettes]

  # A markdown ATX heading must start at column 0: ExDoc parses docs with
  # Earmark, which does not accept the leading spaces CommonMark allows. Because
  # `@doc` heredocs here close at two spaces, a heading written with three
  # spaces keeps a single leading space after Elixir dedents the heredoc, and
  # then renders as the literal text `## Examples` instead of a heading.
  #
  # One to three spaces cannot be inside an indented code block (that needs
  # four), so any match here is a heading that will not render.
  @indented_heading ~r/^ {1,3}#/

  test "no documented heading is indented" do
    for module <- @modules, {signature, text} <- docs(module) do
      offending =
        text
        |> String.split("\n")
        |> Enum.filter(&Regex.match?(@indented_heading, &1))

      assert offending == [],
             "#{inspect(module)}#{signature} has indented markdown headings that " <>
               "render as literal text: #{inspect(offending)}"
    end
  end

  # Returns {signature, doc_text} for the module doc and every documented
  # function/macro, skipping entries that carry no documentation.
  defp docs(module) do
    {:docs_v1, _, _, _, module_doc, _, docs} = Code.fetch_docs(module)

    [{".(module doc)", module_doc} | Enum.map(docs, &entry/1)]
    |> Enum.flat_map(fn {signature, doc} ->
      case doc_text(doc) do
        nil -> []
        text -> [{signature, text}]
      end
    end)
  end

  defp entry({{_kind, name, arity}, _, _, doc, _}), do: {".#{name}/#{arity}", doc}

  defp doc_text(%{"en" => text}), do: text
  defp doc_text(text) when is_binary(text), do: text
  defp doc_text(_other), do: nil
end
