function createPieChart(divName,pieChartDiv,fileName,disputeId) {
//	$("#"+divName).html("");
	
	var width = 180,
	    height = 180,
	    radius = Math.min(width, height) / 2,
	    padding = 5;
	
	var color = d3.scale.ordinal()
	.range(["#DD4A4A", "#2CA02C", "#1F77B4", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);
	
	var arc = d3.svg.arc()
	.outerRadius(radius)
	.innerRadius(0);
	
	var pie = d3.layout.pie()
	.sort(null)
	.value(function(d) { return d.size; });
	

	
	d3.json(fileName+"?disputeId="+disputeId, function(error, root) {
		$("#"+pieChartDiv).html("");
		var data = root.data;
		var svg = d3.select("#"+pieChartDiv).append("svg")
			.attr("width", width)
			.attr("height", height)
			.append("g")
				.attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");
		
		var pieValues = [];
		data.forEach(function(d) {
			d.name=d.name.toUpperCase();
			pieValues.push(d.name);
		});
		color.domain(pieValues);
		
		/*data.forEach(function(d) {
			d.name = 
		});*/
		
		var legend = d3.select("#"+pieChartDiv).append("svg")
		  .attr("class", "legend")
		  .attr("width", radius * 2)
		  .attr("height", radius * 2)
		  .selectAll("g")
		  .data(color.domain().slice().reverse())
		  .enter().append("g")
		  .attr("transform", function(d, i) { return "translate(0," + i * 15 + ")"; });
		
		legend.append("rect")
		  .attr("width", 18)
		  .attr("height", 18)
		  .style("fill", color);
		
		legend.append("text")
		  .attr("x", 24)
		  .attr("y", 9)
		  .attr("dy", ".35em")
		  .text(function(d) { return d; });
		
		
		var g = svg.selectAll(".arc")
	      .data(pie(data))
	    .enter().append("g")
	      .attr("class", "arc");

	  g.append("path")
	      .attr("d", arc)
	      .style("fill", function(d) { return color(d.data.name); });
	  var tooltip=d3.select("div.tooltip");	  
	  d3.select("#"+pieChartDiv).selectAll("g.arc")
	  	.on("mouseover",function(d){	  		
	  		tooltip.html("<div style=\"margin:2px;\"> Category Name: "+d.data.name+"<br/> Cable Count: "+d.value+"</div>");
			tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");
			d3.select(this).select("path").style({"border-style":"groove","border-width":"2px"});
			return tooltip.style("visibility", "visible");
	  	})
	  	.on("mousemove",function(d){
	  		d3.select(this).style({"border-style":"groove","border-width":"2px"});
	  		tooltip.html("<div style=\"margin:2px;\"> Category Name: "+d.data.name+"<br/> Cable Count: "+d.value+"</div>");
			tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");
			return tooltip.style("visibility", "visible");
	  	})
	  	.on("mouseout",function(d){
	  		d3.select(this).select("path").style({"border-style":"none"});
	  		tooltip.style("visibility", "hidden");
	  	});
	});
}