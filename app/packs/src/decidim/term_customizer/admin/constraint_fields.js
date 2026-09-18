$(() => {
  // The components of a space are the same for every constraint of the form,
  // so they are only fetched once per space.
  const componentsCache = {};

  const fetchComponents = (url, manifest, spaceId) => {
    const cacheKey = `${manifest}/${spaceId}`;

    if (!componentsCache[cacheKey]) {
      componentsCache[cacheKey] = Promise.resolve(
        $.getJSON(url, { "manifest": manifest, "space_id": spaceId })
      ).catch((error) => {
        // Do not cache failures, the next selection should retry.
        Reflect.deleteProperty(componentsCache, cacheKey);
        throw error;
      });
    }

    return componentsCache[cacheKey];
  };

  // Mirrors how Rails turns a field name into a field id.
  const fieldId = (name) => name.replace(/\]\[|[^\-a-zA-Z0-9:.]/g, "_").replace(/_$/, "");

  const buildComponentContainer = (baseName, spaceId, data) => {
    const baseId = fieldId(baseName);
    const $container = $("<div>", {
      "class": "row column component-container",
      "data-components": spaceId
    });

    $container.append($("<input>", {
      type: "hidden",
      name: `${baseName}[subject_id]`,
      id: `${baseId}_subject_id`,
      value: spaceId
    }));

    if (!data.components_supported) {
      $container.append($("<input>", {
        type: "hidden",
        name: `${baseName}[component_id]`,
        id: `${baseId}_component_id`,
        value: ""
      }));

      return $container;
    }

    const $select = $("<select>", {
      "class": "constraint-component-selector",
      name: `${baseName}[component_id]`,
      id: `${baseId}_component_id`
    });
    $select.append($("<option>", { value: "", label: " " }));
    data.components.forEach((component) => {
      $select.append($("<option>", { value: component.id }).text(component.name));
    });

    const $label = $("<label>", { "for": `${baseId}_component_id` }).text(data.label);
    $label.append($select);
    $container.append($label);

    return $container;
  };

  const initConstraintFields = ($section) => {
    const $container = $section.closest(".constraints-container");
    const componentsUrl = $container.data("components-url");
    const loadingText = $container.data("components-loading-text");
    const errorText = $container.data("components-error-text");

    const $select = $("select.constraint-subject-selector", $section);
    const $modelSelect = $("select.constraint-subject-model-selector", $section);

    $select.on(
      "change init",

      /* @this HTMLElement */
      function() {
        const val = $(this).val();
        $("[data-manifest]", $section).hide();
        $(`[data-manifest="${val}"]`, $section).show();
      }
    ).trigger("init");

    $modelSelect.on(
      "change init",

      /* @this HTMLElement */
      function(ev) {
        const $modelField = $(this);
        const $manifestContainer = $modelField.closest(".manifest-container");
        const $holder = $(".component-container-holder", $manifestContainer);
        const manifest = $manifestContainer.data("manifest");
        const spaceId = $modelField.val();

        if (!spaceId) {
          $holder.empty();
          return;
        }

        // The fields of the space of a saved constraint are already rendered
        // by the server, there is nothing to load for them.
        const $current = $(".component-container", $holder);
        if (ev.type === "init" && $current.attr("data-components") === String(spaceId)) {
          return;
        }

        const baseName = `${$modelField.attr("name").replace(/\[subject_id\]$/, "")}[component_model][${spaceId}]`;

        // Only the response of the latest selection may be rendered.
        const requestId = (parseInt($holder.data("componentsRequestId"), 10) || 0) + 1;
        $holder.data("componentsRequestId", requestId);
        $holder.html($("<p>", { "class": "help-text component-container-loading" }).text(loadingText));

        fetchComponents(componentsUrl, manifest, spaceId).then((data) => {
          if ($holder.data("componentsRequestId") !== requestId) {
            return;
          }

          $holder.empty().append(buildComponentContainer(baseName, spaceId, data));
        }).catch(() => {
          if ($holder.data("componentsRequestId") !== requestId) {
            return;
          }

          $holder.html($("<p>", { "class": "form-error is-visible component-container-error" }).text(errorText));
        });
      }
    ).trigger("init");
  };

  $.fn.constraintSection = function() {
    $(this).each(

      /**
       * @this HTMLElement
       * @return {void}
       */
      function() {
        const $section = $(this);
        initConstraintFields($section);
      }
    )
  }
})
