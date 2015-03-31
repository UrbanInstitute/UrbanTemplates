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
  constructor : (@options) ->

    # Self Reference for inner function contexts
    self = @
    options = @options or {}

    #
    # check for geojson passed in options or
    # preloaded with bundle
    #
    if not (options.geoJson or Urban.countyGeoJson)
      mapError "No county geoJson provided to Map."

    # Check for necessary options
    required = [
      'csv',
      'countyID',
      'displayVariable',
      'renderTo'
    ]
    for opt in required
      if (o = options[opt])
        self[opt] = o
      else
        mapError "\"#{opt}\" not provided to Map."

    # Check for tooltip formatting function, creating placeholder if nec.
    @tooltip = options.tooltip ? {formatter : (->) , opacity : 0}

    # Default title to lorem
    if options.title.enabled
      @title = options.title.text ? "
          Lorem ipsum dolor sit amet,
          consectetur adipisicing elit. Ipsam, vel!
        "

    # Checked for cached geojson, loading if not
    if us = Urban.countyGeoJson or Urban.cache[options.geoJson]
      self.countyJson = us
      self.loadCSV self.csv, ->
        self.render()
        self.update self.displayVariable
    else
      # Load geojson information and then csv data
      d3.json options.geoJson, (e, us) ->
        Urban.cache[options.geoJson] = us
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
    cache = Urban.cache
    # Check for cached data, downloading if nec.
    if cache[filename]
      self.data = cache[filename]
      callback()
    else
      d3.csv filename, (e, data) ->
        # Store data as object referenced by county id
        cache[filename] = self.data = d = {}
        # convert list to object = countyID => row
        for row in data
          mapError("#{cid} not in csv!") if not (cid of row)
        #parseInt(n, 10) removes leading zeroes for fips in states AL -> CT (alphabetically)
          d[parseInt(row[cid],10)] = row;
        # run callback
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

    # Container element selection
    @renderToElement = renderToElement = d3.select @renderTo

    # This "magic number" is not the pixel width and height ratio,
    # but simply a starting point for the w/h ratio
    # which tightly bounds the map. The actual visible
    # dimensions are set by the svg viewbox.
    width = @width = 1011
    height = @hieght = 588

    ratio = width / height



    # Albers projection centered in the contianer div
    projection = d3.geo.albersUsa()
                    .scale width*1.2
                    .translate [width/2, height/2]

    # Albers path generator
    path = d3.geo.path().projection projection

    # Empty container element of contents
    renderToElement.html ''

    # Append title text div
    if @options.title.enabled
      renderToElement.append 'div'
        .attr 'class', 'urban-map-title'
        .html @title

    # Div container for chart legend
    renderLegend = @displayVariable?.legend?.renderTo
    @legend_container = legend_container =
      if renderLegend
        d3.select renderLegend
      else
        renderToElement.append 'div'

    # Calculate height and width for legend
    # based on container dimensions (set by css)
    legend_dims = legend_container.node().getBoundingClientRect()
    @legend_height = legend_height = legend_dims.height
    @legend_width = legend_width = legend_dims.width or (legend_dims.height / 2)

    # Create svg with dynamic viewbox
    @svg = svg = renderToElement
            .append 'svg'
            .attr
              class : "urban-map"
              preserveAspectRatio : "xMinYMin meet"
              viewBox :  "0 0 #{width} #{height}"
            .append 'g'

    #
    #
    # Constrain svg to maximum dimensions, allowing for centering
    #
    #
    max_height = parseInt(renderToElement.style 'max-height') or 0
    max_width = parseInt(renderToElement.style 'max-width') or 0
    width_bound = Math.max max_width, ratio*max_height
    height_bound = Math.max max_height, max_width / ratio
    if width_bound > 0
      renderToElement.select('svg.urban-map')
        .style('max-width', width_bound+'px')
    if height_bound > 0
      renderToElement.select('svg.urban-map')
        .style('max-height', width_bound+'px')


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
    @renderToElement.on 'mousemove', ->
      [x, y] = [d3.event.pageX, d3.event.pageY]
      tt_bbox = tooltipDiv.node().getBoundingClientRect()
      tooltipDiv.style
        top :  "#{y - tt_bbox.height - 20}px"
        left : "#{x - tt_bbox.width / 2  }px"

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
                  county_data._state_name = Urban.stateNames?[@id[...-3]]
                  county_data._county_name = Urban.countyNames?[@id]
                  tooltipDiv.html formatter.call county_data
                    .style
                      opacity : opacity
                .on 'mouseout', ->
                  # Fade out tooltip if not over map
                  tooltipDiv = d3.select('div.urban-map-tooltip')
                  tooltipDiv
                    .style
                      opacity : 0
                      top : "-1000px"

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
    missingColor = @missingColor = var_obj.missingColor or "#aaa"

    # Check for / reset options
    colors   = @colors   = var_obj.colors ? @colors
    fmt      = @fmt      = var_obj.legend?.formatter ? @fmt      ? -> @value
    binWidth = @binWidth = var_obj.legend?.binWidth  ? @binWidth ? 40
    enable   = @enable   = var_obj.legend?.enabled   ? @enabled  ? true
    n_bins = bins.length

    # make sure there are enough colors
    b = n_bins
    c = colors.length
    # There should be one more color than bins
    d = c-b

    if d > 1
      console.log "
        Warning, more bins than colors were provided.
        #{d-1} bins were removed, as there needs to be
        one more color than the number of bins.
      "
    if d <= 0
      console.log "
        Warning, too many colors were provided.
        #{-(d-1)} colors were removed, as there
        needs to be one more color than the
        number of bins.
      "

    # Correct ratio of bins to colors
    bins = bins[...d-1] if d <= 0
    colors = colors[...-d+1] if d > 1

    # create scale for breaks
    color = d3.scale.threshold().domain(bins).range(colors)

    # Clear previous legend
    @legend_container.selectAll("*").remove()

    # Append svg element to draw legend
    @legend = @legend_container
          .append 'svg'
            .attr
              preserveAspectRatio : "xMinYMin meet"
              viewBox :  "0 0 #{@legend_width} #{@legend_height}"
              class : 'urban-map-legend'
            .append 'g'

    # Spacing between legend bins
    offset = 2

    # Width of colored bins
    binWidth = (@legend_width / (n_bins+1)) - offset*(n_bins)

    # If a legend is desired
    if enable
      # Fill Legend with colors and bins
      center = (@legend_width - (binWidth*n_bins)) / 2
      @legend
        .selectAll 'rect'
          .data bins.concat bins[-1]*2
        .enter()
        .append 'rect'
          .attr
            width : binWidth
            height : binWidth * 0.333
            x : (d, i) -> i*binWidth + i*offset
            y : @legend_height * .5
          .style
            # hack to fill colors below bins
            fill : (d) -> color d * (
              if d == 0
                -0.01
              else if d > 0
                0.99
              else
                1.01
            )

      # Add text to legend
      @legend.selectAll 'text'
            .data bins
          .enter()
          .append 'text'
            .attr 'class', 'urban-map-legend-label'
            .text (d) -> fmt.call value : d

      @legend.selectAll '.urban-map-legend-label'
            .attr
              y : @legend_height * .5 - 10
              x : (d, i) ->
                # Calculate width of bin text
                # and use it to position over
                # gap between successive bins
                w = @getBBox().width
                (i+1)*binWidth - w/2 + i*offset/2

    # Fill the counties with the appropriate color
    fill = (p) ->
      v = self.data?[p.id]?[name]
      if v then color(v) else missingColor

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
  Urban.cache ?= {}
  Urban.Map = Map
  window.Urban = Urban
