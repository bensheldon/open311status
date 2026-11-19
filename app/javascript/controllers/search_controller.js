import { Controller } from "@hotwired/stimulus"

// Not bundled by Vite: the site serves the Pagefind index and its loader.
const PAGEFIND_URL = "/pagefind/pagefind.js"

// Searches the Pagefind index in /pagefind (built by config/pagefind.rb)
// for the `q` URL parameter, and shows the results.
export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    const query = (new URLSearchParams(window.location.search).get("q") || "").trim()
    this.inputTarget.value = query
    if (query) {
      this.resultsTarget.innerHTML = "<p><em>Searching…</em></p>"
      this.#search(query)
    }
  }

  async #search(query) {
    try {
      const pagefind = await import(/* @vite-ignore */ PAGEFIND_URL)
      const search = await pagefind.search(query)
      const results = await Promise.all(search.results.slice(0, 50).map((result) => result.data()))
      this.resultsTarget.innerHTML = this.#render(query, search.results.length, results)
    } catch (error) {
      console.error(error)
      this.resultsTarget.innerHTML = "<p>Search is not available.</p>"
    }
  }

  #render(query, total, results) {
    if (!results.length) return `<p>No service requests found for “${escapeHTML(query)}”.</p>`

    const items = results.map((item) => `
      <li class="list-group-item">
        <a href="${escapeHTML(item.url)}" class="fw-bold">${escapeHTML(item.meta.title)}</a>
        <div class="small text-body-secondary">${escapeHTML(item.meta.city)}${item.meta.requested ? ` · ${escapeHTML(item.meta.requested)}` : ""}</div>
        <p class="mb-0">${item.excerpt}</p>
      </li>`).join("")
    const count = total > results.length ? `Showing ${results.length} of ${total} results` : `${total} ${total === 1 ? "result" : "results"}`
    return `<p>${count}</p><ul class="list-group">${items}</ul>`
  }
}

function escapeHTML(value) {
  const div = document.createElement("div")
  div.textContent = value ?? ""
  return div.innerHTML.replaceAll('"', "&quot;")
}
