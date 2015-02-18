svg = d3.select '#svgContainer'
  .append 'svg'
  .attr
    width: 800
    height: 450

xScale = d3.scale.linear().range [0, svg.attr 'width']
yScale = d3.scale.linear().range [0, svg.attr 'height']


# Updates the visualization to show the given array of samples.  Each sample
# should be an array of two elements corresponding to the X and Y fields.
update = (pairs) ->
  # Scale the X and Y axes to fit the new data
  getX = (pair) -> pair[0]
  getY = (pair) -> pair[1]
  xScale.domain [(d3.min pairs, getX), (d3.max pairs, getX)]
  yScale.domain [(d3.min pairs, getY), (d3.max pairs, getY)]

  # Update the document
  dots = (svg.selectAll '.dot').data pairs
  dots.exit().remove()
  dots.enter().append 'circle'
    .style 'fill', 'red'
    .attr
      class: 'dot'
      r: 2
  dots.transition()
    .ease 'sin'
    .attr
      cx: (pair) -> xScale pair[0]
      cy: (pair) -> yScale pair[1]


# Load the csv data, which comes from
# http://archive.ics.uci.edu/ml/datasets/Heart+Disease
d3.csv 'heartdisease.csv'
  .get (error, rows) ->
    histogram = d3.layout.histogram().bins 20

    # Show two <selects> to choose the variables shown on each axis
    xFieldSelect = d3.select 'select#xField'
    yFieldSelect = d3.select 'select#yField'
    for field of rows[0]
      xFieldSelect.append 'option'
        .attr 'value', field
        .text field
      yFieldSelect.append 'option'
        .attr 'value', field
        .text field

    # When a different field is selected for either axis, update the
    # visualization with the newly-selected data.
    onChange = () ->
      xField = xFieldSelect.node().value
      yField = yFieldSelect.node().value
      update ([row[xField], row[yField]] for row in rows)

    xFieldSelect.on 'change', onChange
    yFieldSelect.on 'change', onChange
