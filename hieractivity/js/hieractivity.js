$(document).ready(function() {
  // Get the calculated heights of each div with a @data-tapas-gi on it. 
  var heightData = [];
  $('[data-tapas-gi].boxed').toArray().forEach(function(obj) { 
    heightData.push($(obj).height());
  });
  
  // Set the view package color scheme for boxes. The color palette is a slightly 
    // modified version of 12-class Set3 from Cynthia Brewer's ColorBrewer 2.0:
    // http://colorbrewer2.org/?type=qualitative&scheme=Set3&n=12
  var tapasScheme = 
    [ '#3274b8', '#7cbab0', '#ffffb3', '#bebada', '#fb8072', '#fdb462', 
      '#80b1d3', '#b3de69', '#fccde5', '#bc80bd', '#ccebc5', '#ffed6f' ]
    .map(function (c) { c = d3.rgb(c); c.opacity = 0.75; return c; });
  var color = d3.scaleOrdinal()
    .range(tapasScheme);
  /*var tapasScheme = d3.scaleSequential(d3.interpolatePlasma)
    .domain([-1,6]);
  var color = tapasScheme;*/
  
  // Set up relevant d3 selections.
  var teiContainer = d3.select('#tei-container');
  var scrollElement = d3.select('div[data-tapas-gi].boxed');
  var scrollElementNode = scrollElement.node();
  var zoomSlider = d3.select('#zoom-slide')
    .on('input', slid)
    .on('mouseout', workedHeight);
  var giPropList = d3.select('#gi-properties');
  // Assign—explicitly—the divs' heights back to them. d3.js requires some absolute 
    // height value in order to zoom on HTML elements.
  var containers = d3.selectAll('[data-tapas-gi].boxed')
      .data(heightData)
      .style('height', function(d) {
        //console.log(d);
        return d + 'px';
      })
      .style('background-color', function() { 
        var depth = $(this).attr('data-tapas-box-depth');
        return color(depth);
      })
      .on('click', inspectElement);
  
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
    var instance1 = d3.select('.selected-gi[data-tapas-gi]').node();
    if ( instance1 !== null && instance1 !== undefined ) {
      instance1.scrollIntoView();
    }
  });


/*  FUNCTIONS  */
  
  // Translate and scale the first element with @data-tapas-gi.
  function transformed(scale) {
    var h = heightData[0],
        w = $(scrollElementNode).width(),
        xNew = w / 2 * (-1 + scale),
        yNew = h / 2 * (-1 + scale);
    scrollElement.style('transform', 
        "translate("+ xNew + "px,"+ yNew +"px)"
      + "scale(" + scale + ")");
    workedHeight();
  }
  
  // When the zoom slider value is changed, convert the integer into a decimal and 
    // call transformed().
  function slid(d) {
    var k = d3.select(this).property('value') / 100;
    //console.log(k);
    transformed(k);
  }

  // Change the height of the teiContainer to match the working (scaled) height of 
    // scrollElement. This is necessary in order to keep the scrollbar from 
    // registering the 'actual' height of scrollElement, which is unaffected by 
    // CSS transformations.
  function workedHeight() {
    var hNew = scrollElementNode.getBoundingClientRect().height + 10;
    teiContainer.style('height', hNew + 'px');
  }
  
  // Get the data attributes associated with an HTML element, and display information
    // in the control panel regarding the TEI element represented.
  function inspectElement() {
    var e = d3.event,
        el = d3.select(this),
        dataObj = el.node().dataset,
        giName = dataObj['tapasGi'],
        attrNames = dataObj['tapasAttributes'] === '' ? [] : dataObj['tapasAttributes'].split(' ');
    e.stopPropagation();
    //e.preventDefault();
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
        }
      }
    }, this);
  }
});
