
/*
    D3 County Map Template
    Ben Southgate
    9/29/14
 */

(function() {
  var Map, mapError;

  mapError = function(text) {
    throw "Urban Map Error : " + text;
  };

  Map = (function() {
    function Map(options) {
      var o, opt, required, self, us, _i, _len, _ref, _ref1;
      this.options = options;
      self = this;
      options = this.options || {};
      if (!(options.geoJson || Urban.countyGeoJson)) {
        mapError("No county geoJson provided to Map.");
      }
      required = ['csv', 'countyID', 'displayVariable', 'renderTo'];
      for (_i = 0, _len = required.length; _i < _len; _i++) {
        opt = required[_i];
        if ((o = options[opt])) {
          self[opt] = o;
        } else {
          mapError("\"" + opt + "\" not provided to Map.");
        }
      }
      this.tooltip = (_ref = options.tooltip) != null ? _ref : {
        formatter: (function() {}),
        opacity: 0
      };
      if (options.title.enabled) {
        this.title = (_ref1 = options.title.text) != null ? _ref1 : "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ipsam, vel!";
      }
      if (us = Urban.countyGeoJson || Urban.cache[options.geoJson]) {
        self.countyJson = us;
        self.loadCSV(self.csv, function() {
          self.render();
          return self.update(self.displayVariable);
        });
      } else {
        d3.json(options.geoJson, function(e, us) {
          Urban.cache[options.geoJson] = us;
          self.countyJson = us;
          return self.loadCSV(self.csv, function() {
            self.render();
            return self.update(self.displayVariable);
          });
        });
      }
    }

    Map.prototype.loadCSV = function(filename, callback) {
      var cache, cid, self;
      self = this;
      cid = self.countyID;
      cache = Urban.cache;
      if (cache[filename]) {
        self.data = cache[filename];
        callback();
      } else {
        d3.csv(filename, function(e, data) {
          var d, row, _i, _len;
          cache[filename] = self.data = d = {};
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            row = data[_i];
            if (!(cid in row)) {
              mapError("" + cid + " not in csv!");
            }
            d[parseInt(row[cid], 10)] = row;
          }
          return callback();
        });
      }
      return self;
    };

    Map.prototype.render = function() {
      var df, formatter, height, height_bound, legend_container, legend_dims, legend_height, legend_width, max_height, max_width, opacity, path, projection, ratio, renderLegend, renderToElement, self, stateTopoData, svg, tooltipDiv, topodata, width, width_bound, _ref, _ref1;
      self = this;
      this.renderToElement = renderToElement = d3.select(this.renderTo);
      width = this.width = 1011;
      height = this.hieght = 588;
      ratio = width / height;
      projection = d3.geo.albersUsa().scale(width * 1.2).translate([width / 2, height / 2]);
      path = d3.geo.path().projection(projection);
      renderToElement.html('');
      if (this.options.title.enabled) {
        renderToElement.append('div').attr('class', 'urban-map-title').html(this.title);
      }
      renderLegend = (_ref = this.displayVariable) != null ? (_ref1 = _ref.legend) != null ? _ref1.renderTo : void 0 : void 0;
      this.legend_container = legend_container = renderLegend ? d3.select(renderLegend) : renderToElement.append('div');
      legend_dims = legend_container.node().getBoundingClientRect();
      this.legend_height = legend_height = legend_dims.height;
      this.legend_width = legend_width = legend_dims.width || (legend_dims.height / 2);
      this.svg = svg = renderToElement.append('svg').attr({
        "class": "urban-map",
        preserveAspectRatio: "xMinYMin meet",
        viewBox: "0 0 " + width + " " + height
      }).append('g');
      max_height = parseInt(renderToElement.style('max-height')) || 0;
      max_width = parseInt(renderToElement.style('max-width')) || 0;
      width_bound = Math.max(max_width, ratio * max_height);
      height_bound = Math.max(max_height, max_width / ratio);
      if (width_bound > 0) {
        renderToElement.select('svg.urban-map').style('max-width', width_bound + 'px');
      }
      if (height_bound > 0) {
        renderToElement.select('svg.urban-map').style('max-height', width_bound + 'px');
      }
      topodata = topojson.feature(this.countyJson, this.countyJson.objects.counties).features;
      stateTopoData = topojson.mesh(this.countyJson, this.countyJson.objects.states, function(a, b) {
        return a !== b;
      });
      d3.select('div.urban-map-tooltip').remove();
      tooltipDiv = d3.select('body').append('div').attr('class', 'urban-map-tooltip').style({
        display: "block",
        position: "absolute",
        opacity: 0
      });
      this.renderToElement.on('mousemove', function() {
        var tt_bbox, x, y, _ref2;
        _ref2 = [d3.event.pageX, d3.event.pageY], x = _ref2[0], y = _ref2[1];
        tt_bbox = tooltipDiv.node().getBoundingClientRect();
        return tooltipDiv.style({
          top: "" + (y - tt_bbox.height - 20) + "px",
          left: "" + (x - tt_bbox.width / 2) + "px"
        });
      });
      df = self.data;
      formatter = self.tooltip.formatter;
      opacity = self.tooltip.opacity;
      this.counties = svg.append('g').selectAll('path').data(topodata).enter().append('path').attr({
        "class": 'urban-map-counties',
        id: function(d) {
          return d.id;
        },
        d: path
      }).on('mouseover', function() {
        var county_data, _ref2, _ref3;
        tooltipDiv = d3.select('div.urban-map-tooltip');
        county_data = this.id in df ? df[this.id] : {};
        county_data._state_name = (_ref2 = Urban.stateNames) != null ? _ref2[this.id.slice(0, -3)] : void 0;
        county_data._county_name = (_ref3 = Urban.countyNames) != null ? _ref3[this.id] : void 0;
        return tooltipDiv.html(formatter.call(county_data)).style({
          opacity: opacity
        });
      }).on('mouseout', function() {
        tooltipDiv = d3.select('div.urban-map-tooltip');
        return tooltipDiv.style({
          opacity: 0,
          top: "-1000px"
        });
      });
      svg.append("path").datum(stateTopoData).attr({
        "class": "urban-map-states",
        d: path
      }).style({
        fill: 'none'
      });
      return self;
    };

    Map.prototype.update = function(var_obj) {
      var b, binWidth, bins, c, center, color, colors, d, enable, fill, fmt, missingColor, n_bins, name, offset, self, time, _ref, _ref1, _ref10, _ref11, _ref12, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
      self = this;
      bins = this.bins = (_ref = (_ref1 = var_obj.breaks) != null ? _ref1 : this.bins) != null ? _ref : mapError("No bins provided!");
      name = (_ref2 = var_obj.name) != null ? _ref2 : mapError("No variable name provided!");
      missingColor = this.missingColor = var_obj.missingColor || "#aaa";
      colors = this.colors = (_ref3 = var_obj.colors) != null ? _ref3 : this.colors;
      fmt = this.fmt = (_ref4 = (_ref5 = (_ref6 = var_obj.legend) != null ? _ref6.formatter : void 0) != null ? _ref5 : this.fmt) != null ? _ref4 : function() {
        return this.value;
      };
      binWidth = this.binWidth = (_ref7 = (_ref8 = (_ref9 = var_obj.legend) != null ? _ref9.binWidth : void 0) != null ? _ref8 : this.binWidth) != null ? _ref7 : 40;
      enable = this.enable = (_ref10 = (_ref11 = (_ref12 = var_obj.legend) != null ? _ref12.enabled : void 0) != null ? _ref11 : this.enabled) != null ? _ref10 : true;
      n_bins = bins.length;
      b = n_bins;
      c = colors.length;
      d = c - b;
      if (d > 1) {
        console.log("Warning, more bins than colors were provided. " + (d - 1) + " bins were removed, as there needs to be one more color than the number of bins.");
      }
      if (d <= 0) {
        console.log("Warning, too many colors were provided. " + (-(d - 1)) + " colors were removed, as there needs to be one more color than the number of bins.");
      }
      if (d <= 0) {
        bins = bins.slice(0, d - 1);
      }
      if (d > 1) {
        colors = colors.slice(0, -d + 1);
      }
      color = d3.scale.threshold().domain(bins).range(colors);
      this.legend_container.selectAll("*").remove();
      this.legend = this.legend_container.append('svg').attr({
        preserveAspectRatio: "xMinYMin meet",
        viewBox: "0 0 " + this.legend_width + " " + this.legend_height,
        "class": 'urban-map-legend'
      }).append('g');
      offset = 2;
      binWidth = (this.legend_width / (n_bins + 1)) - offset * n_bins;
      if (enable) {
        center = (this.legend_width - (binWidth * n_bins)) / 2;
        this.legend.selectAll('rect').data(bins.concat(bins[-1] * 2)).enter().append('rect').attr({
          width: binWidth,
          height: binWidth * 0.333,
          x: function(d, i) {
            return i * binWidth + i * offset;
          },
          y: this.legend_height * .5
        }).style({
          fill: function(d) {
            return color(d * (d === 0 ? -0.01 : d > 0 ? 0.99 : 1.01));
          }
        });
        this.legend.selectAll('text').data(bins).enter().append('text').attr('class', 'urban-map-legend-label').text(function(d) {
          return fmt.call({
            value: d
          });
        });
        this.legend.selectAll('.urban-map-legend-label').attr({
          y: this.legend_height * .5 - 10,
          x: function(d, i) {
            var w;
            w = this.getBBox().width;
            return (i + 1) * binWidth - w / 2 + i * offset / 2;
          }
        });
      }
      fill = function(p) {
        var v, _ref13, _ref14;
        v = (_ref13 = self.data) != null ? (_ref14 = _ref13[p.id]) != null ? _ref14[name] : void 0 : void 0;
        if (v) {
          return color(v);
        } else {
          return missingColor;
        }
      };
      if ((time = var_obj.transition)) {
        this.counties.transition().duration(Math.abs(time)).attr('fill', fill);
      } else {
        this.counties.attr('fill', fill);
      }
      return self;
    };

    return Map;

  })();

  (function() {
    var Urban;
    Urban = Urban || {};
    if (Urban.cache == null) {
      Urban.cache = {};
    }
    Urban.Map = Map;
    return window.Urban = Urban;
  })();

}).call(this);
