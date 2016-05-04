function initialize_events() {

  create_location_select_box();
  create_radio_button_options();

   jQuery('#submit').click( function() {
     var location = jQuery('#location_select').val();
     var start_date = jQuery('#daterange').data('daterangepicker').startDate.format('YYYY-MM-DD');
     var end_date = jQuery('#daterange').data('daterangepicker').endDate.format('YYYY-MM-DD');
     var types = jQuery('#types').val() || [];
     var interval = jQuery('#interval label.active input').val()
    // var restrict = jQuery('#restrict label.active input').val()

     var type_color = {
       temp: '#8C001A', //red
       day_length: '#FF9100', //orange
       intensity: '#ffd300', //yellow
       dp: '#5cb85c', //green
       rh: '#5bc0de', //light blue
       rain: '#428bca' //darker blue
     };

     jQuery('#graphs_body').html("");
     var numTypes = types.length;
     for (var i = 0; i < numTypes; i++) {
       console.log("type number "+i+"="+types[i]);
       jQuery('#graphs_body').append("<div id="+types[i]+"></div>");
     }

     var data = get_data(location, start_date, end_date, interval, type_color, types);
   });
}

function get_data(location, start_date, end_date, interval, type_color, types) {
  var spinner;
  jQuery.ajax( {
    url: '/rest/weather',
    data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'types' : types },
    beforeSend: function() {
      var target = document.getElementById('spinning_wheel');
      console.log('target = '+target);
      spinner = new Spinner({color:'#ADD8E6', lines: 12}).spin(target);
      //jQuery('#working_msg').html('<h4> Testing the msg part of the working modal </h4>');
      jQuery('#working_modal').modal("show");
    },
    success: function(response) {
	    if (response.error) {
        spinner.stop();
        jQuery('#working_modal').modal("hide");
        alert(response.error);
	    }
	    else {
        display_summary_statistics(response.stats);
        display_timeseries(response.values, response.metadata, type_color);
        spinner.stop();
        jQuery('#working_modal').modal("hide");
	    }
    },
    error: function(response) {
      spinner.stop();
      jQuery('#working_modal').modal("hide");
	    alert('error');
    }
  });
}

function select_all_options(obj) {
    if (!obj || obj.options.length ==0) { return; }
    for (var i=0; i<obj.options.length; i++) {
      obj.options[i].selected = true;
    }
    jQuery('#types').trigger('change');
}

function display_summary_statistics(data) {
  var table = jQuery('#summary_stats').DataTable( {
    dom: 'Bfrtip',
    buttons: ['copy', 'excel', 'csv' ],
    data: data,
    destroy: true,
    columns: [
      { title: "Data Type" },
      { title: "Unit" },
      { title: "Minimum" },
      { title: "Maximum" },
      { title: "Average" },
      { title: "Std Deviation" },
      { title: "Total Sum" },
      { title: "Location" },
      { title: "Start Date" },
      { title: "End Date" },
      { title: "Measurement Interval" }
    ],
    columnDefs: [
      { visible: false, targets: [7,8,9,10] }
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

function display_timeseries(data, metadata, type_color) {
  for (var type in data) {
    if (data.hasOwnProperty(type)) {
    //console.log("current type ="+type);
    var type_hash = metadata[type];
    //console.log("type_hash="+JSON.stringify(type_hash));
    var averages = " averages in ";
    if (type_hash['interval'] == 'Raw') { averages = " measurements in ";}
    var description = type_hash['interval']+' '+type_hash['description']+averages+type_hash['unit']+', gathered by HOBO weather station at '+type_hash['location']+' betweeen '+type_hash['start_date']+' and '+type_hash['end_date']+'.';
    console.log("description: "+description);
    var converted_data = MG.convert.date(data[type], 'date', "%Y-%m-%d %H:%M:%S");
    MG.data_graphic({
      title: type_hash['description'],
  //    y_label: type_string[1],
      yax_units: type_hash['unit'],
      y_scale_type: 'linear',
      description: description,
      color: type_color[type],
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
      var select_html = '<p>Select a location:</p><select class="form-control input-sm" id="location_select" autofocus="autofocus"><option></option><option>' + response.join('</option><option>') + '</option></select>';
      jQuery('#location_select_div').html(select_html);

      jQuery('#location_select').change(
         function() {
           var location = jQuery(this).val();
           create_type_multiple_select(location);
         }
       );
	},
	error: function(response) {
	    alert("An error occurred retrieving locations");
	}
    });
}

function create_radio_button_options() {
  var interval_html = '<center><p>Select measurement type:</p><div class = "btn-group" data-toggle = "buttons" id="interval"><label class = "btn btn-default active"><input type = "radio" name = "options" id = "option1" value="Daily"> Daily averages</label><label class = "btn btn-default"><input type = "radio" name = "options" id = "option2" value="Hourly"> Hourly averages</label><label class = "btn btn-default"><input type = "radio" name ="interval_options" id = "option3" value="Raw">Raw values</label></div></center>'
  jQuery('#interval_select_div').html(interval_html);
  var type_html ='<p>Select data types:</p><select multiple="" class="form-control disabled" id="types" name="1" style="min-width: 200px;overflow:auto;"></select><br><button class="btn btn-default btn-sm disabled" id="select_all" >Select All</button>';
  jQuery('#type_select_div').html(type_html);
  var daterange_html = '<p>Select a date range (defaults to latest month available for the selected options):</p><input class="form-control input-sm disabled" type="text" id="daterange" name="daterange"/>';
  jQuery('#daterange_select_div').html(daterange_html);
//  var time_html = '<p>Restrict by time of day:</p><div class = "btn-group" data-toggle = "buttons" id="restrict"><label class = "btn btn-default active"><input type = "radio" name ="time_options" id = "both" value="both"> All measurements</label><label class = "btn btn-default"><input type = "radio" name = "time_options" id = "night" value="night"> Night only</label><label class = "btn btn-default"><input type = "radio" name = "time_options" id = "day" value="day"> Day only</label></div>'
//  jQuery('#time_select_div').html(time_html);
}

function create_type_multiple_select(location) {
  jQuery.ajax( {
	url: '/rest/types',
  data: {'location': location},
  success: function(response) {
      jQuery('#types').html("");
      jQuery('#select_all').removeClass('disabled')
      //jQuery('location_select').removeAttr( "autofocus", null );
      var typesLength = response.types.length;
      jQuery('#select_all').removeClass('disabled');
      jQuery('#types').attr("size", typesLength);
      var type_html;
      for ( var i=0; i < typesLength; i++) {
        type_html += '<option value="'+response.types[i][0]+'">'+response.types[i][1]+'</option>';
      }
      //var type_html ='<option>' + response.types[1].join('</option><option>') + '</option>';
      jQuery('#types').append(type_html);
      jQuery('#select_all').click( function() {
          select_all_options(document.getElementById('types'));
      });
      jQuery('#types').change(
        function() {
          jQuery('#submit').removeClass('disabled');
          var location = jQuery('#location_select').val();
          var types = jQuery(this).val();
          create_daterangepicker(location,types);
      });
    },
  	error: function(response) {
  	    alert("An error occurred initializing type multiple select");
  	}
  });
}

function create_daterangepicker(location,types) {
  jQuery.ajax( {
  url: '/rest/dates',
  data: {'location': location, 'types': types},
  success: function(response) {

      var daterange_html = '<p>Select a date range (defaults to latest month available for the selected options):</p><input class="form-control input-sm" type="text" id="daterange" name="daterange"/>';
      jQuery('#daterange_select_div').html(daterange_html);
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
          "opens": "left"
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
