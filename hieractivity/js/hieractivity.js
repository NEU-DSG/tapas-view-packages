$(document).ready(function() {
  // Get the calculated heights of each div with a @data-tapas-gi on it. 
  var heightData = [];
  $('div[data-tapas-gi]').toArray().forEach(function(obj) { 
    heightData.push($(obj).height());
  });
  //console.log(heightData);
  var color = d3.scaleOrdinal()
    .range(d3.schemeCategory20
      .map(function (c) { c = d3.rgb(c); c.opacity = 0.6; return c; }));
  
  // Set up relevant d3 selections.
  var scrollElement = d3.select('[data-tapas-gi]');
  var zoomSlider = d3.select('#zoom-slide')
    .on('input', slid);
  // Assign—explicitly—the divs' heights back to them. d3.js requires some absolute 
    // height value in order to zoom on HTML elements.
  var containers = d3.selectAll('div[data-tapas-gi]')
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
    scrollElement.style("transform", 
        "translate("+ xNew + "px,"+ yNew +"px)"
      + "scale(" + scale + ")");
    //scrollElement.style("height", h * scale);
  }
  
  // When the zoom slider value is changed, convert the integer into a decimal and 
    // call transformed().
  function slid(d) {
    var k = d3.select(this).property('value') / 100;
    //console.log(k);
    transformed(k);
  }
  
  /*function zoomed() {
    transformed(d3.event.scale);
    zoomSlider.property("value", d3.event.scale);
  }*/
});
