# Graphical Templates

(Hopefully) helpful javascript templates for data visualization.

# urban.map.js

A re-usable interactive US map for county level data features.


### Building from source

NodeJS, GruntJS, and BrowserSync are required for building from source. Once they are installed, run the following commands:

First install dependencies, then run the following to install local references:

```
npm install
```

Finally, simply "grunt" to build the project and start a dev server. A browser window should open automatically.

```
grunt
```

### Usage

Include `urban.map.min.js` in your html file, along with the necessary D3 libraries:

```html
<!-- import urban.map.css -->
<link rel="stylesheet" href="css/urban.map.css">

<!-- Required D3 Scripts -->
<script src="http://d3js.org/d3.v3.min.js" charset="utf-8"></script>
<script src="http://d3js.org/topojson.v1.min.js"></script>

<!-- import urban.map.js -->
<script src="urban.map.min.js"></script>
```

#### Javascript

To create a map object, use the `Urban.Map` constructor, with options similar to below.


```javascript
/*
  Create a new "Urban Map" object
*/
var map = new Urban.Map({
  // Container div to render map onto (can also just render to 'body')
  "renderTo" : "#map",

  // CSV file containing data to show on map
  "csv" : "data/population.csv",

  // geojson file of us counties (not necessary if using urban.map.bundle.js
  "geoJson" : "json/counties.geo.json",

  // Variable that identifies the county in the csv
  "countyID" : "fips_code",

  // Title for map
  "title" : ( "Lorem ipsum dolor sit amet, " +
              "consectetur adipisicing elit. Ipsam, vel!"),

  // variable to color map by
  "displayVariable" : {

    // name of variable in csv
    "name" : "white_percent",

    // Colors to use in choropleth
    "colors" : ["#b0d5f1","#82c4e9","#0096d2","#00578b","#000000"],

    // number of different breaks (exclude max and min)
    "breaks" : [20,40,60,80],

    /*
      ============================
        optional settings
      ============================
    */
    // (optional) Color for missing data
    "missingColor" : "#aaa",
    // (optional) Settings for map legend
    "legend" : {
      // (optional) Show legend in map
      "enabled" : true,
      // (optional) Set the relative pixel width of the bins in the legend
      "binWidth" : 40,
      // (optional) Format for the legend
      "formatter" : function() {
        // access to value of bin
        return this.value + "%";
      }
    }

  },

  // (optional) HTML for tooltip using variables in csv
  "tooltip" : {
    // (optional) Function which has access to all data (from csv)
    // for the county being mousedover
    "formatter" : function () {

      var check_if_missing = function(variable) {
        // Check to see if the variable is undefined,
        // returning missing text if so.
        return variable ? variable + '%' : '(Not Available)';
      };

      return '<div> ' + this._county_name + ", " + this._state_name + '</div>' +
      '<div> White : ' + check_if_missing(this.white) + '</div>' +
      '<div> Black : ' + check_if_missing(this.black) + '</div>' +
      '<div> Latino : ' + check_if_missing(this.latino) + '</div>'

    },

    // (optional) Opacity of tooltip
    "opacity" : 0.9
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
  max-width: 600px;
  margin: 20px auto;
  border: 4px solid #ccc;
}


/*
  -------------------------------
  Classes created by urban.map.js
  -------------------------------
*/

/* popup tooltip when hovering over a county */
.urban-map-tooltip {
  padding: 10px;
  background-color: white;
  color : #333;
  border-radius : 5px;
  border : 1px solid #aaa;
}

/* the county svg elements themselves */
.urban-map-counties:hover {
  stroke :orange;
  opacity: 0.7;
  stroke-width:3px;
  cursor:pointer;
}

/* the US state elements */
.urban-map-states {
  stroke : white;
  stroke-linejoin: round;
}

/* title text displayed above map */
.urban-map-title {
  width: 50%;
  min-width: 300px;
  float: left;
  display: inline-block;
  font-size: 26px;
  padding: 5px;
}

/* the div containing the svg legend */
.urban-map-legend {
  width: 30%;
  padding: 2%;
  min-width: 250px;
  height: 70px;
  float: right;
  display: inline-block;
}

/* legend title text */
.urban-map-legend-title {
  padding-top: 10px;
  font-size: 18px;
}

/* legend bin labels (svg text elements) */
.urban-map-legend-label {
  font-size: 14px;
}

.urban-map-social {
  width: 100%;
  overflow:hidden;
  display: block;
}

.urban-map-source {
  display: inline-block;
  float: left;
  padding: 0 10px;
}

.urban-map-logo {
  display: inline-block;
  float: right;
  padding: 0 10px;
}

.urban-map-share, .urban-map-embed {
  width: 45%;
  display: inline-block;
  padding: 10px;
}

.urban-map-socialtext {
  width: 100%;
  overflow:hidden;
}

.urban-map-embed,
.urban-map-embed .urban-map-input,
.urban-map-embed .urban-map-button,
.urban-map-embed .urban-map-socialtext span
{
  float: right;
}

.urban-map-share,
.urban-map-share .urban-map-input,
.urban-map-share .urban-map-button,
.urban-map-share .urban-map-socialtext span
{
  float: left;
}

.urban-map-input {
  display:  inline-block;
  width: 50%;
  height: 25px;
  line-height: 25px;
  font-size: 16px;
  padding: 5px;
  margin: 0;
  border: none;
  background-color: #eee;
  -moz-box-sizing: content-box;
  -webkit-box-sizing: content-box;
  box-sizing: content-box;
  color :#999;
}

.urban-map-button {
  display:  inline-block;
  text-align: center;
  width: 60px;
  height: 25px;
  line-height: 25px;
  font-size: 16px;
  margin: 0;
  background-color: #0096d2;
  color :white;
  padding: 5px;
  cursor: pointer;
  border: none;
}

.urban-map-button:hover {
  background-color: #999;
}
```


