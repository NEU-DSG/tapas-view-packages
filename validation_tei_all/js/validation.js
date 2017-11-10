$(document).ready(function() {
  console.log('Hello world');
  
  // The following code is adapted with few changes from hieractivity.js, which in
    // turn adapted it from HeydonWorks. It should probably be moved to a new JS 
    // library in the common folder.
  $('.collapsableHeading').each(function() {
    var heading = $(this),
        collapsable = heading.next(),
        collapsableID = collapsable.attr('id');
    //console.log(collapsableID);
    var isAutoCollapsed = collapsable.is('[class~=collapsable-hidden]');
    heading.wrapInner('<button aria-expanded="'+ !isAutoCollapsed
      +'" aria-controls="'+ collapsableID +'"></button>');
    collapsable.attr('aria-hidden', isAutoCollapsed);
    var button = heading.children('button');
    // Show or hide the collapsable <div> when the associated button is pressed.
    button.on('click', function() {
      var isExpanding = $(this).attr('aria-expanded') === 'false' ? true : false;
      collapsable.slideToggle();
      collapsable.toggleClass('collapsable-hidden');
      collapsable.attr('aria-hidden', !isExpanding);
      $(this).attr('aria-expanded', isExpanding);
    });
  });
});