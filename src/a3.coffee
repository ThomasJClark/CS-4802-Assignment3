svg = d3.select '#svgContainer'
  .append 'svg'
  .attr
    width: 700
    height: 700

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']

# Updates the visualization to show the given array of samples.  Each sample
# should have the following properties:
#   x = A continuous variable to show on the x axis
#   y = A continuous variable to show on the y axis
#   c = A discrete variable to show with color
update = (container, data) ->
  # Scale the X and Y axes to fit the new data
  xScale = d3.scale.linear()
    .domain [(d3.min data, (d) -> +d.x), (d3.max data, (d) -> +d.x)]
    .range [0, container.attr 'width']
  yScale = d3.scale.linear()
    .domain [(d3.max data, (d) -> +d.y), (d3.min data, (d) -> +d.y)]
    .range [0, container.attr 'height']

  # Update the document
  dots = (container.selectAll '.dot').data data
  dots.exit().remove()
  dots.enter().append 'circle'
    .attr
      class: 'dot'
      r: '1%'
  dots.transition()
    .ease 'sin'
    .style
      fill: (datum) -> colors[datum.c % colors.length]
    .attr
      cx:    (datum) -> xScale datum.x
      cy:    (datum) -> yScale datum.y


binaryVariables = [
  'sex',
  'fbs',
  'exang'
]

discreteVariables = [
  'cp',
  'restecg',
  'slope',
  'ca',
  'thal',
  'num'
]

continuousVariables = [
  'age',
  'trestbps',
  'chol',
  'thalach',
  'oldpeak'
]

# Load the csv data, which comes from
# http://archive.ics.uci.edu/ml/datasets/Heart+Disease
d3.csv 'heartdisease.csv'
  .get (error, rows) ->
    selectedFields =
      x: continuousVariables[0]
      y: continuousVariables[1]
      c: discreteVariables[0]

    histogram = d3.layout.histogram().bins 20

    # Add a table of SVGs for every pairing of continuous variables.  When one
    # of the mini SVGs is clicked, the main view updates to that pair of
    # variables.
    (d3.select '#selectionContainer').append 'h2'
      .text 'X and Y Locations'
    table = (d3.select '#selectionContainer').append 'table'
    for xField in continuousVariables
      row = table.append 'tr'
      for yField in continuousVariables
        if xField is yField
          (row.append 'td').text xField
            .style 'text-align', 'center'
        else
          (row.append 'td').append 'svg'
            .attr
              width: '75px'
              height: '75px'
            .style
              display: 'block'
            .data [{ xField: xField, yField: yField }]
            .on 'mouseover', () ->
              (d3.select this).style 'border-color', 'RoyalBlue'
            .on 'mouseout', () ->
              (d3.select this).style 'border-color', 'Silver'
            .on 'click', (d) ->
              selectedFields.x = d.xField
              selectedFields.y = d.yField
              update svg, ({ x: r[selectedFields.x], y: r[selectedFields.y], c: r[selectedFields.c] } for r in rows)
            .call () ->
              d = this.node().__data__
              update this, ({ x: r[d.xField], y: r[d.yField], c: 0 } for r in rows)

    # Show a <select> to choose which discrete variable to use to color the
    # dots.
    (d3.select '#selectionContainer').append 'h2'
      .text 'Colors'
    colorFieldSelect = (d3.select '#selectionContainer').append 'select'
      .on 'change', () ->
        selectedFields.c = this.selectedOptions[0].value
        update svg, ({ x: r[selectedFields.x], y: r[selectedFields.y], c: r[selectedFields.c] } for r in rows)

    for field in discreteVariables
      colorFieldSelect.append 'option'
        .attr 'value', field
        .text field
