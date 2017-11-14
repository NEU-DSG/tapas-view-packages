$(document).ready(function() {
  console.log('Loaded Hieractivity')
  // Turn on tooltip functionality from the jQueryUI library.
  $('.legend-key').tooltip({
    classes: {
      "ui-tooltip": "hieractive-tooltip"
    }
  });
  
  // Add buttons to all expandable headings. By adding accessibility options via
    // Javascript and not XSLT, we allow those without Javascript to see content
    // that would otherwise be hidden and inaccessible. Solution based on
    // 'Progressive Collapsibles' by @haydonworks:
    // http://heydonworks.com/practical_aria_examples/#progressive-collapsibles
  $('.expandable-heading').each(function() {
    var heading = $(this),
        nextDiv = heading.next(),
        nextDivID = nextDiv.attr('id');
    //console.log(nextDivID);
    // If the next <div> has a class of 'expandable-hidden', treat it as
      // collapsed, and mark the button as not expanded.
    var isAutoCollapsed = nextDiv.is('[class~=expandable-hidden]');
    heading.wrapInner('<button aria-expanded="'+ !isAutoCollapsed
      +'" aria-controls="'+ nextDivID +'"></button>');
    nextDiv.attr('aria-hidden', isAutoCollapsed);
    var button = heading.children('button');
    // Show or hide the expandable <div> when the associated button is pressed.
    button.on('click', toggleContainerVisibility);
  });
  
  // Set up variables with relevant d3 selections.
  var controlPanel = d3.select('#control-panel'),
      controlPanelNode = controlPanel.node(),
      controlsViewport = d3.select('#controls-viewport'),
      controlsViewportNode = controlsViewport.node(),
      teiContainer = d3.select('#tei-container'),
      scrollElement = d3.select('#tei-resources-box'),
      scrollElementNode = scrollElement.node(),
      giPropList = d3.select('#gi-properties'),
      colorSchemeList = d3.select('#color-scheme');
  var zoomSlider = d3.select('#zoom-slide')
      .on('input', slid)
      .on('mouseout', workedHeight)
      .property('disabled', false);
  // All representations of TEI elements have their properties shown on click.
  var teiElements = d3.selectAll('[data-tapas-gi]')
      .on('click', inspectElement);
  var containers = teiElements.filter('.boxed');
  
  // When the radio buttons' input value changes, mark HTML elements that correspond
    // to the chosen TEI element.
  $('input[name=element]').change(function(e) {
    e.preventDefault();
    var inputEl = $(e.target),
        gi = inputEl.val(),
        isChecked = inputEl.prop('checked');
    // When the option chosen is "defaults only", de-select all elements.
    if ( gi === 'none' ) {
      d3.selectAll('.selected-gi[data-tapas-gi]').classed('selected-gi', false);
      // If using checkboxes for the other values, clear them.
    // When the option has been unchecked, de-select elements of that type. (This 
      // will only fire on checkboxes, not radio buttons.)
    } else if ( !isChecked ) {
      d3.selectAll('.selected-gi[data-tapas-gi='+ gi +']').classed('selected-gi', false);
    // When the option has been checked, select all elements of that type, and 
      // scroll to the first occurrence.
    } else {
      // If using radio buttons, remove the previous selection.
      d3.selectAll('.selected-gi[data-tapas-gi]').classed('selected-gi', false);
      d3.selectAll('[data-tapas-gi='+ gi +']').classed('selected-gi', true);
      var instance1 = d3.select('.selected-gi[data-tapas-gi='+ gi +']').node();
      if ( instance1 !== null && instance1 !== undefined ) {
        $.scrollTo( $(instance1), {
          axis: 'y',            // Only animate the y axis (vertical scroll).
          duration: 300,        // Duration of animation.
          interrupt: true,      // Cancel the animation if the user scrolls.
          offset: { top: -30 }  // Create a 30px buffer above the target.
        } );
      } else {
        console.log("Could not scroll to first-occurring element of type "+gi);
      }
    }
  });
  
  /* Use the text-to-background visibility setting selected by the user. */
  $('input[name=contrast-type]').change(function(e) {
    e.preventDefault();
    // Remove previous selection.
    teiContainer.classed('text-contrast-high text-contrast-mid text-contrast-low text-contrast-none', false);
    // Get the selected visibility setting.
    var checked = d3.select('input[name=contrast-type]:checked');
    console.log(checked);
    var type = checked.attr('value');
    teiContainer.classed('text-contrast-'+type, true);
  });
  
  /* Use the color scheme selected by the user. */
  $('input[name=color-scheme]').change(function(e) {
    e.preventDefault();
    //unassignTextHeights();
    var divContainer = $('div.hieractivity');
    divContainer.toggleClass('hieractivity-depthwise hieractivity-familial');
    assignTextHeights();
  });
  
  // Enable remaining form controls.
  console.log('Attempting to enable form inputs');
  d3.select('#text-contrast-selector')
      .property('disabled', false);
  d3.select('#gi-option-selector')
      .property('disabled', false);
  d3.select('#color-scheme-selector')
      .property('disabled', false);
  console.log(d3.select('#color-scheme-selector').property('disabled'));
  

  // Assign box (and control panel) heights soon, and when the window is resized.
  $(window).resize(assignAllHeights);
  setTimeout(assignAllHeights, 1000);
  
  // Make the control panel draggable.
  /*$('#control-panel').draggable({
    cancel: 'h2, #controls-container',
    containment: 'window'
  });*/


/*  FUNCTIONS  */
  
  // Use the browser to calculate the heights of boxed elements, and then assign 
    // those heights back to them. d3.js requires some absolute height value in order 
    // to zoom on HTML elements.
  function assignTextHeights() {
    // Remove previous height calculation.
    containers.style('height', null);
    unassignHeight(scrollElementNode);
    // Get the calculated heights of each div with a @data-tapas-gi on it.
    var heightData = [];
    $('[data-tapas-gi].boxed').toArray().forEach(function(obj) {
      heightData.push($(obj).outerHeight());
    });
    // Assign the height of the scrollElement back to it.
    assignHeightBack(scrollElementNode);
    console.log($(scrollElementNode).outerHeight());
    // Assign the other boxes' heights back to them.
    containers
        .data(heightData)
        .style('height', function(d) {
          //console.log(d);
          return d + 'px';
        });
    console.log("Assigned heights to boxes");
  }
  
  function assignAllHeights() {
    var windowHeight = 'innerHeight' in window ? window.innerHeight : document.documentElement.offsetHeight(),
        panelMaxHeight = windowHeight - 50,
        viewportMaxHeight = panelMaxHeight - $('#control-panel > h2').outerHeight();
    controlPanel.style('max-height', panelMaxHeight);
    controlsViewport.style('max-height', viewportMaxHeight);
    assignHeightBack(controlsViewportNode);
    assignTextHeights();
  }
  
  // Assign the height of an element back to it.
  function assignHeightBack(element) {
    var el = d3.select(element);
    unassignHeight(element);
    // Assign the browser-calculated height to the element.
    el.style('height', $(element).outerHeight()+'px');
  }

  // Remove a previous height calculation.
  function unassignHeight(element) {
    d3.select(element).style('height', null);
  }
  
  // Get the data attributes associated with an HTML element, and display information
    // in the control panel regarding the TEI element represented.
  function inspectElement() {
    var shadowMax = 0.6,
        shadowMin = 1e-6,         // 0.000001
        shadowColor = '#9EAEC9',  // @raspberry-dark
        oldSelection = d3.select('.currently-inspected'),
        e = d3.event,
        el = d3.select(this),
        dataObj = el.node().dataset,
        giName = dataObj['tapasGi'],
        attrNames = dataObj['tapasAttributes'] === '' ? [] : dataObj['tapasAttributes'].split(' ');
    e.stopPropagation();
    //e.preventDefault();
    // The previously-selected element's box shadow contracts back in on itself.
    oldSelection.classed('currently-inspected', false)
      .transition()
        .duration(200)
        .ease(d3.easeExpIn)
        .styleTween('box-shadow', function() {
          return function (t) {
            // If we're on the last step of the duration, remove the 'box-shadow' 
              // rule on the element.
            if ( t === 1.0 ) {
              return '';
            }
            return '0 0 '
                  + d3.interpolateNumber(0.6, 1e-6)(t) + 'em ' 
                  + shadowColor;
          };
        });
    // Animate a box shadow to indicate the element the user selected.
    el.classed('currently-inspected', true)
      .transition()
        .duration(250)
        .ease(d3.easeExpOut)
        .styleTween('box-shadow', function() {
          return function (t) {
            return '0 0 ' 
                  + d3.interpolateNumber(shadowMin, shadowMax)(t) + 'em ' 
                  + shadowColor;
          };
        });
    // Clear the 'Clicked element' widget, then create a list of the target 
      // element's properties.
    giPropList.html('');
    giPropList.append('dt')
      .text('Element name:');
    giPropList.append('dd')
      .append('span')
        .text(giName)
        .classed('encoded encoded-gi', true);
    // For each listed attribute, recreate its key in the datastore.
    attrNames.forEach(function(str) {
      var key = 'tapasAtt' + str.replace(/([-:]^\w|\b\w)/g, function(letter, index) {
        return letter.toUpperCase();
      }).replace(/[:-]/g,'');
      if ( key !== 'tapasAtt' ) {
        var value = dataObj[key];
        if ( value !== undefined && value !== '' ) {
          giPropList.append('dt')
            .append('span')
              .text('@'+str)
              .classed('encoded encoded-att', true);
          giPropList.append('dd')
            .text(value);
        } else {
          console.log('Data attribute "'+ key + '" not found');
          console.log(dataObj);
        }
      }
    }, this);
  }
  
  // When the zoom slider value is changed, convert the integer into a decimal and
    // call transformed().
  function slid(d) {
    var k = d3.select(this).property('value') / 100;
    //console.log(k);
    transformed(k);
  }
  
  // Slide a container open or closed, and ensure ARIA labels are set.
  function toggleContainerVisibility(e) {
    var button = $(e.target),
        isExpanding = button.attr('aria-expanded') === 'false' ? true : false,
        parentElement = button.parent(),
        container = parentElement.next(),
        grandparent = parentElement.parent(),
        isInControls = grandparent.hasClass('control-widget') || grandparent.is('#control-panel');
    // If this event is occurring in the control panel, unassign the height of the 
      // panel before proceeding, and re-assign it when the sliding animation is 
      // complete.
    container.slideToggle({
      done: function() {
        container.toggleClass('expandable-hidden');
        container.attr('aria-hidden', !isExpanding);
        button.attr('aria-expanded', isExpanding);
        if ( isInControls ) {
          assignHeightBack(controlsViewportNode);
        }
      }
    });
  }
  
  // Translate and scale the first element with @data-tapas-gi.
  function transformed(scale) {
    var h = $(scrollElementNode).height(),
        w = $(scrollElementNode).width(),
        xNew = w / 2 * (-1 + scale),
        yNew = h / 2 * (-1 + scale);
    scrollElement.style('transform',
        "translate("+ xNew + "px,"+ yNew +"px)"
      + "scale(" + scale + ")");
    workedHeight();
  }
  
  // Change the height of the teiContainer to match the working (scaled) height of
    // scrollElement. This is necessary in order to keep the scrollbar from
    // registering the 'actual' height of scrollElement, which is unaffected by
    // CSS transformations.
  function workedHeight() {
    var hNew = scrollElementNode.getBoundingClientRect().height + 10;
    teiContainer.style('height', hNew + 'px');
  }
});
