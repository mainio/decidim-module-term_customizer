$(() => {
  const $fields = $("form.translation-sets-form .multifield-fields");

  $fields.multifield();
  $fields.on(
    "add-field-section",

    /* @this HTMLElement */
    function(ev, newField) {
      $(newField).constraintSection();
    }
  );

  $(".constraints-list .constraint-section", $fields).each((_i, el) => {
    $(el).constraintSection();
  });
});
