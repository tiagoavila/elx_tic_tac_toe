defmodule ElxTicTacToeWeb.PageControllerTest do
  use ElxTicTacToeWeb.ConnCase

  @tag skip: true
  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Peace of mind from prototype to production"
  end
end
