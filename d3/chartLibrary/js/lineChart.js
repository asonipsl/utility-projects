function drawLineChart(type,divId,disputeId){	
	var parentDiv=$("#"+divId);
	var parentDivWidth=parentDiv.width();
	var parentDivHeight=parentDiv.height();
	var margin = {top: 20, right: 80, bottom: 30, left: 50},
		width = parentDivWidth - margin.left - margin.right,
		height = parentDivHeight - margin.top - margin.bottom;
	var fileName="",interpolateOption="";
	var parseDate;
	var lineNames=[];
	var tickFormat="";
	if(type=="lineChart"){
		fileName="/PirateToInsight/rest/disputews/getLineChart?dispute="+disputeId;
		interpolateOption="line";
		parseDate= d3.time.format("%Y-%m").parse;
		tickFormat="%Y";
	}else if(type=="CountrySentiment"){
		fileName="/PirateToInsight/rest/disputews/getSentiment?dispute="+disputeId+"&entity_type=country";
		interpolateOption="cardinal";
		parseDate= d3.time.format("%Y").parse;
		tickFormat="%Y";
	}else if(type=="PersonSentiment"){		
		fileName="/PirateToInsight/rest/disputews/getPersonSentiment?dispute="+disputeId+"&entity_type=person";
		interpolateOption="cardinal";
		parseDate= d3.time.format("%Y").parse;
		tickFormat="%y";
	}
	
	var x = d3.time.scale().range([0, width]);
				
	var y = d3.scale.linear()
		.rangeRound([height, 0]);

	var color = d3.scale.category10();

	var xAxis = d3.svg.axis()
		.scale(x)
		.orient("bottom")
		.tickFormat(d3.time.format(tickFormat));

	var yAxis = d3.svg.axis()
		.scale(y)
		.orient("left")		
		.tickSize(-width, 0, 0);
				
	var line = d3.svg.line()
		.interpolate(interpolateOption)
		.x(function(d) { return x(d.date); })
		.y(function(d) { return y(d.sentiment); });

	d3.json(fileName, function(error, data) {
		color.domain(data.names);
		data=data.data;
		data.forEach(function(d) {
			d.date = parseDate(d.date);
			d.count=0;
		});	
		var cities = color.domain().map(function(name,i) {
			lineNames.push(name);
			return {
			  name: name,
			  values: data.map(function(d) {	
				 
				  if(d[name]==undefined || d[name]=="undefined" || d[name]==""){
					  d[name]=0.0;
				  }
				  d.count+=parseInt(d[name]);
				return {date: d.date, sentiment: d[name],tooltipText:d.tooltip[i]};
			  })	  
			};
		 });
	
	$("#"+divId).empty();
	var svg;
		
		if(type=="lineChart"){
		 svg = d3.select("#"+divId).append("svg")
			.attr("width", width + margin.left + margin.right)
			.attr("height", height + margin.top + margin.bottom)
			.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
			x.domain(d3.extent(data, function(d) { return d.date; }));
			
			y.domain([
				d3.min(data, function(c) { return d3.min(data, function(v) { return v.count; }); }),
				d3.max(data, function(c) { return d3.max(data, function(v) { return v.count; }); })+50
			]);
			line.y(function(d) { return y(d.count); });
			svg.append("g")
				.attr("class", "x axis")
				.attr("transform", "translate(0," + height + ")")
				.call(xAxis);
			svg.append("g")
				.attr("class", "y axis")
				  .call(yAxis)
				  .append("text")
				  .attr("transform", "rotate(-90)")
				  .attr("y", 6)
				  .attr("dy", ".71em")
				  .style("text-anchor", "end");
				//.text("Cable Count");
			
			var path=svg.append("path")
			  .datum(data)
			  .attr("class", "line")
			  .attr("d", line)
			  .attr("data-legend",function(d) { return d.name});
			var dotsGroup=svg.append("g");
			var dots= dotsGroup.selectAll(".dot").data(data);
			dots.enter().append("circle")
			  .attr("class", "dot")
			  .attr("cx", function (d) {  		
				  return x(d.date);
			  })
			  .attr("cy", function (d) {  		
				  return y(d.count);
			  })		
			  .attr("tooltip",function (d) {  		
				  return d.tooltip[0];
			  })
			  .attr("r", 2.5);		
		  
			//To draw the events overlay on chart.
			var startDate=d3.min(data, function(c) { return c.date;});
			var endDate=d3.max(data, function(c) { return c.date;});
			drawEvents(svg,path.node(),x,disputeId,startDate,endDate);
			
		}else{
			svg = d3.select("#"+divId).append("svg")
			.attr("width", width + margin.left + margin.right-10)
			.attr("height", height + margin.top + margin.bottom)
			.append("g")
			.attr("transform", "translate(" + margin.left + "," + 0 + ")");
			
			x.domain(d3.extent(data, function(d) { return d.date; }));
//			var minDate=d3.min(cities, function(c) { return d3.min(c.values, function(v) { return v.date; }); });
//			var maxDate=d3.max(cities, function(c) { return d3.max(c.values, function(v) { return v.date; }); });
//			x.domain([minDate,maxDate]);
			
			var min=d3.min(cities, function(c) { return d3.min(c.values, function(v) { return v.sentiment; }); });
			var max=d3.max(cities, function(c) { return d3.max(c.values, function(v) { return v.sentiment; }); });
		
//			y.domain([min-0.2,max+0.2]);
			y.domain([-0.6,0.6]);
			yAxis.ticks(8);
		 
		svg.append("g")
		  .attr("class", "y axis")
		  .call(yAxis)
		  .append("text")
		  .attr("transform", "rotate(-90)")
		  .attr("y", 6)
		  .attr("dy", ".71em")
		  .style("text-anchor", "end");
		  //.text("sentiment (ºF)");

		  svg.append("g")
			  .attr("class", "x axis")
			  .attr("transform", "translate(0," + y(0) + ")")
			  .call(xAxis);
		  
		  var lines = svg.selectAll(".country")
			  .data(cities)
			  .enter().append("g")
			  .attr("class", "country")
			  .attr("id",function(d,i){return i;});
		  lines.append("path")
			  .attr("class", "line")
			  .attr("d", function(d) { return line(d.values); })
			  .attr("data-legend",function(d) { return d.name})
			  .style("stroke", function(d) { return color(d.name); });
		  
		  
		  
		  if(type=="CountrySentiment"){
			  for ( var lineNum = 0; lineNum < lineNames.length; lineNum++) {
				  var dotsGroup=svg.append("g")
				  					.attr("id",lineNum+"_"+lineNum)
				  					.attr("class","dotsGroup");
				  var dots= dotsGroup.selectAll(".dot").data(data);
				  dots.enter().append("circle")
				  .attr("class", "dot")
				  .attr("cx", function (d,i) {  		
					  return x(d.date);
				  })
				  .attr("cy", function (d,i) {  		
					  return y(getY(cities,lineNum,i));
				  })		
				  .attr("tooltip",function (d,i) {  		
					  return getTooltipText(cities,lineNum,i);
				  })
				  .attr("r", 2.5);				  
				  
			  }			  
		  }else{
			  for ( var lineNum = 0; lineNum < lineNames.length; lineNum++) {		
				  var dotsGroup=svg.append("g")
					.attr("id",lineNum+"_"+lineNum)
					.attr("class","dotsGroup");
				  var dots= dotsGroup.selectAll(".dot").data(data);
				  dots.enter().append("circle")
				  .attr("class", "dot")				  
				  .attr("cx", function (d,i) {  		
					  return x(d.date);
				  })
				  .attr("cy", function (d,i) {  		
					  return y(getY(cities,lineNum,i));
				  })		
				  /*.attr("tooltip",function (d,i) {  		
					  return getTooltipText(cities,lineNum,i);
				  })*/
				  .attr("r", 2.5);
			  }
		  }
		  $("#"+divId).append(				  
				$("<ul>")
				.attr("class","legend_ul")
				.attr("id",divId+"_legend")
				.append(
						$("<li>")						
						.attr("id",-1)
						.attr("parentdivId",divId)
						.attr("class","active")
						.html("All")						
						.on("click",function(e,i){
							legendClickEvent(divId,this,lineNames.length,true);
						})
				)
		  );
		  lineNames.forEach(function(name,i){
			  $("#"+divId+"_legend")
				.append(
						$("<li>")						
						.attr("id",i)
						.attr("parentdivId",divId)
						.attr("class","active")
						.html(name)
						.css("color",color(name))
						.on("click",function(e,i){
							legendClickEvent(divId,this,lineNames.length,false);
						})
				);
		  });		  
		}
		/*var legend = svg.append("g")
		.attr("class","legend")
		.attr("transform","translate(340,5)")
		.style("font-size","12px")
		.call(d3.legend)	 
		
		$(".legend-box").css("display","none");
		*/
		
		//Attaching the tooltip on circles.	
		
		var tooltip=d3.select("div.tooltip");
		d3.select("#"+divId).selectAll('circle.dot').on("mouseover", function(d){
			d3.select(this).attr('r',4.0);
			if(type=="lineChart"){				
				tooltip.html("<div>Year: "+d.date.getFullYear()+"<br/>Cable Count:"+d.count+"</div>");
				tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-150)+"px");
				return tooltip.style("visibility", "visible");
			}else{
				if("CountrySentiment"){					
					var index=lineNames.indexOf(d3.select(this).attr('tooltip'));			
					tooltip.html(d.tooltip[index]);
					tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-50)+"px");
				}else{					
					tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-150)+"px");
				}
				return tooltip.style("visibility", "hidden");
			}	
			
		})
		.on("mousemove", function(d){
			d3.select(this).attr('r',4.0);
			if(type=="lineChart"){			
				tooltip.html("<div>Year: "+d.date.getFullYear()+"<br/>Cable Count:"+d.count+"</div>");
				tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-150)+"px");
			}else{
				if("CountrySentiment"){
					var index=lineNames.indexOf(d3.select(this).attr('tooltip'));
					tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-50)+"px");
					tooltip.html(d.tooltip[index]);
				}else{					
					tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-150)+"px");
				}
			}			
			return tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX-150)+"px");
		})
		.on("mouseout", function(){
			d3.select(this).attr('r',2.5);
			return tooltip.style("visibility", "hidden");
		});
	
	});
	
}
/*function toggleCauseBtn(){	
	if($("#countStat").attr("stat")==1){		
		$("#countStat").css("display","none");
		$("#countStat").attr("stat",0);
	}else{		
		$("#countStat").css("display","block");
		$("#countStat").attr("stat",1);
	}
}*/
function legendClickEvent(divId,target,totalLines,isShowAll){	
	if(isShowAll){
		d3.select("#"+divId).selectAll(".country").style("display","block");
		d3.select("#"+divId).selectAll(".dotsGroup").style("display","block");	
	}else{
		$(this).parent().find().removeClass("active");
		$(this).parent().children().addClass("inactive");
		$(this).toggleClass("inactive");
		$(this).toggleClass("active");
		var parentId=$(target).attr("parentdivId");
		var lineCount=$(target).attr("id");
		d3.select("#"+parentId).select("svg").select("g").selectAll(".country").style("display","none");
		$("#"+parentId).find(".dotsGroup").css("display","none");		
		$("#"+parentId).find("svg").find("g").find("#"+lineCount).css("display","block");
		$("#"+parentId).find("#"+lineCount+"_"+lineCount+".dotsGroup").css("display","block");
	}
}
function getY(cities,lineCount,dotCount){
	return cities[lineCount].values[dotCount].sentiment;
}
function getTooltipText(cities,lineCount,dotCount){	
	return cities[lineCount].values[dotCount].tooltipText;
}
function drawEvents(svg,path,xScale,disputeId,startDate,endDate){
	var parseDate= d3.time.format("%Y-%m").parse;	
	d3.json("/PirateToInsight/rest/disputews/getDisputeEvent?disputeId="+disputeId,function(error,data){
		var eventData=[];
		data.forEach(function(d){
			d.event="";
			d.date=parseDate(d.date);			
			d.events.forEach(function(v){
				d.event+=v+"<br/>";
			});
			if(d.date>startDate && d.date<endDate){
				eventData.push({"date":d.date,"event":d.event});
			}
		});
		
		
		var image=svg.selectAll("image")
			.data(eventData)
			.enter().append("svg:image")
				.attr("xlink:href", "/PirateToInsight/images/event1.png")
			    .attr("x", function(d){return xScale(d.date);})
			    .attr("y", function(d){var pos=getPosByDate(path,xScale,d.date); return (pos.y-30);})
			    .attr("width", "36")
			    .attr("height", "36");
		var tooltip=d3.select("div.tooltip");		
		//Attaching the tooltip on images.	
		d3.selectAll('image').on("mouseover", function(d){				
			tooltip.html(d.event);
			tooltip.style("top",(d3.event.pageY+30)+"px").style("left",(d3.event.pageX-50)+"px");
			return tooltip.style("visibility", "visible");
		})
		.on("mousemove", function(d){
			tooltip.html(d.event);
			return tooltip.style("top",(d3.event.pageY+30)+"px").style("left",(d3.event.pageX-50)+"px");
		})
		.on("mouseout", function(){
			return tooltip.style("visibility", "hidden");
		});
	});
		
}
function getPosByDate(path,xScale,dateValue){
	var target = Math.ceil(xScale(dateValue));
    var pos = path.getPointAtLength(target);    
    return pos;
}