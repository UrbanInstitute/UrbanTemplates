# Graphical Templates

(Hopefully) helpful javascript templates for data visualization.

## urban.map.js

A re-usable interactive US map for county level data features.

[view example](http://datatools.urban.org/features/bsouthga/UrbanTemplates/Map)

### Usage

simply include `urban.map.min.js` and create a map as follows (see example.html for detailed example usage).

    var map = new Urban.Map({
      // Container div to render map onto
      "renderTo" : "#map",
      // CSV file containing data to show on map
      "csv" : "data/population.csv",
      // geojson file of us counties
      "geoJson" : "json/counties.geo.json",
      // Colors to use in choropleth
      "colors" : ["#b0d5f1","#82c4e9","#0096d2","#00578b","#000000"],
      // Variable that identifies the county in the csv
      "countyID" : "fips_code",
      // variable to color map by
      "displayVariable" : {
        // name of variable in csv
        "name" : "white_percent",
        // number of different breaks (exclude minimum value (0), include maximum)
        "breaks" : [20,40,60,80,100],
        // Settings for map legend
        "legend" : {
          // Show legend in map
          "enabled" : true,
          // Set the relative pixel width of the bins in the legend
          "binWidth" : 40,
          // Format for the legend
          formatter : function() {
            // access to value of bin
            return this.value + "%";
          }
        }
      },
      // HTML for tooltip using variables in csv
      "tooltip" : {
        formatter : function () {
          // Function which has access to all data (from csv)
          // for the county being mousedover
          return '<div> Demographics </div>' +
          '<div> White Percentage : ' + this.white + '% </div>' +
          '<div> Black Percentage : ' + this.black + '% </div>' +
          '<div> Latino Percentage :' + this.latino+ '% </div>'
        },
        // Opacity of tooltip
        opacity : 0.9
      }

    });