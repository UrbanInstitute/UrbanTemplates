###
  D3 County Map Template
  Ben Southgate
  9/29/14
###

##
##
## Throw module error
##
##
mapError = (text) -> throw "Urban Map Error : #{text}"


##
##
## Class for Responsive County Map
##
##
class Map


  #
  #
  # Map Constructor
  #
  #
  constructor : (options) ->

    # Self Reference for inner function contexts
    self = @
    options ?= {}

    # Check for necessary options
    required = [
      'geoJson',
      'csv',
      'colors',
      'countyID',
      'displayVariable',
      'renderTo'
    ]
    for opt in required
      if (o = options[opt])
        self[opt] = o
      else
        mapError("\"#{opt}\" not provided to Map.")

    # Add tooltip
    @tooltip = options.tooltip ? {formatter : (->) , opacity : 0}

    # Load geojson information and then csv data
    d3.json options.geoJson, (e, us) ->
      self.countyJson = us
      self.loadCSV self.csv, ->
        self.render()
        self.update(self.displayVariable)


  #
  #
  # Load new data into map, running callback on complete
  #
  #
  loadCSV : (filename, callback) ->
    # Self Reference for inner function contexts
    self = @
    cid = self.countyID
    d3.csv filename, (e, data) ->
      # Store data as object referenced by county id
      self.data = d = {}
      for row in data
        mapError("#{cid} not in csv!") if not (cid of row)
        d[row[cid]] = row
      callback()
    return self


  #
  #
  # Draw the map onto given container
  #
  #
  render : ->

    # Self Reference for inner function contexts
    self = this

    # These "magic numbers" are not the pixel width and height,
    # but simply a starting point for the w/h ratio
    # which tightly bounds the map. The actual visible
    # dimensions are set by the svg viewbox.
    width = 1011
    height = 588

    # Albers projection centered in the contianer div
    projection = d3.geo.albersUsa()
                    .scale width
                    .translate [width/2, height/2]

    # Albers path generator
    path = d3.geo.path().projection projection

    # Container element selection
    renderToElement = d3.select @renderTo

    # Create svg with dynamic viewbox
    svg = renderToElement.html ''
            .append 'svg'
            .attr
              class : "urban-map"
              preserveAspectRatio : "xMinYMin slice"
              viewBox :  "0 0 #{width} #{height}"
            .append 'g'

    # County topology
    topodata = topojson.feature(
                  @countyJson,
                  @countyJson.objects.counties
                ).features

    # Tooltip div
    tooltip = d3.select('body').append('div')
      .attr('class', 'urban-map-tooltip')
      .style
        display : "block"
        position : "absolute"
        opacity : 0

    # Move tooltip to position above mouse
    d3.select('body').on 'mousemove', ->
      [x, y] = [d3.event.pageX, d3.event.pageY]
      tt_bbox = tooltip.node().getBoundingClientRect()
      tooltip.style
        top : "#{y - tt_bbox.height - 10}px"
        left : "#{x - tt_bbox.width/2}px"

    # References to data, tooltip formatting function,
    # and desired opacity
    df = self.data
    formatter = self.tooltip.formatter
    opacity = self.tooltip.opacity

    # Create county paths and store as class attribute
    @counties = svg.append 'g'
                .selectAll 'path'
                  .data topodata
                .enter()
                  .append 'path'
                  .attr 'class', 'urban-map-counties'
                  .attr 'id', (d) -> d.id
                  .attr 'd', path
                .on 'mouseover', ->
                  # Call formatting function in context of
                  # county specific data
                  county_data = if @id of df then df[@id] else {}
                  tooltip.html formatter.call(county_data)
                    .transition()
                    .duration(100)
                    .style
                      opacity : opacity
                .on 'mouseout', ->
                  # Fade out tooltip if not over map
                  tooltip
                    .transition()
                    .duration(100)
                    .style
                      opacity : 0
    return self


  #
  #
  # Draw the map onto given container
  #
  #
  update : (var_obj) ->
    # Self Reference for inner function contexts
    self = @
    bins = @bins = var_obj.breaks ? @bins ? mapError("No bins provided!")
    @colors = var_obj.colors ? @colors
    name = var_obj.name

    # make sure there are enough colors
    b = bins.length
    c = @colors.length
    throw "#{b - c} more bins than colors!" if b > c
    throw "#{c - b} more colors than bins!" if b < c

    # create scale for breaks
    color = d3.scale.threshold()
      .domain bins
      .range @colors

    # Fill the counties with the appropriate color
    fill = (p) -> color(self.data[p.id]?[name] ? "#aaa")

    # Call transition if desired
    if (time = var_obj.transition)
      @counties.transition()
        .duration Math.abs(time)
        .attr 'fill', fill
    else
      @counties.attr 'fill', fill

    return self



##
##
## Export Module
##
##
Urban = Urban or {}
do ->
  Urban.Map = Map
  window.Urban = Urban
