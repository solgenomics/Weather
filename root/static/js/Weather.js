function initialize_events() {

  jQuery(document)
    .on('click', '.panel-heading span.clickable', function(e){
        jQuery(this).parents('.panel').find('.panel-collapse').collapse('toggle');
    })
    .on('show.bs.collapse', '.panel-collapse', function () {
        var $span = jQuery(this).parents('.panel').find('.panel-heading span.clickable');
        $span.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
    })
    .on('hide.bs.collapse', '.panel-collapse', function () {
        var $span = jQuery(this).parents('.panel').find('.panel-heading span.clickable');
        $span.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
    })

  create_location_select_box();
  create_radio_button_options();

   jQuery('#submit').click( function() {
     var location = jQuery('#location_select').val();
     var start_date = jQuery('#daterange').data('daterangepicker').startDate.format('YYYY-MM-DD');
     var end_date = jQuery('#daterange').data('daterangepicker').endDate.format('YYYY-MM-DD');
     //var cap_types = jQuery('#types').val() || [];
     var types = jQuery('#types').val() || [];
     var typeNames = [];
     jQuery("#types > option").each(function(){
       typeNames.push(jQuery(this).text());
     });
     var nameHash = {};
     jQuery('#graphs_body').html("");
     for (var i = 0; i < types.length; i++) {
       nameHash[types[i]] = typeNames[i];
       jQuery('#graphs_body').append("<div id="+types[i]+"></div>");
     }

     var interval = jQuery('#interval label.active input').val()

     var type_color = {
       temp: '#8C001A', //red
       day_length: '#FF9100', //orange
       intensity: '#ffd300', //yellow
       dp: '#5cb85c', //green
       rh: '#5bc0de', //light blue
       rain: '#428bca' //darker blue
     };

     var data = get_data(location, start_date, end_date, interval, type_color, types, nameHash);
   });
}

function get_data(location, start_date, end_date, interval, type_color, types, nameHash) {
  var spinner;
  jQuery.ajax( {
    url: '/rest/weather',
    data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'types' : types },
    beforeSend: function() {
      var target = document.getElementById('spinning_wheel');
      //console.log('target = '+target);
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
        //console.log(JSON.stringify(response.raw_data));
        display_tables(response.stats, response.raw_data, response.values, response.metadata, location, start_date, end_date, interval);
        jQuery('a[data-toggle="tab"]').on( 'shown.bs.tab', function (e) {
          $.fn.dataTable.tables( {visible: true, api: true} ).columns.adjust();
        } );
        //console.log(JSON.stringify(response.stats));
        display_timeseries(response.values, response.metadata, response.stats, type_color, nameHash);
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

function display_tables(summary_data, raw_data, values, metadata, location, start_date, end_date, interval) {
  jQuery('#table_panel').html('');
  var averages = " averages";
  if (interval == 'individual') { averages = " measurements";}
  var table_html = '<ul class="nav nav-tabs"><li class="active"><a data-toggle="tab" href="#summary">Summary</a></li><li><a data-toggle="tab" href="#raw">Raw Data</a></li></ul><div class="tab-content">';
  table_html += '<div id="summary" class="tab-pane fade in active"><div class="table-responsive" style="margin-top: 10px;"><table id="summary_stats" class="table table-hover table-striped table-bordered" width="100%"><caption class="well well-sm" style="caption-side: bottom;margin-top: 10px;"><center> Table description: <i>Summary of '+interval+averages+' from '+location+' between '+start_date+' and '+end_date+'.</i></center></caption></table></div></div>';
  table_html += '<div id="raw" class="tab-pane fade"><div class="table-responsive" style="margin-top: 10px;"><table id="raw_data" class="table table-hover table-striped table-bordered" width="100%"><thead><tr>';
  table_html += '<th>Time</th>';
  var types= [];
  for (var type in values) {
    if (values.hasOwnProperty(type)) {
      types.push(type);
    }
  }
  types.sort ();
  for (i in types) {
    var type = types[i]
    var type_hash = metadata[type];
    table_html += '<th>'+type_hash['description']+'</th>';
  }
  table_html += '</tr></thead><caption class="well well-sm" style="caption-side: bottom;margin-top: 10px;"><center> Table description: <i>All '+interval+averages+' from '+location+' between '+start_date+' and '+end_date+'.</i></center></caption></table></div></div></div>';
  jQuery('#table_panel').html(table_html);
  var summary_table = jQuery('#summary_stats').DataTable( {
    dom: 'Bfrtip',
    buttons: ['copy', 'excel', 'csv', 'print' ],
    data: summary_data,
    destroy: true,
    paging: true,
    lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
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
  var full_table = jQuery('#raw_data').DataTable( {
    dom: 'Bfrtip',
    buttons: ['copy', 'excel', 'csv', 'print' ],
    data: raw_data,
    destroy: true,
    paging: true,
    lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]]
  });
}

function display_timeseries(data, metadata, summary_data, type_color, nameHash) {
  for (var type in data) {
    if (data.hasOwnProperty(type)) {
      var type_hash = metadata[type];
      var max_y_value = get_max_y(type, summary_data, nameHash);
      var summary_array = summary_data[type];
      var averages = " averages in ";
      if (type_hash['interval'] == 'individual') { averages = " measurements in ";}
      var description = type_hash['interval'].capitalizeFirstLetter()+' '+type_hash['description'].toLowerCase()+averages+type_hash['unit']+', gathered by HOBO weather station at '+type_hash['location']+' betweeen '+type_hash['start_date']+' and '+type_hash['end_date']+'.';
      var converted_data = MG.convert.date(data[type], 'date', "%Y-%m-%d %H:%M:%S");
      MG.data_graphic({
        title: type_hash['description'],
        yax_units: type_hash['unit'],
        y_scale_type: 'linear',
        description: description,
        color: type_color[type],
        data: converted_data,
        interpolate: 'step',
        max_y: max_y_value,
    //  y_rug: true,
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
      //console.log("locations= "+response);
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
  var interval_html = '<center><p>Select measurement type:</p><div class = "btn-group" data-toggle = "buttons" id="interval"><label class = "btn btn-default active"><input type = "radio" name = "options" id = "option1" value="daily"> Daily averages</label><label class = "btn btn-default"><input type = "radio" name = "options" id = "option2" value="hourly"> Hourly averages</label><label class = "btn btn-default"><input type = "radio" name ="interval_options" id = "option3" value="individual">Individual values</label></div></center>'
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
      console.log("response types="+response.types);
      var locationTypes = response.types;
      jQuery('#types').html("");
      jQuery('#select_all').removeClass('disabled')
      var typesLength = response.types.length;
      jQuery('#select_all').removeClass('disabled');
      jQuery('#types').attr("size", typesLength);
      var type_html;
      for ( var i=0; i < typesLength; i++) {
        type_html += '<option value="'+response.types[i][0]+'">'+response.types[i][1]+'</option>';
      }
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

String.prototype.capitalizeFirstLetter = function() {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

function create_daterangepicker(location,types) {
  jQuery.ajax( {
  url: '/rest/dates',
  data: {'location': location, 'types': types},
  success: function(response) {

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
        //  "startDate": moment(jsDate).format('YYYY-MM-DD'),
          "startDate": response.earliest_date,
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

function get_max_y(type, summary_data, nameHash) {
  var max;
  var full_name = nameHash[type];
  for (var i=0; i < summary_data.length; i++) {
    if (full_name == summary_data[i][0]) {
      max = summary_data[i][3];
    }
  }
  return max;
}
