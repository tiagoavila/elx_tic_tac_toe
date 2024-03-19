defmodule ElxTicTacToeWeb.ErrorHTMLTest do
  use ElxTicTacToeWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  @tag skip: true
  test "renders 404.html" do
    assert render_to_string(ElxTicTacToeWeb.ErrorHTML, "404", "html", []) == "Not Found"
  end

  @tag skip: true
  test "renders 500.html" do
    assert render_to_string(ElxTicTacToeWeb.ErrorHTML, "500", "html", []) ==
             "Internal Server Error"
  end
end
