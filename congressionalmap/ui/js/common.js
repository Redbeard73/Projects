              
j$(document).ready(function () {
  //hide table
  j$("#dataTable").show();
  
  //init range input
  j$("#range1, #range2").rangeinput();
  
  var myform_from = j$("#range1");
  var myform_to = j$("#range2");          
  myform_from.change(function(){
      var val = myform_from.data("rangeinput").getValue();
      if(val >= myform_to.data("rangeinput").getValue()){
          myform_to.data("rangeinput").setValue(val);
      }
  });
  myform_to.change(function(){
      var val = myform_to.data("rangeinput").getValue();
      if(val <= myform_from.data("rangeinput").getValue()){
          myform_from.data("rangeinput").setValue(val);
      }
  });


});// end document.ready
  
  
j$(window).load(function () {
  
	var j$body = j$("body");
	
	if (!is_touch_device) {
	
  	if (j$body.find('table.aria').length) {
  			j$("table.aria").focus();
  				var j$inp = j$(this);
  				j$inp.bind('keydown', function(e) {                
  					var key = e.which;
  					if (key == 13) {					
  						e.preventDefault(); 
  						j$(".header:focus").click();   
  					}
  				});
  			
  			// adding aria and rolls and caption
  			j$('table.aria:first-child').attr('role', 'grid').attr('aria-labelledby', 'tblcaption');
  		
  			//adding more accessiblity attribute//
  			j$('table thead tr th').attr('tabindex', '0');
  			var j$tabletr = j$('table tbody tr');
  				j$tabletr.each(function(){
  					j$(this).find('td').each(function(i){
  						j$(this).attr('tabindex', '0').attr('role', 'gridcell').attr('aria-labelledby', j$('table.aria thead tr th').eq(i).text());
  					});
  			});
  	} //end if
  	
  }//end if touch

  
	//Table init for any page with a table.data.addsorting
  
	
  // show hide the table
	j$("#dataTableWrapper a").click(function() {
		j$body.find("#dataTable").slideToggle();
		j$(window).scrollTop() + 100
	});
	
	
	// Table filter
	//var theTable = j$('#dataTable table');

	//j$('#filter-form').reset();

  //j$('#filter').keyup(function() {
  //  j$.uiTableFilter( theTable, this.value );
  //})

  //j$('#filter-form').submit(function(){
  //  theTable.find("tbody > tr:visible > td:eq(1)").mousedown();
  //  return false;
  //}).focus(); //Give focus to input field
  

});	// window.load

