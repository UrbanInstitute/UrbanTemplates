###
  D3 County Map Template
  Ben Southgate
  9/29/14
###


Urban = Urban or {}

# Throw error for map
mapError = (text) -> throw "Urban Map Error : #{text}"

###
  Responsive Map Class
###
class Map

  constructor : (options) ->

    self = @
    options ?= {}
    # Added to library from external js file
    self.countyJson = countyJson
    @container = options?.container ? "#map"

    for opt in ['geoJson', 'csv']
      o = options[opt]
      mapError("\"#{opt}\" not provided to Map.") if not o
      self[opt] = o

    d3.csv self.csv, (e, data) ->
      self.data = data
      self.render()

  render : ->

    # Self Reference for inner function contexts
    self = this

    containerElement = d3.select(this.container).style('overflow', 'hidden')

    # These values are not the pixel width and height,
    # But simply a starting point for the w/h ratio
    width = 1011
    height = 588

    projection = d3.geo.albersUsa().scale(width).translate([width/2, height/2.5])

    path = d3.geo.path().projection(projection)

    svg = containerElement.html('')
                .append('svg')
                .attr({
                  "class" : "Urban-Map-County",
                  "preserveAspectRatio" : "xMinYMin meet",
                  "viewBox" : '0 0 ' + width + ' ' + height
                }).append('g')

    us = self.countyJson
    counties = svg.append('g')
      .attr('class', 'counties')
      .selectAll('path')
        .data(topojson.feature(us, us.objects.counties).features)
      .enter()
        .append('path')
        .attr('d', path)


do ->
  # Export Module
  Urban.Map = Map
  window.Urban = Urban
