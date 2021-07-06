$(() => {
  const initConstraintFields = ($section) => {
    const $select = $("select.constraint-subject-selector", $section)
    const $modelSelect = $("select.constraint-subject-model-selector", $section)

    $select
      .on(
        "change init",

        /* @this HTMLElement */
        function () {
          const val = $(this).val()
          $("[data-manifest]", $section).hide()
          $(`[data-manifest="${val}"]`, $section).show()
        },
      )
      .trigger("init")

    $modelSelect
      .on(
        "change init",

        /* @this HTMLElement */
        function () {
          const $container = $(this).parents(".manifest-container")
          const val = $(this).val()
          $("[data-components]", $container).hide()
          $(`[data-components="${val}"]`, $container).show()
        },
      )
      .trigger("init")
  }

  $.fn.constraintSection = function () {
    $(this).each(
      /**
       * @this HTMLElement
       * @return {void}
       */
      function () {
        const $section = $(this)
        initConstraintFields($section)
      },
    )
  }
})
