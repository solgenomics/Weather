
function initialize_events() {

  //alert('Initializing date_pickers...');

/*  $(function() {
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
*/

  var start_date;
  var end_date;

    $('input[name="daterange"]').daterangepicker(
      {
          startDate: moment().subtract('days', 29),
          endDate: moment(),
      },
      function(start, end) {
        start_date = start.format('YYYY-MM-DD');
        console.log("start="+start);
        end_date = end.format('YYYY-MM-DD');
        console.log("end="+end);
      }
    );

    $('#submit').click( function() {
	     var location = $('#location_select').val();
       //var start_date = $('#daterange').val(picker.startDate.format('YYYY-MM-DD'));
       //var end_date = $('#daterange').val(picker.endDate.format('YYYY-MM-DD')); //$('#start_datepicker').val();
       console.log(start_date+" till "+end_date);
       //var end_date = $('#end_datepicker').val();
       var types = $('#types').val() || [];
       var interval = $('#interval').val();
       console.log("types = "+types);
       //var type = $('input:radio[name=type]:checked').val();

       //alert(start_date+ ' '+end_date + ' '+ location + ' '+ type);

       var type_data = {
         temperature: ['Temperature', 'Temperature measurements in °C, as gathered by HOBO weather station', '#8C001A'],
         intensity: ['Intensity', 'Intensity measurements in lum/ftÂ², as gathered by HOBO weather station', '#ffd300'],
         dew_point: ['Dew Point', 'Dew Point measurements in °C, as gathered by HOBO weather station', '#5cb85c'],
         relative_humidity: ['Relative Humidity', 'Percent Relative Humidity measurements, as gathered by HOBO weather station', '#5bc0de'],
         precipitation: ['Precipitation', 'Precipitation totals in mm, as gathered by HOBO weather station', '#428bca']
       };

       jQuery('#temperature').html("");
       jQuery('#intensity').html("");
       jQuery('#dew_point').html("");
       jQuery('#relative_humidity').html("");
       jQuery('#precipitation').html("");
       var data = get_data(location, start_date, end_date, interval, type_data, types);

    });
}

function get_data(location, start_date, end_date, interval, type_data, types) {
  console.log(type_data);
  jQuery.ajax( {
    url: '/rest/weather',
    data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'types' : types },
    success: function(response) {
	    if (response.error) {
        alert(response.error);
	    }
	    else {
        console.log("response values = "+JSON.stringify(response.values));
        console.log("response stats = "+JSON.stringify(response.stats));
        display_summary_statistics(response.stats);
        display_timeseries(response.values, type_data);
	    }
    },
    error: function(response) {
	    alert('error');
    }
  });
}

function display_summary_statistics(data) {
  $('#summary_stats').DataTable( {
    data: data,
    destroy: true,
    columns: [
      { title: "Measurement Type" },
      { title: "Minimum" },
      { title: "Maximum" },
      { title: "Average" },
      { title: "Std Deviation" },
      { title: "Total Sum" }
    ]
  } );
}
function display_timeseries(data, type_data) {
  //for ( var i = 0; i < data.length; i++) {
    //  var measurements = data[i];
  for (var type in data) {
    if (data.hasOwnProperty(type)) {
    console.log("current type ="+type);
    var type_string = type_data[type];
    var converted_data = MG.convert.date(data[type], 'date', "%Y-%m-%d %H:%M:%S");
    MG.data_graphic({
      title: type_string[0],
      description: type_string[1],
      color: type_string[2],
      data: converted_data,
      linked: true,
      full_width: true,
      height: 300,
      right: 40,
      xax_count: 4,
      target: '#' + type
    });
  }
  }
}
