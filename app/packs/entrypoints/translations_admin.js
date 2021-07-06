$(() => {
  const $search = $("#data_picker-autocomplete")
  const $results = $("#add-translations-results")
  const $template = $("template", $results)
  const $form = $search.parents("form")
  let xhr = null
  let currentSearch = ""

  $search.on("keyup", function () {
    currentSearch = $search.val()
  })

  $search.autoComplete({
    minChars: 2,
    cache: 0,
    source: function (term, response) {
      try {
        xhr.abort()
      } catch (exception) {
        xhr = null
      }

      const url = $form.attr("action")
      xhr = $.getJSON(url, $form.serializeArray(), function (data) {
        response(data)
      })
    },
    renderItem: function (item, search) {
      const sanitizedSearch = search.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&")
      const re = new RegExp(`(${sanitizedSearch.split(" ").join("|")})`, "gi")
      const modelId = item[0]
      const title = item[1]
      // The terms are already escaped but when they are rendered to a data
      // attribute, they get unescaped when those values are used. The only
      // character we need to replace is the ampersand
      const value = title.replace(/&/g, "&amp;")

      const val = `${title} - ${modelId}`
      return `<div class="autocomplete-suggestion" data-model-id="${modelId}" data-val="${value}">${val.replace(
        re,
        "<b>$1</b>",
      )}</div>`
    },
    onSelect: function (event, term, item) {
      const $suggestions = $search.data("sc")
      const modelId = item.data("modelId")
      const title = item.data("val")

      let template = $template.html()
      template = template.replace(
        new RegExp("{{translation_key}}", "g"),
        modelId,
      )
      template = template.replace(
        new RegExp("{{translation_term}}", "g"),
        title,
      )
      const $newRow = $(template)
      $("table tbody", $results).append($newRow)
      $results.removeClass("hide")

      // Add it to the autocomplete form
      const $field = $(`<input type="hidden" name="keys[]" value="${modelId}">`)
      $form.append($field)

      // Listen to the click event on the remove button
      $(".remove-translation-key", $newRow).on("click", function (ev) {
        ev.preventDefault()
        $newRow.remove()
        $field.remove()

        if ($("table tbody tr", $results).length < 1) {
          $results.addClass("hide")
        }
      })

      $search.val(currentSearch)
      setTimeout(function () {
        $(`[data-model-id="${modelId}"]`, $suggestions).remove()
        $suggestions.show()
      }, 20)
    },
  })
})
