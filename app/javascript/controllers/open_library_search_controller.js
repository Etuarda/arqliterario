import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];
  static values = {
    url: String,
    minChars: Number,
    debounceMs: Number,
  };

  connect() {
    this.timeout = null;
    this.handleOutsideClick = this.handleOutsideClick.bind(this);

    document.addEventListener("click", this.handleOutsideClick);
    this.inputTarget.addEventListener("input", (e) => this.onInput(e));
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick);
  }

  onInput(e) {
    const query = (e.target.value || "").trim();

    clearTimeout(this.timeout);

    if (query.length < (this.minCharsValue || 3)) {
      this.hideResults();
      return;
    }

    this.timeout = setTimeout(() => this.search(query), this.debounceMsValue || 350);
  }

  async search(query) {
    try {
      const resp = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`, {
        headers: { Accept: "application/json" },
      });

      if (!resp.ok) throw new Error("Falha ao buscar livros.");

      const books = await resp.json();
      this.renderResults(Array.isArray(books) ? books : []);
    } catch (_) {
      this.renderResults([]);
    }
  }

  renderResults(books) {
    this.resultsTarget.innerHTML = "";

    if (!books.length) {
      this.hideResults();
      return;
    }

    books.forEach((book) => {
      const item = document.createElement("div");
      item.className = "result-item";

      const title = book.title || "Sem título";
      const author = book.author || "Autor desconhecido";
      const year = book.published_year || "N/A";

      item.innerHTML = `
        <strong>${this.escapeHtml(title)}</strong>
        <br>
        <small>${this.escapeHtml(author)} (${this.escapeHtml(String(year))})</small>
      `;

      item.addEventListener("click", () => this.onSelect(book));
      this.resultsTarget.appendChild(item);
    });

    this.showResults();
  }

  onSelect(book) {
    const titleEl = document.getElementById("field-title");

    // Contexto: NEW/EDIT (tem form) -> preenche campos
    if (titleEl) {
      document.getElementById("field-title").value = book.title || "";
      document.getElementById("field-author").value = book.author || "";
      document.getElementById("field-year").value = book.published_year || "";
      document.getElementById("field-isbn").value = book.isbn || "";
      document.getElementById("field-image").value = book.image_url || "";

      this.inputTarget.value = "";
      this.inputTarget.placeholder = `Livro selecionado: ${book.title || ""}`;
      this.hideResults();
      return;
    }

    // Contexto: INDEX (não tem form) -> redireciona para NEW preenchido via params
    const params = new URLSearchParams({
      title: book.title || "",
      author: book.author || "",
      year: book.published_year || "",
      isbn: book.isbn || "",
      image_url: book.image_url || "",
    });

    window.location.href = `/books/new?${params.toString()}`;
  }

  handleOutsideClick(e) {
    if (!this.element.contains(e.target)) this.hideResults();
  }

  showResults() {
    this.resultsTarget.style.display = "block";
  }

  hideResults() {
    this.resultsTarget.style.display = "none";
  }

  escapeHtml(str) {
    return String(str)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#039;");
  }
}
