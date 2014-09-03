function createAreaGrpah(divName,fileName){
	var parentDiv=$("#"+divName);
	var parentDivWidth=parentDiv.width();
	var parentDivHeight=parentDiv.height();	
	var margin = {top: 20, right: 20, bottom: 30, left: 50},
		width = parentDivWidth - margin.left - margin.right,
		height = parentDivHeight - margin.top - margin.bottom;

	var parseDate = d3.time.format("%Y-%m-%d").parse;
	var x = d3.time.scale()
		.range([0, width]);

	var y = d3.scale.linear()
		.range([height, 0]);

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom")
		.ticks(12)
		.tickSize(10, 0, 0)
		.tickFormat(d3.time.format("%b-%y"));

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left")
		.ticks(10)
		.tickSize(-width, 0, 0);
		
	var area = d3.svg.area()
		.x(function(d) { return x(d.date); })
		.y0(height)
		.y1(function(d) { return y(d.count); });

	var svg = d3.select("#"+divName).append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)
	  .append("g")
		.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	d3.json("/PirateToInsight/rest/disputews/getAreaChart", function(error, data) {
		data=data.data
	  data.forEach(function(d) {
		d.date = parseDate(d.date);
		d.count = +d.count;
	  });
	
//	console.log(data);
	  x.domain(d3.extent(data, function(d) { return d.date; }));
	  y.domain([0, d3.max(data, function(d) { return d.count; })]);

	  svg.append("g")
		  .attr("class", "x axis")
		  .attr("transform", "translate(0," + height + ")")
		  .call(xAxis);

	  svg.append("g")
		  .attr("class", "y axis")
		  .call(yAxis)
		.append("text")
		  .attr("transform", "rotate(-90)")
		  .attr("y", "-40")
		  .attr("dy", ".71em")
		  .style("text-anchor", "end")
		  .text("Cable Count");
		  
	  svg.append("path")
		  .datum(data)
		  .attr("class", "area")
		  .attr("d", area);

	});
}