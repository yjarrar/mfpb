defmodule MFPBWeb.IndexLive do
  use MFPBWeb, :live_view

  alias MFPB.Requests

  @impl true
  def render(assigns) do
    ~H"""
    <header class="py-8 bg-stone-800">
      <div class="text-center">
        <h1 class="text-5xl tracking-wide text-stone-50">mfpb</h1>
      </div>
    </header>
    <main class="container">
      <section class="text-center">
        <button class="font-bold my-8 px-8 py-3 border-2 border-stone-800 hover:bg-stone-800 hover:text-stone-50 rounded-xl text-xl transition-colors" phx-click="create" phx-throttle="1000">Create new bin</button>
      </section>
      <section class="max-w-prose mx-auto leading-relaxed text-lg">
        <p class="mb-3">
          <b>mfpb</b> is a simple tool used to inspect HTTP requests.
        </p>
        <p class="mb-3">
          It tries not to get in your way, it doesn't parse the body or do other
          fancy stuff with your request. This way you see exactly what was sent.
          The idea is basically having the same output you would get by doing HTTP
          requests to a listening instance of <code class="bg-neutral-200 px-1 ml-1">netcat</code>.
        </p>
        <p class="mb-3">
          Under the hood it uses the super cool
          <a target="_blank" href="https://github.com/phoenixframework/phoenix_live_view">Phoenix Live View</a>,
          so new requests are prepended at the top of the page without the need of
          refreshing.
        </p>
        <p class="mb-3">
          You can find the source <a target="_blank" href="https://github.com/rbino/mfpb">on Github</a>.
        </p>
      </section>
    </main>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("create", _params, socket) do
    case Requests.create_new_bin() do
      {:ok, bin_id} ->
        {:noreply, push_redirect(socket, to: "/b/#{bin_id}")}

      :error ->
        # TODO: handle this
        {:noreply, socket}
    end
  end
end
