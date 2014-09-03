function createStackedBarChart(divId,fileName,disputeId){
	var parentDiv=$("#"+divId);
	var parentDivWidth=parentDiv.width();
	var parentDivHeight=parentDiv.height();
	var margin = {top: 20, right: 80, bottom: 30, left: 50},
	width = parentDivWidth - margin.left - margin.right,
	height = parentDivHeight - margin.top - margin.bottom
    p = [20, 50, 30, 20],
    x = d3.scale.ordinal().range([0,30,60,90,120,150,180,210]),
    y = d3.scale.linear().range([0, height]),
    z = d3.scale.ordinal().range(["#2CA02C","#DA1C1D","yellow"]),  
    format = d3.time.format("%b");
	var svg;
	
	var countryNames=[];
	d3.json(fileName+"?disputeId="+disputeId, function(data) {
		$("#"+divId).html("");
		$(".proanti_lable").remove();
		var countryData=data.data;
		var country=[];
		for(var int=0;int<countryData.length;int+=2){
			var temp={"country":countryData[int].country,"pro":0,"anti":0};
			if(countryData[int].country==countryData[int+1].country){
				countryNames.push(countryData[int].country);
				var total=countryData[int].count+countryData[int+1].count;
				if(countryData[int].favour=="anti"){
					temp.pro=(countryData[int].count/total)*100;
					temp.anti=(countryData[int+1].count/total)*100;
				}else{
					temp.pro=(countryData[int+1].count/total)*100;
					temp.anti=(countryData[int].count/total)*100;
				}
			}
			country.push(temp)
		}
	  // Transpose the data into layers by cause.
		var countries = d3.layout.stack()(["anti","pro"].map(function(favour) {
	    return country.map(function(d) {
	      return {x: d.country, y: +d[favour]};
	    });
	  }));
	svg = d3.select("#"+divId).append("svg")
		.attr("width", width + margin.left + margin.right)
		.attr("height", height + margin.top + margin.bottom)		
		.append("g")
		.attr("transform", "translate(" + 40 + "," + 0 + ")");
		
	svg.style("top",$(parentDiv).position().top)
		.style("left",$(parentDiv).position().left)
	  // Compute the x-domain (by date) and y-domain (by top).
	  x.domain(countries[0].map(function(d) { return d.x; }));
	  y.domain([0, d3.max(countries[countries.length - 1], function(d) { return d.y0 + d.y; })]);
	
	  // Add a group for each cause.
	  var cause = svg.selectAll("g.cause")
	      .data(countries)
	    .enter().append("svg:g")
	      .attr("class", "cause")
	      .style("fill", function(d, i) { return z(i); })
	      .style("stroke", function(d, i) { return d3.rgb(z(i)).darker(); });
	
	  // Add a rect for each date.
	/*  var rect = cause.selectAll("rect")
	      .data(Object)
	    .enter().append("svg:rect")
	      .attr("x", function(d,i) {console.log(i); return x(d.x); })
	      .attr("y", function(d) { return getY(d); })
	      .attr("height",function(d) { return y(d.y);})
	      .attr("width", 20);
*/
	  //All Length
	  var barGroup1=svg.append("g").attr("class","anti");
	  barGroup1.selectAll("rect")
	  			.data(country)
	  			.enter().append("svg:rect")
	  			.attr("x",function(d){return x(d.country);})
	  			.attr("y",25)
	  			.attr("height",200)
	  			.attr("width",20)
	  			.style("fill",function(d){return z(0);})
	  			.style("stroke", function(d, i) { return d3.rgb(z(0)).darker(); });
	  	
	  var barGroup2=svg.append("g").attr("class","pro");
	  barGroup2.selectAll("rect")
			.data(country)
			.enter().append("svg:rect")
			.attr("x",function(d){return x(d.country);})
			.attr("y",25)
			.attr("height",function(d){return getHeight(d);})
			.attr("width",20)
			.style("fill",function(d){return z(1);})
			.style("stroke", function(d, i) { return d3.rgb(z(1)).darker(); });		
	  	
	  	
	  	var wordTop=$(parentDiv).position().top +40;
		var wordLeft=$(parentDiv).position().left -30;
		var i=0;
		$.each(countryNames,function(){		
			var wordDiv=$("<div>").appendTo($(parentDiv).parent());
			$(wordDiv).attr("id","country_"+i);
			$(wordDiv).attr("class","proanti_lable");
			$(wordDiv).text(this);
			$(wordDiv).css({"font-weight":"bold","position":"absolute","top": wordTop + 30 * i,"left":wordLeft});
			i=i+1;
		});
	
	});
	function getHeight(d){
		return 200-(d.pro*2);
	}
	function getH(d){
		if(d.y0==0)
			return -y(d.y);
		else
			return -y(d.y0);
	}
}