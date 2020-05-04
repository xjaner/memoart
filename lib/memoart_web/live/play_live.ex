defmodule MemoartWeb.PlayLive do
  use MemoartWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h3>Juga al Memoart!</h3>
    <div class="container">
    <table class="board">
    <tr>
    <td class="card">
    <!-- <div class="flip-container" ontouchstart="this.classList.toggle('hover');"> -->
    <div class="flip-container">
    <div class="flipper">
    <div class="front">
    <a href="#" phx-click="a1"></a>
    </div>
    <div class="back" id="back-a1">
    </div>
    </div>
    </div>

    </td>
    <td class="card">
    <div class="flip-container" id="flip-toggle">
    <div class="flipper">
    <div class="front">
    <a href="#" phx-click="a2"></a>
    </div>
    <div class="back" id="back-a2">
    </div>
    </div>
    </div>
    <button onclick="document.querySelector('#flip-toggle').classList.toggle('hover');" class="sexyButton">Toggle Flip</button>
    </td>
    <td class="card">A3</td>
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

  def handle_event("a" <> card_id, _, socket) do
    IO.puts("A#{card_id}!!!!")
    {:noreply, socket}
  end
end
