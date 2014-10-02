# Graphical Templates

(Hopefully) helpful javascript templates for data visualization.

# urban.map.js

A re-usable interactive US map for county level data features.

[![click to play with](https://github.com/UrbanInstitute/UrbanTemplates/blob/master/example.png)](http://datatools.urban.org/features/bsouthga/UrbanTemplates/Map)

### Usage

Include `urban.map.min.js` in your html file, along with the necessary D3 libraries:

```html
<!-- Required D3 Scripts -->
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="http://d3js.org/topojson.v1.min.js"></script>

<!-- import urban.map.js -->
<script src="urban.map.min.js"></script>
```

#### Javascript

To create a map object, use the `Urban.Map` constructor, with options similar to below.


```javascript
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
```

#### CSS

All aspects of the map can be styled using CSS, and the size of the map SVG is responsive to the size of its container.

```css

/* Example map container */
#map {
  display: block;
  width: 80%;
  min-width: 400px;
  margin: 0px auto;
}

.urban-map-tooltip {
  padding: 10px;
  background-color: white;
  color : #333;
  border-radius : 5px;
  border : 1px solid #aaa;
}

.urban-map-counties:hover {
  stroke :orange;
  opacity: 0.7;
  stroke-width:3px;
  cursor:pointer;
}

.urban-map-states {
  stroke : white;
  stroke-linejoin: round;
}
```


