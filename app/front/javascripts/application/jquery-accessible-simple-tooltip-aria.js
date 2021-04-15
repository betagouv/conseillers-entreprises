(function() {

  'use strict';
  /*
   * jQuery accessible simple (non-modal) tooltip window, using ARIA
   * @version v2.2.0
   * Website: https://a11y.nicolas-hoffmann.net/simple-tooltip/
   * License MIT: https://github.com/nico3333fr/jquery-accessible-simple-tooltip-aria/blob/master/LICENSE
   */
  function accessibleSimpleTooltipAria(options) {
    var element = $(this);
    options = options || element.data();
    var text = options.simpletooltipText || '';
    var prefix_class = typeof options.simpletooltipPrefixClass !== 'undefined' ? options.simpletooltipPrefixClass + '-' : '';
    var content_id = typeof options.simpletooltipContentId !== 'undefined' ? '#' + options.simpletooltipContentId : '';

    var index_lisible = Math.random().toString(32).slice(2, 12);
    var aria_describedby = element.attr('aria-describedby') || '';

    element.attr({
      'aria-describedby': 'label_simpletooltip_' + index_lisible + ' ' + aria_describedby
    });

    element.wrap('<span class="' + prefix_class + 'simpletooltip_container"></span>');

    var html = '<span class="js-simpletooltip ' + prefix_class + 'simpletooltip" id="label_simpletooltip_' + index_lisible + '" role="tooltip" aria-hidden="true">';

    if (text !== '') {
      html += '' + text + '';
    } else {
      var $contentId = $(content_id);
      if (content_id !== '' && $contentId.length) {
        html += $contentId.html();
      }
    }
    html += '</span>';

    $(html).insertAfter(element);
  }

  // Bind as a jQuery plugin
  $.fn.accessibleSimpleTooltipAria = accessibleSimpleTooltipAria;

  addEventListener('turbolinks:load', function () {
    $('.js-simple-tooltip')
      .each(function() {
        // Call the function with this as the current tooltip
        accessibleSimpleTooltipAria.apply(this);
      });

    // events ------------------
    $('body')
      .on('mouseenter focusin', '.js-simple-tooltip', function() {
        var aria_describedby = $(this).attr('aria-describedby');
        if (ariaDescribedPresent(aria_describedby)) {
          var $tooltip = getTooltipToShow(aria_describedby);
          showTooltip($tooltip);
        }
      })
      .on('mouseleave', '.js-simple-tooltip', function() {
        var aria_describedby = $(this).attr('aria-describedby');
        if (ariaDescribedPresent(aria_describedby)) {
          var $tooltip = getTooltipToShow(aria_describedby);
          var $is_target_hovered = $tooltip.is(':hover');

          if (!$is_target_hovered) {
            hideTooltip($tooltip);
          }
        }
      })
      .on('focusout', '.js-simple-tooltip', function() {
        var aria_describedby = $(this).attr('aria-describedby');
        if (ariaDescribedPresent(aria_describedby)) {
          var $tooltip = getTooltipToShow(aria_describedby);

          hideTooltip($tooltip);
        }
      })
      .on('mouseleave', '.js-simpletooltip', function() {
        $(this).attr('aria-hidden', 'true');
      })
      .on('keydown', '.js-simple-tooltip', function(event) {
        var aria_describedby = $(this).attr('aria-describedby');
        if (ariaDescribedPresent(aria_describedby)) {
          var $tooltip = getTooltipToShow(aria_describedby);

          if (event.keyCode == 27) { // esc
            hideTooltip($tooltip);
          }
        }
      });

    function ariaDescribedPresent(aria_describedby) {
      return typeof aria_describedby != "undefined";
    }

    function getTooltipToShow(aria_describedby) {
      var tooltip_to_show_id = aria_describedby.substr(0, aria_describedby.indexOf(" "));
      var $tooltip_to_show = $('#' + tooltip_to_show_id);
      return $tooltip_to_show;
    }

    function showTooltip($tooltip) {
      $tooltip.attr('aria-hidden', 'false');
    }

    function hideTooltip($tooltip) {
      $tooltip.attr('aria-hidden', 'true');
    }
  });
})();
