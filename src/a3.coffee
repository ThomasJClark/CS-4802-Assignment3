svg = d3.select '#svgContainer'
  .append 'svg'
  .attr
    width: 700
    height: 700

# Updates the visualization to show the given array of samples.
#   container is the SVG containing the visualization.
#   data is the CSV data.
#   electedFields is an object literal whose x, y, and c properties specify
#     which fields from data to show.
update = (container, data, selectedFields) ->
  # Scale the X and Y axes to fit the new data
  xScale = d3.scale.linear()
    .domain [(d3.min data, (d) -> +d[selectedFields.x]), (d3.max data, (d) -> +d[selectedFields.x])]
    .range [0, container.attr 'width']
  yScale = d3.scale.linear()
    .domain [(d3.max data, (d) -> +d[selectedFields.y]), (d3.min data, (d) -> +d[selectedFields.y])]
    .range [0, container.attr 'height']

  # Update the document
  dots = (container.selectAll '.dot').data data
  dots.exit().remove()
  dots.enter().append 'circle'
    .attr
      class: 'dot'
      r: '1%'
  dots.transition()
    .ease 'sin-out'
    .attr
      cx:    (datum) -> xScale datum[selectedFields.x]
      cy:    (datum) -> yScale datum[selectedFields.y]
  dots.style 'fill', (datum) ->
    value = datum[selectedFields.c]
    if value is '?' or not discreteVariables[selectedFields.c][+value] then 'Silver'
    else discreteVariables[selectedFields.c][+value]

discreteVariables =
  sex:     [ '#377eb8', '#e41a1c' ]
  fbs:     [ '#99d8c9', '#2ca25f' ]
  exang:   [ '#e0ecf4', '#8856a7' ]
  cp:      [ undefined, '#e41a1c', '#377eb8', '#4daf4a', '#984ea3' ]
  restecg: [ '#4daf4a', '#984ea3', '#ff7f00' ]
  slope:   [ undefined, '#e41a1c', '#377eb8', '#4daf4a' ]
  ca:      [ '#fee5d9', '#fcae91', '#fb6a4a', '#cb181d' ]
  thal:    { 3: '#e41a1c', 6: '#377eb8', 7: '#4daf4a' }
  num:     [ '#ff7f00', '#984ea3' ]

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
      x: 'age'
      y: 'trestbps'
      c: 'sex'

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
              class: 'scatter-matrix-cell'
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
              update svg, rows, selectedFields
            .call () ->
              d = this.node().__data__
              update this, rows, { x: d.xField, y: d.yField, c: selectedFields.c  }

    # Show a <select> to choose which discrete variable to use to color the
    # dots.
    (d3.select '#selectionContainer').append 'h2'
      .text 'Colors'
    colorFieldSelect = (d3.select '#selectionContainer').append 'select'
      .on 'change', () ->
        selectedFields.c = this.selectedOptions[0].value
        update svg, rows, selectedFields

        d3.selectAll 'svg.scatter-matrix-cell'
          .each (d) ->
            update (d3.select this), rows, { x: d.xField, y: d.yField, c: selectedFields.c }

    for field of discreteVariables
      colorFieldSelect.append 'option'
        .attr 'value', field
        .text field

    update svg, rows, selectedFields
