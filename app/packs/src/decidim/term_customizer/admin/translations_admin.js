/* eslint-disable import/no-unresolved */
import AutoComplete from "src/decidim/refactor/moved/autocomplete";

$(() => {
  const searchInput = document.getElementById("tc-autocomplete");
  const resultsElement = document.getElementById("add-translations-results");
  const template = resultsElement.querySelector("template");
  const form = searchInput.closest("form");
  const searchUrl = new URL(form.getAttribute("action"), window.location.origin);
  let currentSearch = "";
  let selectedTerms = [];

  // Prevent accidental submit on the autocomplete field
  form.addEventListener("submit", (ev) => ev.preventDefault());

  const dataSource = (query, callback) => {
    const baseParams = Object.fromEntries(searchUrl.searchParams.entries());
    const params = new URLSearchParams({ ...baseParams, term: query });
    fetch(`${searchUrl.pathname}?${params.toString()}`, {
      method: "GET",
      headers: { "Content-Type": "application/json" }
    }).then((response) => response.json()).then((data) => {
      callback(data);
    });
  };

  const parseHtml = (html) => new DOMParser().parseFromString(html, "text/html");

  const LIST_MARK = "\uE000";

  const toLines = (html) => {
    let doc = parseHtml(html);

    if ((/<\/?[a-z][^>]*>/i).test(doc.body.textContent)) {
      doc = parseHtml(doc.body.textContent);
    }

    doc.body.querySelectorAll("ul, ol").forEach((el) => {
      el.before("\n");
      el.after("\n");
    });

    doc.body.querySelectorAll("li").forEach((el) => el.prepend(LIST_MARK));
    doc.body.querySelectorAll("li, p, br, div").forEach((el) => el.after("\n"));

    return doc.body.textContent.
      split("\n").
      map((line) => {
        const list = line.includes(LIST_MARK);
        return { text: line.replaceAll(LIST_MARK, "").replace(/\s+/g, " ").trim(), list };
      }).
      filter(({ text }) => text.length > 0);
  };

  const HTML_ESCAPES = {
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;"
  };

  const escapeHtml = (text) => text.replace(/[&<>"]/g, (char) => HTML_ESCAPES[char]);

  const highlight = (text, search) => {
    if (!search) {
      return escapeHtml(text);
    }

    const re = new RegExp(`(${search})`, "gi");

    return text.split(re).map((part, index) => {
      const safe = escapeHtml(part);
      return index % 2 === 1
        ? `<strong class="search-highlight">${safe}</strong>`
        : safe;
    }).join("");
  };

  const renderLine = (text, css, search) => `<span class="${css}">${highlight(text, search)}</span>`;

  const renderResult = (lines, key, search) => {
    const parts = [];
    let group = null;

    const flush = () => {
      if (group) {
        parts.push(`<span class="tc-result-list">${group.join("")}</span>`);
        group = null;
      }
    };

    lines.forEach(({ text, list }) => {
      const html = renderLine(text, "tc-result-line", search);

      if (list) {
        group = group || [];
        group.push(html);
      } else {
        flush();
        parts.push(html);
      }
    });

    if (key) {
      const keyHtml = renderLine(key.text, "tc-result-line tc-result-key", search);
      if (group) {
        group.push(keyHtml);
      } else {
        parts.push(keyHtml);
      }
    }

    flush();
    return parts.join("");
  };

  // Just to avoid the "no-new" ESLint issue, wrap this in a function
  const initiate = () => {
    const config = JSON.parse(searchInput.dataset.autocomplete);

    return new AutoComplete(searchInput, {
      name: searchInput.getAttribute("name"),
      placeholder: searchInput.getAttribute("placeholder"),
      searchPrompt: true,
      searchPromptText: config.searchPromptText,
      threshold: 3,
      dataMatchKeys: ["label"],
      modifyResult: (item, valueItem) => {
        const sanitizedSearch = currentSearch.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
        const lines = toLines(valueItem.label);

        const last = lines[lines.length - 1];
        const key = last && last.text === `(${valueItem.value})`
          ? lines.pop()
          : null;

        item.innerHTML = renderResult(lines, key, sanitizedSearch);
        item.dataset.value = valueItem.value;
      },
      dataSource
    });
  };

  const ac = initiate();

  searchInput.addEventListener("keyup", () => {
    currentSearch = searchInput.value;
  });
  // Method for hiding the currently selected items
  const hideSelectedItems = () => {
    const resultsList = searchInput.nextSibling;
    for (const resultItem of resultsList.querySelectorAll("li")) {
      if (selectedTerms.indexOf(resultItem.dataset.value) < 0) {
        resultItem.classList.remove("hide");
      } else {
        resultItem.classList.add("hide");
      }
    }
  };

  // Currently not possible in Decidim to get notified when the list is
  // modified, so hack it with a MutationObserver.
  // Create an observer instance linked to the callback function
  const observer = new MutationObserver(() => {
    hideSelectedItems();
  });
  observer.observe(searchInput.nextSibling, { childList: true });

  // Hide the already selected items when the input is opened
  // Handle the selection of an item
  searchInput.addEventListener("selection", (ev) => {
    const selection = ev.detail.selection;
    const selectedItem = selection.value;
    const newRow = template.content.cloneNode(true).querySelector("tr");

    const label = escapeHtml(toLines(selectedItem.label).map(({ text }) => text).join(" "));
    newRow.innerHTML = newRow.innerHTML.
      replace(/{{translation_key}}/g, () => escapeHtml(selectedItem.value)).
      replace(/{{translation_term}}/g, () => label);

    const targetTable = resultsElement.querySelector("table tbody");
    targetTable.appendChild(newRow);
    resultsElement.classList.remove("hide");

    // Add it to the selected elements and hide the selected item
    selectedTerms.push(selectedItem.value);
    hideSelectedItems();

    // Listen to the click event on the remove button
    newRow.querySelector(".remove-translation-key").addEventListener("click", (removeEv) => {
      removeEv.preventDefault();
      newRow.parentNode.removeChild(newRow);
      selectedTerms = selectedTerms.filter((item) => item !== selectedItem.value);
      hideSelectedItems();

      if (targetTable.querySelectorAll("tr").length < 1) {
        resultsElement.classList.add("hide");
      }
    });
    setTimeout(() => {
      ac.autocomplete.open();
    }, 0)
  });

  document.addEventListener("click", (event) => {
    if (!searchInput.nextSibling.contains(event.target)) {
      setTimeout(() => {
        ac.autocomplete.close();
      }, 0)
    }
  });
});
