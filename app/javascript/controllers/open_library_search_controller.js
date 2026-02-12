import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];
  static values = { url: String };

  connect() {
    this.abortController = null;
    this.timer = null;
  }

  disconnect() {
    this._clearTimer();
    this._abort();
  }

  search() {
    const q = this.inputTarget.value.trim();

    if (q.length < 3) {
      this._renderEmpty("Digite pelo menos 3 caracteres...");
      return;
    }

    this._clearTimer();
    this.timer = setTimeout(() => this._fetchResults(q), 250);
  }

  async _fetchResults(q) {
    this._abort();
    this.abortController = new AbortController();

    try {
      this._renderLoading();

      const resp = await fetch(`${this.urlValue}?query=${encodeURIComponent(q)}`, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      });

      if (!resp.ok) {
        this._renderEmpty("Erro ao buscar no acervo.");
        return;
      }

      const data = await resp.json();
      const results = Array.isArray(data.results) ? data.results : [];
      this._renderResults(results);
    } catch (e) {
      if (e.name === "AbortError") return;
      this._renderEmpty("Falha na busca. Tente novamente.");
    }
  }

  select(event) {
    const item = event.currentTarget;
    const payload = item.dataset.payload;

    if (!payload) return;

    const book = JSON.parse(payload);

    const params = new URLSearchParams();
    if (book.title) params.set("title", book.title);
    if (book.author) params.set("author", book.author);
    if (book.published_year) params.set("published_year", book.published_year);
    if (book.isbn) params.set("isbn", book.isbn);
    if (book.image_url) params.set("image_url", book.image_url);

    window.location.href = `/books/new?${params.toString()}`;
  }

  _renderLoading() {
    this.resultsTarget.innerHTML = `<div class="result-item muted">Buscando...</div>`;
    this.resultsTarget.classList.add("active");
  }

  _renderEmpty(message) {
    this.resultsTarget.innerHTML = `<div class="result-item muted">${message}</div>`;
    this.resultsTarget.classList.add("active");
  }

  _renderResults(results) {
    if (!results.length) {
      this._renderEmpty("Nenhum resultado encontrado.");
      return;
    }

    this.resultsTarget.innerHTML = results
      .map((b) => {
        const safe = {
          title: b.title || "",
          author: b.author || "",
          published_year: b.published_year || "",
          isbn: b.isbn || "",
          image_url: b.image_url || ""
        };

        const label = `${safe.title}${safe.author ? " — " + safe.author : ""}${safe.published_year ? " (" + safe.published_year + ")" : ""}`;

        return `
          <button
            type="button"
            class="result-item"
            data-action="click->open-library-search#select"
            data-payload='${JSON.stringify(safe).replaceAll("'", "&apos;")}'>
            ${this._escapeHtml(label)}
          </button>
        `;
      })
      .join("");

    this.resultsTarget.classList.add("active");
  }

  _escapeHtml(str) {
    return String(str)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;");
  }

  _clearTimer() {
    if (this.timer) clearTimeout(this.timer);
    this.timer = null;
  }

  _abort() {
    if (this.abortController) this.abortController.abort();
    this.abortController = null;
  }
}
