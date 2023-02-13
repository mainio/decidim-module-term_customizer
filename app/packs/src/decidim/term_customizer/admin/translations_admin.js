import AutoComplete from "src/decidim/autocomplete";

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
        const re = new RegExp(`(${sanitizedSearch})`, "gi");
        const replacedText = item.textContent.replace(re, '<strong class="search-highlight">$1</strong>');
        item.innerHTML = replacedText;
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
    newRow.innerHTML = newRow.innerHTML.replace(new RegExp("{{translation_key}}", "g"), selectedItem.value);
    newRow.innerHTML = newRow.innerHTML.replace(new RegExp("{{translation_term}}", "g"), selectedItem.label);

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
