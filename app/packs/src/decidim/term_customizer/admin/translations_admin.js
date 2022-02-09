$(() => {
  const $search = $("#data_picker-autocomplete");
  const $results = $("#add-translations-results");
  const $template = $("template", $results);
  const $form = $search.parents("form");
  let currentSearch = "";
  let selectedTerms = [];

  $search.on("keyup", function() {
    currentSearch = $search.val();
  });

  // Prevent accidental submit on the autocomplete field
  $form.on("submit", (ev) => ev.preventDefault());

  // jquery.autocomplete is calling this method which is apparently removed from
  // newer jQuery versions.
  $.isObject = $.isPlainObject; // eslint-disable-line id-length

  const customizeAutocomplete = (ac) => {
    const $ac = $(`#${ac.mainContainerId}`);
    const $acWrap = $("<div />");
    $ac.css({ top: "", left: "" });
    $acWrap.css({ position: "relative" });
    $acWrap.append($ac);

    // Move the element to correct position in the DOM to control its alignment
    // better.
    $search.after($acWrap);

    // Do not set the top and left CSS attributes on the element
    ac.fixPosition = () => {};

    // Hack the suggest method to exclude values that are already selected.
    ac.origSuggest = ac.suggest;
    ac.suggest = () => {
      // Filter out the selected items from the list
      ac.suggestions = ac.suggestions.filter((val) => !selectedTerms.includes(val));
      ac.data = ac.data.filter((val) => !selectedTerms.includes(val.value));

      return ac.origSuggest();
    };

    // Customize the onKeyPress to allow spaces because we do not want
    // selection to happen on space press.
    //
    // Original code at: https://git.io/JzjAM
    ac.onKeyPress = (ev) => {
      if (ac.disabled || !ac.enabled) {
        return;
      }

      switch (ev.keyCode) {
      case 27:
        // ESC
        ac.el.val(ac.currentValue);
        ac.hide();
        break;
      case 9:
      case 13:
        // TAB or RETURN
        if (ac.suggestions.length === 1) {
          ac.select(0)
        } else if (ac.selectedIndex === -1) {
          ac.hide();
          return;
        } else {
          ac.select(ac.selectedIndex);
        }
        if (ev.keyCode === 9) {
          return;
        }
        break;
      case 38:
        // UP
        ac.moveUp();
        break
      case 40:
        // DOWN
        ac.moveDown();
        break
      // DISABLED:
      // case 32:
      //   // SPACE
      //   if (ac.selectedIndex === -1) {
      //     break;
      //   }
      //   ac.select(ac.selectedIndex);
      //   break;
      default:
        return;
      }
      ev.stopImmediatePropagation();
      ev.preventDefault();
    }

    return ac;
  };

  // Customized methods for the autocomplete to add our hacks
  $.fn.tcAutocomplete = function(options) {
    $(this).each((_i, el) => {
      const $el = $(el);
      const ac = customizeAutocomplete($el.autocomplete(options));
      $el.data("autocomplete", ac);
    })
  };

  $search.tcAutocomplete({
    width: "100%",
    minChars: 2,
    noCache: true,
    serviceUrl: $form.attr("action"),
    delimiter: "||",
    deferRequestBy: 500,
    // Custom format result because of some weird bugs in the old version of the
    // jquery.autocomplete library.
    formatResult: (term, itemData) => {
      const sanitizedSearch = term.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
      const re = new RegExp(`(${sanitizedSearch})`, "gi");

      const value = `${itemData.value} - ${itemData.data}`;
      return value.replace(re, "<strong>$1</strong>");
    },
    onSelect: function(suggestion, itemData) {
      const modelId = itemData.data;
      const title = itemData.value;

      // Mark the term as selected
      selectedTerms.push(suggestion);

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
        selectedTerms = selectedTerms.filter((val) => val !== suggestion);

        if ($("table tbody tr", $results).length < 1) {
          $results.addClass("hide");
        }
      });

      $search.val(currentSearch);

      setTimeout(() => {
        $search.data("autocomplete").suggest();
      }, 20);
    }
  });
});
