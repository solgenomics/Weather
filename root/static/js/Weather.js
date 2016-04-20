function initialize_events() {

    jQuery('input[name="daterange"]').daterangepicker(
      {
        "autoApply": true,
        "startDate": "10/01/2015",
        "endDate": "10/31/2015",
        "minDate": "09/01/2015",
        //"maxDate": "12/31/2015",
        "opens": "center"
      },
      function(start, end) {
        startDate = start.format('YYYY-MM-DD');
        endDate = end.format('YYYY-MM-DD');
      }
    );

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
  //console.log(type_data);
  jQuery.ajax( {
    url: '/rest/weather',
    data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'restrict': restrict, 'types' : types },
    success: function(response) {
	    if (response.error) {
        alert(response.error);
	    }
	    else {
        //console.log("response values = "+JSON.stringify(response.values));
        //console.log("response stats = "+JSON.stringify(response.stats));
        display_summary_statistics(response.stats);
      //  if (response.daylength_stats) {
      //    display_daylength_stats(response.daylength_stats);
      //  }
      //  display_raw_data(response.values, type_data);
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
  } );

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

}
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
