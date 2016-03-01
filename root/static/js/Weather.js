
function initialize_events() { 

    alert('Initializing date_pickers...');

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
	
	var types = new Array('Temperature', 'Relative Humidity', 'Dew Point', 'Intensity', 'Precipitation');
	
	jQuery('#chart_area').html("");
	for(var n = 0; n<types.length; n++) { 
	    alert("Getting data for "+types[n]);
	     data = get_data(location, start_date, end_date, interval, types[n]);
	}
    });
}

function get_data(location, start_date, end_date, interval, type) { 
    jQuery.ajax( { 
	url: '/rest/weather',
	data: { 'location' : location, 'start_date' : start_date, 'end_date' : end_date, 'interval' : interval, 'type' : type },
	success: function(response) { 
	    if (response.error) { 
		alert(response.error);
	    }
	    else { 
		var s = JSON.stringify(response);
		alert(s);
		
		graph(response.data, response.domain_x, response.domain_y);
	    }
	},
	error: function(response) { 
	    alert('error');
	}
    });
}

function graph(data) { 

    var y_values = new Array();
    var x_values = new Array();

    var y_max = 0;

    for (var i=0; i<data.length; i++) { 
	if (data[i].value > y_max) { y_max = data[i].value };
	y_values.push(data[i].value);
	x_values.push(data[i].name);
    }

//    var svg = d3.select("#chart_area")
//        .append("svg")
//        .attr("width", width)
//        .attr("height", height)
//    ;

   

    var margin = {top: 20, right: 20, bottom: 70, left: 40},
    width = 800 - margin.left - margin.right,
    height = 140 - margin.top - margin.bottom;
    
    // var graph_div = d3.select("#chart_area").append('svg')
    // 	.attr("width", width + margin.left + margin.right)
    // 	.attr("height", height + margin.top + margin.bottom)
    // 	.append("g")
    // 	.attr("transform", "translate("+margin.left+', '+margin.top+")")
    //    ;
    // Parse the date / time
    var	parseDate = d3.time.format("%Y-%m-%d %H:%M").parse;
    
    var x = d3.scale.ordinal().rangeRoundBands([0, width], .05);
    
    var y = d3.scale.linear().range([height, 0]);
    
    var xAxis = d3.svg.axis()
	.scale(x)
	.orient("bottom")
	.tickFormat(d3.time.format("%Y-%m-%d"));
    
    var yAxis = d3.svg.axis()
	.scale(y)
	.orient("left")
	.ticks(10);
    
    var svg = d3.select("#chart_area").append("svg")
	.attr("width", width + margin.left + margin.right)
	.attr("height", height + margin.top + margin.bottom)
	.append("g")
	.attr("transform", 
              "translate(" + margin.left + "," + margin.top + ")");

    data.forEach(function(d) {
	//alert("Data d = "+d.name + " " + d.value);
        d.date = parseDate(d.name);
	//alert("Date:"+d.date);
        d.name = +d.value;
    });
    
   // alert(JSON.stringify(data));

    x.domain(data.map(function(d) { return d.date; }));
    y.domain([0, d3.max(data, function(d) { return d.value; })]);
    

    svg.append("g")
	.attr("class", "x axis")
	.attr("transform", "translate(0," + height + ")")
	.call(xAxis)
	.selectAll("text")
	.style("text-anchor", "end")
	.attr("dx", "-.8em")
	.attr("dy", "-.55em")
	.attr("transform", "rotate(-90)" );

    svg.append("g")
	.attr("class", "y axis")
	.call(yAxis)
	.append("text")
	.attr("transform", "rotate(-90)")
	.attr("y", 6)
	.attr("dy", ".71em")
	.style("text-anchor", "end")
	.text(data.type);
    
    svg.selectAll("bar")
	.data(data)
    .enter().append("rect")
	.style("fill", "steelblue")
	.attr("x", function(d) { return x(d.date); })
	.attr("width", x.rangeBand())
	.attr("y", function(d) { return y(d.value); })
	.attr("height", function(d) { return height - y(d.value); });
   
}


