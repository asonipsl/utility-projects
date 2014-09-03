function createBarChart(divName,fileName,disputeId){	
	$("#"+divName).html("");
	var barNames=[],frequencies=[];
	var left_width = 0;
	var x, y;
	var parentDiv=$("#"+divName); 
	var yPos=[10,50,90,130,170,210,250,290,330];
 
  var gap = 10;
	d3.json(fileName+"?disputeId="+disputeId, function(error, root) {
		var data=root.data;
		data.forEach(function(d) {			
			barNames.push(d.name);
			frequencies.push(d.frequency);
		});	 
     var chart,
      width = $("#"+divName).width()-10,
      bar_height = 20,
      height = bar_height * barNames.length + 20,
	  text;
	 x = d3.scale.linear()
		 .domain([0, d3.max(frequencies)])
		 .range([0, 100]);
	  

	  y = d3.scale.ordinal()
		.domain(frequencies)
		.rangeBands([0, (bar_height + 2 * gap) * barNames.length]);
	 
	  chart = d3.select($("#"+divName)[0])
		.append('svg')
		.attr('class', 'barChart')
		.attr('width', width)
		.attr('height', (bar_height + gap * 2) * barNames.length + 20)
		.append("g")
		.attr("transform", "translate(0, 15)");
	 
	  chart.selectAll("rect")
		.data(frequencies)
		.enter().append("rect")
		.attr("x", left_width)
		.attr("y", function(d,i) {return yPos[i]; })
		.attr("width", function(d){return getBarWidth(d);})
		.attr("height", bar_height);
	  chart.selectAll("text.score")
		.data(frequencies)
		.enter().append("text")
		.attr("x", function(d){ return getX(d-5);})
		.attr("y", function(d, i){ return yPos[i] + 10; } )
		.attr("dx", -5)
		.attr("dy", ".36em")
		.attr("text-anchor", "end")
		.attr('class', 'score')
		.text(String);
		
		var wordTop=$(parentDiv).position().top + 10;
		var wordLeft=$(parentDiv).position().left + 10;
		var i=0;
		$.each(barNames,function(){		
			var wordDiv=$("<div>").appendTo($(parentDiv));
			$(wordDiv).attr("id","word_"+i);
			$(wordDiv).text(this);
			$(wordDiv).css({"position":"absolute","top": wordTop + 40 * i,"left":wordLeft});
			i=i+1;
		});
		function getBarWidth(value){
			return (x(value)/(width)) * 850;
		}
		function getX(value){
			if(getBarWidth(value) < 30 )
				return 30;			
			else 
				return getBarWidth(value);
		}		
	});
}