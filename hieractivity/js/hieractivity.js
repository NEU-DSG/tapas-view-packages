$(document).ready(function() {
  // Get the calculated heights of each div with a @data-tapas-gi on it. 
  var heightData = [];
  $('[data-tapas-gi].boxed').toArray().forEach(function(obj) { 
    heightData.push($(obj).height());
  });
  //console.log(heightData);
  
  // View package color scheme
  var tapasScheme = d3.schemeCategory20
    .map(function (c) { c = d3.rgb(c); c.opacity = 0.75; return c; });
  var color = d3.scaleOrdinal()
    .range(tapasScheme);
  /*var tapasScheme = d3.scaleSequential(d3.interpolatePlasma)
    .domain([-1,6]);
  var color = tapasScheme;*/
  
  // Set up relevant d3 selections.
  var teiContainer = d3.select('#tei-container');
  var scrollElement = d3.select('div[data-tapas-gi].boxed');
  var zoomSlider = d3.select('#zoom-slide')
    .on('input', slid);
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
      });
  
  // Translate and scale the first element with @data-tapas-gi.
  function transformed(scale) {
    var h = heightData[0],
        w = $(scrollElement.node()).width(),
        xNew = w / 2 * (-1 + scale),
        yNew = h / 2 * (-1 + scale);
    scrollElement.style('transform', 
        "translate("+ xNew + "px,"+ yNew +"px)"
      + "scale(" + scale + ")");
    // Change the height of the teiContainer to match the working (scaled) height of 
      // scrollElement. This is necessary in order to keep the scrollbar from 
      // registering the 'actual' height of scrollElement, which is unaffected by 
      // CSS transformations.
    var hNew = scrollElement.node().getBoundingClientRect().height + 10;
    teiContainer.style('height', hNew + 'px');
  }
  
  // When the zoom slider value is changed, convert the integer into a decimal and 
    // call transformed().
  function slid(d) {
    var k = d3.select(this).property('value') / 100;
    //console.log(k);
    transformed(k);
  }
});
