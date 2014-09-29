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

    # Reference to county geojson (added to file on build)
    self.countyJson = countyJson
    @container = options?.container ? "#map"

    for opt in ['geoJson', 'csv']
      o = options[opt]
      mapError("\"#{opt}\" not provided to Map.") if not o
      self[opt] = o

    @loadCSV @csv, -> @render()


  loadCSV : (filename, callback) ->
    d3.csv self.csv, (e, data) ->
      self.data = data
      callback()
    return self

  render : ->

    # Self Reference for inner function contexts
    self = this

    # These values are not the pixel width and height,
    # But simply a starting point for the w/h ratio
    # Which tightly bounds the map
    width = 1011
    height = 588

    us = @countyJson

    projection = d3.geo.albersUsa()
                    .scale(width)
                    .translate([width/2, height/2])

    path = d3.geo.path().projection(projection)

    containerElement = d3.select(@container)

    svg = containerElement.html ''
            .append 'svg'
            .attr
              class : "urban-map"
              preserveAspectRatio : "xMinYMin slice"
              viewBox :  "0 0 #{width} #{height}"
            .append 'g'

    counties = svg.append 'g'
                .attr 'class', 'counties'
                .selectAll 'path'
                  .data topojson.feature(us, us.objects.counties).features
                .enter()
                  .append 'path'
                  .attr 'd', path

    return self


do ->
  # Export Module
  Urban.Map = Map
  window.Urban = Urban
