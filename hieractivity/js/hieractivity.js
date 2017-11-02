$(document).ready(function() {
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
    button.on('click', function() {
      var isExpanding = $(this).attr('aria-expanded') === 'false' ? true : false;
      nextDiv.slideToggle();
      nextDiv.toggleClass('expandable-hidden');
      nextDiv.attr('aria-hidden', !isExpanding);
      $(this).attr('aria-expanded', isExpanding);
    });
  });
  
  // Set up variables with relevant d3 selections.
  var controlPanel = d3.select('#control-panel');
  var teiContainer = d3.select('#tei-container');
  var scrollElement = d3.select('#tei-resources-box');
  var scrollElementNode = scrollElement.node();
  var zoomSlider = d3.select('#zoom-slide')
      .on('input', slid)
      .on('mouseout', workedHeight)
      .property('disabled', false);
  var giPropList = d3.select('#gi-properties');
  var colorSchemeList = d3.select('#color-scheme');
  // All representations of TEI elements have their properties shown on click.
  var teiElements = d3.selectAll('[data-tapas-gi]')
      .on('click', inspectElement);
  var containers = teiElements.filter('.boxed');
  // Assign box (and control panel) heights now, and when the window is resized.
  assignAllHeights();
  $(window).resize(assignAllHeights);
  
  // When the radio buttons' input value changes, mark HTML elements that correspond
    // to the chosen TEI element.
  $('input[name=element]').change(function(e) {
    e.preventDefault();
    // Remove the previous selection.
    d3.selectAll('.selected-gi[data-tapas-gi]').classed('selected-gi', false);
    // Select the new element type.
    var checked = $('input[name=element]:checked');
    checked.each(function() {
      var gi = $( this ).val();
      d3.selectAll('[data-tapas-gi='+ gi +']').classed('selected-gi', true);
    });
    // Get the first newly-selected element and scroll to it.
    /*var instance1 = d3.select('.selected-gi[data-tapas-gi]').node();
    if ( instance1 !== null && instance1 !== undefined ) {
      instance1.scrollIntoView();
    }*/
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
  d3.select('#text-contrast-selector')
      .property('disabled', false);
  d3.select('#gi-option-selector')
      .property('disabled', false);
  d3.select('#color-scheme-selector')
      .property('disabled', false);
  
  // Make the control panel draggable.
  $('#control-panel').draggable({
    cancel: 'h2, #controls-container',
    containment: 'window'
  });
  /*controlPanel.selectAll('.expandable-heading button').on('click', function(e) {
    assignHeightBack(controlPanel.node());
  });*/


/*  FUNCTIONS  */
  
  // Use the browser to calculate the heights of boxed elements, and then assign 
    // those heights back to them. d3.js requires some absolute height value in order 
    // to zoom on HTML elements.
  function assignTextHeights() {
    // Remove previous height calculation.
    containers.style('height', null);
    // Get the calculated heights of each div with a @data-tapas-gi on it.
    var heightData = [];
    $('[data-tapas-gi].boxed').toArray().forEach(function(obj) {
      heightData.push($(obj).height());
    });
    // Assign the height of the scrollElement back to it.
    assignHeightBack(scrollElementNode);
    // Assign the other boxes' heights back to them.
    containers
        .data(heightData)
        .style('height', function(d) {
          //console.log(d);
          return d + 'px';
        });
  }
  
  function assignAllHeights() {
    assignHeightBack(controlPanel.node());
    assignTextHeights();
  }
  
  // Assign the height of an element back to it.
  function assignHeightBack(element) {
    var el = d3.select(element);
    // Remove previous height calculation.
    el.style('height', null);
    // Assign the browser-calculated height to the element.
    el.style('height', $(element).height()+'px');
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
