$(() => {
  const $search = $("#data_picker-autocomplete");
  const $results = $("#add-translations-results");
  const $template = $("template", $results);
  const $form = $search.parents("form");
  // let xhr = null;
  let currentSearch = "";

  $search.on("keyup", function() {
    currentSearch = $search.val();
  });

  // Regexp copied from jquery.autocomplete
  const regEx = new RegExp(
    `(\\${["/", ".", "*", "+", "?", "|", "(", ")", "[", "]", "{", "}", "\\"].join("|\\")})`,
    "g"
  );

  // console.log($search.autocomplete);
  const autocomplete = $search.autocomplete({
    minChars: 2,
    noCache: true,
    serviceUrl: $form.attr("action"),
    // Custom format result because of some weird bugs in the old version of the
    // jquery.autocomplete library.
    formatResult: (_term, itemData) => {
      const value = itemData.value;
      const pattern = `(${value.replace(regEx, "\\$1")})`;
      return value.replace(new RegExp(pattern, "gi"), "<strong>$1</strong>");
    },
    // renderItem: function (item, search) {
    //   const sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
    //   const re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi");
    //   const modelId = item[0];
    //   const title = item[1];
    //   // The terms are already escaped but when they are rendered to a data
    //   // attribute, they get unescaped when those values are used. The only
    //   // character we need to replace is the ampersand
    //   const value = title.replace(/&/g, "&amp;");

    //   const val = `${title} - ${modelId}`;
    //   return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${value}">${val.replace(re, "<b>$1</b>")}</div>`;
    // },
    onSelect: function(_suggestion, itemData) {
      const modelId = itemData.data;
      const title = itemData.value;

      let template = $template.html();
      template = template.replace(new RegExp("{{translation_key}}", "g"), modelId);
      template = template.replace(new RegExp("{{translation_term}}", "g"), title);
      const $newRow = $(template);
      $("table tbody", $results).append($newRow);
      $results.removeClass("hide");

      // Add it to the autocomplete form
      const $field = $(`<input type="hidden" name="keys[]" value="${modelId}">`);
      $form.append($field);

      // Listen to the click event on the remove button
      $(".remove-translation-key", $newRow).on("click", function(ev) {
        ev.preventDefault();
        $newRow.remove();
        $field.remove();

        if ($("table tbody tr", $results).length < 1) {
          $results.addClass("hide");
        }
      });

      $search.val(currentSearch);

      setTimeout(() => {
        autocomplete.suggest();
      }, 20);
      // Reopen the autocomplete results
      // setTimeout(function() {
      //   $(`[data-model-id="${modelId}"]`, $suggestions).remove();
      //   $suggestions.show();
      // }, 20);
    }
  });
});
