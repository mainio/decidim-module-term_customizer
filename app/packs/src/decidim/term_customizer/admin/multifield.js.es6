import AutoButtonsByPositionComponent from "src/decidim/admin/auto_buttons_by_position.component"
import AutoLabelByPositionComponent from "src/decidim/admin/auto_label_by_position.component"
import createDynamicFields from "src/decidim/admin/dynamic_fields.component"
import createSortList from "src/decidim/admin/sort_list.component"

$(() => {
  const initMultifield = ($wrapper) => {
    const wrapperSelector = `#${$wrapper.attr("id")}`
    const placeholderId = $wrapper.data("placeholder-id")

    const fieldSelector = ".multifield-field"

    const autoLabelByPosition = new AutoLabelByPositionComponent({
      listSelector: `${wrapperSelector} .multifield-field:not(.hidden)`,
      labelSelector: ".card-title span:first",
      onPositionComputed: (el, idx) => {
        $(el).find("input.position-input").val(idx)
      },
    })

    const autoButtonsByPosition = new AutoButtonsByPositionComponent({
      listSelector: `${wrapperSelector} .multifield-field:not(.hidden)`,
      hideOnFirstSelector: ".move-up-field",
      hideOnLastSelector: ".move-down-field",
    })

    const createSortableList = () => {
      createSortList(`${wrapperSelector} .fields-list:not(.published)`, {
        handle: ".multifield-field-divider",
        placeholder:
          '<div style="border-style: dashed; border-color: #000"></div>',
        forcePlaceholderSize: true,
        onSortUpdate: () => {
          autoLabelByPosition.run()
        },
      })
    }

    const hideDeletedSection = ($target) => {
      const inputDeleted = $target.find("input[name$=\\[deleted\\]]").val()

      if (inputDeleted === "true") {
        $target.addClass("hidden")
        $target.hide()
      }
    }

    createDynamicFields({
      placeholderId: placeholderId,
      wrapperSelector: wrapperSelector,
      containerSelector: ".multifield-fields-list",
      fieldSelector: fieldSelector,
      addFieldButtonSelector: ".add-field",
      removeFieldButtonSelector: ".remove-field",
      moveUpFieldButtonSelector: ".move-up-field",
      moveDownFieldButtonSelector: ".move-down-field",
      onAddField: ($newField) => {
        createSortableList()

        autoLabelByPosition.run()
        autoButtonsByPosition.run()

        $wrapper.trigger("add-field-section", $newField)
      },
      onRemoveField: () => {
        autoLabelByPosition.run()
        autoButtonsByPosition.run()
      },
      onMoveUpField: () => {
        autoLabelByPosition.run()
        autoButtonsByPosition.run()
      },
      onMoveDownField: () => {
        autoLabelByPosition.run()
        autoButtonsByPosition.run()
      },
    })

    createSortableList()

    $(fieldSelector).each((idx, el) => {
      const $target = $(el)

      hideDeletedSection($target)
    })

    autoLabelByPosition.run()
    autoButtonsByPosition.run()
  }

  $.fn.multifield = function () {
    $(this).each(
      /**
       * @this HTMLElement
       * @return {void}
       */
      function () {
        const $elem = $(this)
        let id = $elem.attr("id")
        if (!id || id.length < 1) {
          id = `multifield-${Math.random().toString(16).slice(2)}`
          $elem.attr("id", id)
        }
        initMultifield($elem)
      },
    )
  }
})
