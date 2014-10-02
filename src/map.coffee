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
        mapError "\"#{opt}\" not provided to Map."

    # Add tooltip
    @tooltip = options.tooltip ? {formatter : (->) , opacity : 0}

    # Load geojson information and then csv data
    d3.json options.geoJson, (e, us) ->
      self.countyJson = us
      self.loadCSV self.csv, ->
        self.render()
        self.update self.displayVariable


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
    # Method chaining
    return self


  #
  #
  # Draw the map onto given container
  #
  #
  render : ->

    # Self Reference for inner function contexts
    self = @

    # These "magic numbers" are not the pixel width and height,
    # but simply a starting point for the w/h ratio
    # which tightly bounds the map. The actual visible
    # dimensions are set by the svg viewbox.
    width = @width = 1011
    height = @hieght = 588

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

    # Choropleth legend container
    @legend = svg.append 'g'
                .attr
                  class : 'urban-map-legend'

    # County topology
    topodata = topojson.feature(
                  @countyJson,
                  @countyJson.objects.counties
                ).features

    # state topology
    stateTopoData = topojson.mesh(
                      @countyJson,
                      @countyJson.objects.states,
                      (a, b) -> a != b
                    )

    # Tooltip div
    d3.select('div.urban-map-tooltip').remove()
    tooltipDiv = d3.select('body').append('div')
      .attr('class', 'urban-map-tooltip')
      .style
        display : "block"
        position : "absolute"
        opacity : 0

    # Move tooltip to position above mouse
    d3.select('body').on 'mousemove', ->
      [x, y] = [d3.event.pageX, d3.event.pageY]
      tooltipDiv = d3.select('div.urban-map-tooltip')
      tt_bbox = tooltipDiv.node().getBoundingClientRect()
      tooltipDiv.style
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
                  .attr
                    class : 'urban-map-counties'
                    id : (d) -> d.id
                    d : path
                .on 'mouseover', ->
                  # Call formatting function in context of
                  # county specific data
                  tooltipDiv = d3.select('div.urban-map-tooltip')
                  county_data = if @id of df then df[@id] else {}
                  tooltipDiv.html formatter.call county_data
                    .transition()
                    .duration 100
                    .style
                      opacity : opacity
                .on 'mouseout', ->
                  # Fade out tooltip if not over map
                  tooltipDiv = d3.select('div.urban-map-tooltip')
                  tooltipDiv
                    .transition()
                    .duration 100
                    .style
                      opacity : 0

    # Add state mesh
    svg.append "path"
        .datum stateTopoData
        .attr
          class : "urban-map-states"
          d : path
        .style
          fill : 'none'

    # Method chaining
    return self


  #
  #
  # Update the choropleth
  #
  #
  update : (var_obj) ->
    # Self Reference for inner function contexts
    self = @

    # Bins and name for variable to display
    bins = @bins = var_obj.breaks ? @bins ? mapError("No bins provided!")
    name = var_obj.name ? mapError("No variable name provided!")

    # Check for / reset options
    colors   = @colors   = var_obj.colors ? @colors
    fmt      = @fmt      = var_obj.legend?.formatter ? @fmt      ? -> this.value
    binWidth = @binWidth = var_obj.legend?.binWidth  ? @binWidth ? 40
    enable   = @enable   = var_obj.legend?.enabled   ? @enabled  ? true

    # make sure there are enough colors
    b = bins.length
    c = colors.length
    throw "#{b - c} more bins than colors!" if b > c
    throw "#{c - b} more colors than bins!" if b < c

    # create scale for breaks
    color = d3.scale.threshold().domain(bins).range(colors)

    # Clear previous legend
    @legend.empty()

    # If a legend is desired
    if enable
      # Fill Legend with colors and bins
      center = (@width - (binWidth*bins.length)) / 2
      @legend
        .selectAll 'rect'
          .data bins
        .enter()
        .append 'rect'
          .attr
            width : binWidth
            height : binWidth * 0.5
            x : (d, i) -> center + i*binWidth
            y : 50
          .style
            fill : (d) -> color d*0.99

      # Add text to legend
      @legend.selectAll 'text'
            .data bins[..-2]
          .enter()
          .append 'text'
            .text (d) -> fmt.call {value : d}
            .attr
              y : 40
              x : (d, i) -> center + (i+1)*binWidth - binWidth/3

    # Fill the counties with the appropriate color
    fill = (p) -> color(self.data[p.id]?[name] ? "#aaa")

    # Call transition if desired
    if (time = var_obj.transition)
      @counties.transition()
        .duration Math.abs time
        .attr 'fill', fill
    else
      @counties.attr 'fill', fill

    # Method chaining
    return self



##
##
## Export Module
##
##
do ->
  Urban = Urban or {}
  Urban.Map = Map
  window.Urban = Urban
