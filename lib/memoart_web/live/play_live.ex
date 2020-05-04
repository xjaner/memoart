defmodule MemoartWeb.PlayLive do
  use MemoartWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, :a1flip, "front")
    socket = assign(socket, :a2flip, "")
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h3>Juga al Memoart!</h3>
    <div class="container">
    <table class="board">
    <tr>
    <td class="card">
    <div class="flip-container">
    <div class="flipper">
    <div class="<%= @a1flip %>">
    <a href="#" phx-click="a1"></a>
    </div>
    </div>
    </div>

    </td>
    <td class="card">
    <div class="flip-container <%= @a2flip %>">
    <div class="flipper">
    <div class="front">
    <a href="#" phx-click="a2"></a>
    </div>
    <div class="back" id="back-a2">
    <a href="#" phx-click="a2"></a>
    </div>
    </div>
    </div>
    </td>
    <td class="card">

    <div class="flip-container">
    <div class="flipper">
    <!--<div class="front">-->
    <div class="<%= @a1flip %>">
    <a href="#" phx-click="a1"></a>
    </div>
    <!--<div class="back" id="back-a1">
    </div>-->
    </div>
    </div>

    </td>
    <td class="card">A4</td>
    <td class="card">A5</td>
    </tr>
    <tr>
    <td class="card">B1</td>
    <td class="card">B2</td>
    <td class="card">B3</td>
    <td class="card">B4</td>
    <td class="card">B5</td>
    </tr>
    <tr>
    <td class="card">C1</td>
    <td class="card">C2</td>
    <td class="card">C3</td>
    <td class="card">C4</td>
    <td class="card">C5</td>
    </tr>
    <tr>
    <td class="card">D1</td>
    <td class="card">D2</td>
    <td class="card">D3</td>
    <td class="card">D4</td>
    <td class="card">D5</td>
    </tr>
    <tr>
    <td class="card">E1</td>
    <td class="card">E2</td>
    <td class="card">E3</td>
    <td class="card">E4</td>
    <td class="card">E5</td>
    </tr>
    </table>
    </div>
    """
  end

  def handle_event("a2", _, socket) do
    new_class = case socket.assigns.a2flip do
      "" -> "g"
      "g" -> "hover"
      _ -> ""
    end
    IO.puts("A2 - a2flip:#{socket.assigns.a2flip} --> #{new_class}")
    socket = assign(socket, :a2flip, new_class)
    {:noreply, socket}
  end

  def handle_event("a" <> card_id, _, socket) do
    new_class = case socket.assigns.a1flip do
      "front" -> "back"
      _ -> "front"
    end
    IO.puts("A#{card_id} - a1flip:#{socket.assigns.a1flip}")
    socket = assign(socket, :a1flip, new_class)
    {:noreply, socket}
  end
end
