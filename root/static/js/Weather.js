
function initialize_events() {

    //alert('Initializing date_pickers...');

    $(function() {
	$("#start_datepicker").datepicker( {
	    'dateFormat' : "yy-mm-dd",
	    changeMonth: true,
	    numberOfMonths: 2,
//	    'onClose': function( selectedDate ) {
//		$( "#end_datepicker" ).datepicker( "option", "minDate", selectedDate );
//	    }
	});
    });

    $(function() {
	$("#end_datepicker").datepicker( {
	    'dateFormat' : "yy-mm-dd",
	    changeMonth: true,
	    numberOfMonths: 2,
//	    'onClose': function( selectedDate ) {
//		alert('Setting start_datapicker minDate');
//		$( "#start_datepicker" ).datepicker( "option", "minDate", selectedDate );
//	    }
	});
    });

    $('#submit').click( function() {
	var location = $('#location_select').val();
	var start_date = $('#start_datepicker').val();
	var end_date = $('#end_datepicker').val();
	var interval = $('input:radio[name=interval]:checked').val();
	var type = $('input:radio[name=type]:checked').val();
	//alert(start_date+ ' '+end_date + ' '+ location + ' '+ type);

	var types = [['Temperature', ' in °C', 'Description goes here', '#8C001A'], ['Intensity', ' in lum/ftÂ²', 'Description goes here', '#ffd300'], ['Dew Point', ' in °C', 'Description goes here', '#5cb85c'], ['Relative Humidity', ' expressed as a %', 'Description goes here', '#5bc0de'], ['Precipitation', ' in mm', 'Description goes here', '#428bca']];

	jQuery('#chart_area').html("");
	for(var n = 0; n<types.length; n++) {
	    //alert("Getting data for "+types[n]);
	     data = get_data(location, start_date, end_date, interval, types[n]);
	}
    });
}

function get_data(location, start_date, end_date, interval, type) {

    jQuery.ajax( {
	url: '/rest/weather',
	data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'type' : type[0] },
	success: function(response) {
	    if (response.error) {
		alert(response.error);
	    }
	    else {
    var targetdiv_id = '#'+type[0].replace(" ", "");
    var title = type[0] + type[1];
    var json_data = MG.convert.date(response.data, 'date', "%Y-%m-%d %H:%M:%S");
    MG.data_graphic({
        title: title,
        description: type[2],
        color: type[3],
        data: json_data,
        linked: true,
        full_width: true,
        height: 300,
        right: 40,
        xax_count: 4,
        target: targetdiv_id
    });
	    }
	},
	error: function(response) {
	    alert('error');
	}
    });
}
