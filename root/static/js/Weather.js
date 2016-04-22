function initialize_events() {

  create_location_select_box();

   jQuery('#submit').click( function() {
     var location = jQuery('#location_select').val();
     var start_date = jQuery('#daterange').data('daterangepicker').startDate.format('YYYY-MM-DD');
     var end_date = jQuery('#daterange').data('daterangepicker').endDate.format('YYYY-MM-DD');
     //console.log(start_date+" till "+end_date);
     var types = jQuery('#types').val() || [];
     var interval = jQuery('#interval').val();
     var restrict = jQuery('#restrict').val();
     console.log("restrict value= "+restrict);
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
     var data = get_data(location, start_date, end_date, interval, restrict, type_data, types);
   });
}

function get_data(location, start_date, end_date, interval, restrict, type_data, types) {
  jQuery.ajax( {
    url: '/rest/weather',
    data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'restrict': restrict, 'types' : types },
    success: function(response) {
	    if (response.error) {
        alert(response.error);
	    }
	    else {
        display_summary_statistics(response.stats);
        display_timeseries(response.values, type_data);
	    }
    },
    error: function(response) {
	    alert('error');
    }
  });
}

function select_all_options(obj) {
    if (!obj || obj.options.length ==0) { return; }
    for (var i=0; i<obj.options.length; i++) {
      obj.options[i].selected = true;
    }
}

function display_summary_statistics(data) {
  var table = jQuery('#summary_stats').DataTable( {
    dom: 'Bfrtip',
    buttons: ['copy', 'excel', 'csv' ],
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
  });
}

/*  function display_raw_data(data, types) {
    var table = jQuery('#raw_data').DataTable( {
      dom: 'Bfrtip',
      buttons: ['copy', 'excel', 'csv' ],
      data: data,
      destroy: true,
      columns: [
            { "data": "name[, ]" },
            { "data": "hr.0" },
            { "data": "office" },
            { "data": "extn" },
            { "data": "hr.2" },
            { "data": "hr.1" }
        ]
    } );

 for creation of extra table of daylength stats

  <div class="row">
    <div class="panel panel-info">
      <div class="panel-heading">Daylength Stats Table</div>
      <div class="panel-body" style="overflow:hidden">
        <div class="table-responsive">
        <table id="summary_stats" class="table table-hover table-striped table-bordered" width="100%"></table>
        </div>
      </div>
    </div>
  </div>
  <br/>
  */
  //table.buttons().container().appendTo( jQuery('#example_wrapper .col-sm-6:eq(0)' ) );

function display_timeseries(data, type_data) {
  //for ( var i = 0; i < data.length; i++) {
    //  var measurements = data[i];
  for (var type in data) {
    if (data.hasOwnProperty(type)) {
    //console.log("current type ="+type);
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

function create_location_select_box() {
  jQuery.ajax( {
	url: '/rest/locations',
	success: function(response) {
      console.log("locations= "+response);
      var select_html = '<p>Select a location:</p><select class="form-control input-sm" id="location_select"><option></option><option>' + response.join('</option><option>') + '</option></select>';
      jQuery('#location_select_div').html(select_html);

      jQuery('#location_select').change(
         function() {
           var location = jQuery(this).val();
           create_type_and_datepicker(location);
         }
       );
	},
	error: function(response) {
	    alert("An error occurred retrieving locations");
	}
    });
}

function create_type_and_datepicker(location) {
  jQuery.ajax( {
	url: '/rest/types_and_range',
  data: {'location': location},
  success: function(response) {
      console.log("type and date limits = "+JSON.stringify(response));
      var type_html ='<p>Select measurement types:</p><select multiple="" class="form-control" id="types" name="1" size="5" style="min-width: 200px;overflow:auto;"><option>' + response.types.join('</option><option>') + '</option></select>';
      jQuery('#types_div').html(type_html);

      var daterange_html = '<p>Select a date range:</p><input class="form-control input-sm" type="text" id="daterange" name="daterange"/>';
      jQuery('#daterange_div').html(daterange_html);
      var momentDate = moment(response.latest_date, 'YYYY-MM-DD');  // take max date and get date one month before
      var jsDate = momentDate.toDate();
      jsDate.setMonth(jsDate.getMonth() - 1);


      jQuery('input[name="daterange"]').daterangepicker(
        {
          locale: {
            format: 'YYYY-MM-DD'
          },
          "autoApply": true,
          "startDate": moment(jsDate).format('YYYY-MM-DD'),
          "endDate": response.latest_date,
          "minDate": response.earliest_date,
          "maxDate": response.latest_date,
          "opens": "center"
        },
        function(start, end) {
          startDate = start.format('YYYY-MM-DD');
          endDate = end.format('YYYY-MM-DD');
        }
      );
    },
  	error: function(response) {
  	    alert("An error occurred initializing daterangepicker");
  	}
  });
}
