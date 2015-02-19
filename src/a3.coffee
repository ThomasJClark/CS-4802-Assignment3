svg = d3.select '#svgContainer'
  .append 'svg'
  .attr
    width: 750
    height: 600

dotsGroup = svg.append 'g'
  .attr
    transform: "translate(#{+(svg.attr 'width') * 0.1}, #{(svg.attr 'height') * 0.1})"
    width:     (svg.attr 'width') * 0.85
    height:    (svg.attr 'height') * 0.85

xAxis = d3.svg.axis()
xAxisGroup = svg.append 'g'
  .attr
    transform: "translate(#{+(svg.attr 'width') * 0.1}, #{+(svg.attr 'height') * 0.05})"
    width:     (svg.attr 'width') * 0.85
    height:    (svg.attr 'height')
xAxisLabel = svg.append 'text'
  .attr
    transform: "translate(#{(svg.attr 'width') * 0.5}, #{(svg.attr 'height') * 0.025 })"
    'text-anchor': 'middle'

yAxis = d3.svg.axis().orient 'right'
yAxisGroup = svg.append 'g'
  .attr
    transform: "translate(#{+(svg.attr 'width') * 0.05}, #{+(svg.attr 'height') * 0.1})"
    width:     (svg.attr 'width')
    height:    (svg.attr 'height') * 0.85
yAxisLabel = svg.append 'text'
  .attr
    transform: "translate(#{(svg.attr 'width') * 0.025}, #{(svg.attr 'height') * 0.5}) rotate(-90)"
    'text-anchor': 'middle'

# Updates the visualization to show the given array of samples.
#   container is the SVG containing the visualization.
#   data is the CSV data.
#   electedFields is an object literal whose x, y, and c properties specify
#     which fields from data to show.
updateDots = (container, data, selectedFields) ->
  # Scale the X and Y axes to fit the new data
  xScale = d3.scale.linear()
    .domain [(d3.min data, (d) -> +d[selectedFields.x]), (d3.max data, (d) -> +d[selectedFields.x])]
    .range [0, container.attr 'width']
  yScale = d3.scale.linear()
    .domain [(d3.max data, (d) -> +d[selectedFields.y]), (d3.min data, (d) -> +d[selectedFields.y])]
    .range [0, container.attr 'height']

  # Update the dots
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
    if value is '?' or not discreteVariableColors[selectedFields.c][+value] then 'Silver'
    else discreteVariableColors[selectedFields.c][+value]

# Update the scales and text labels of the X and Y axes with the ranges and
# names of the selected fields.
#   data is the CSV data.
#   electedFields is an object literal whose x, y, and c properties specify
#     which fields from data to show.
updateAxes = (data, selectedFields) ->
    # Scale the X and Y axes to fit the new data
    xScale = d3.scale.linear()
      .domain [(d3.min data, (d) -> +d[selectedFields.x]), (d3.max data, (d) -> +d[selectedFields.x])]
      .range [0, xAxisGroup.attr 'width']
    yScale = d3.scale.linear()
      .domain [(d3.max data, (d) -> +d[selectedFields.y]), (d3.min data, (d) -> +d[selectedFields.y])]
      .range [0, yAxisGroup.attr 'height']

    xAxisGroup.transition()
      .ease 'sin-out'
      .call (xAxis.scale xScale)
    yAxisGroup.transition()
      .ease 'sin-out'
      .call (yAxis.scale yScale)

    # Set the text on each axis to the name of the appropriate field
    xAxisLabel.text variableNames[selectedFields.x]
    yAxisLabel.text variableNames[selectedFields.y]

# Update the colors and text in the color key to contain the appropriate values
# for the currently selected discrete variable.
updateColorKey  = (selectedFields) ->
  colorKey = (d3.select '#color-key').selectAll 'li'
    .data (d3.zip discreteVariableValues[selectedFields.c], discreteVariableColors[selectedFields.c]).filter (d) ->
      d and d[0] and d[1]
  colorKey.exit().remove()
  colorKey.enter().append 'li'
    .style 'list-style', 'none'
  colorKey
    .text (data) -> data[0]
    .style 'color', (data) -> data[1]

discreteVariableColors =
  sex:     [ '#ff8284', '#377eb8' ]
  fbs:     [ '#99d8c9', '#2ca25f' ]
  exang:   [ '#e0ecf4', '#8856a7' ]
  cp:      [ undefined, '#e41a1c', '#377eb8', '#4daf4a', '#984ea3' ]
  restecg: [ '#4daf4a', '#984ea3', '#ff7f00' ]
  slope:   [ undefined, '#e41a1c', '#377eb8', '#4daf4a' ]
  ca:      [ '#fee5d9', '#fcae91', '#fb6a4a', '#cb181d' ]
  thal:    [ undefined, undefined, undefined, '#e41a1c', undefined, undefined, '#377eb8', '#4daf4a' ]
  num:     [ '#ff7f00', '#984ea3' ]

discreteVariableValues =
    sex:     [ 'Female', 'Male' ]
    fbs:     [ 'No', 'Yes' ]
    exang:   [ 'No', 'Yes' ]
    cp:      [ undefined, 'Typical angina ', 'Atypical angina', 'Non-anginal pain', 'Asymptomatic' ]
    restecg: [ 'Normal', 'ST-T wave abnormality', 'Probable or definite left ventricular hypertrophy' ]
    slope:   [ undefined, 'Upsloping', 'Flat', 'Downsloping' ]
    ca:      [ '0', '1', '2', '3' ]
    thal:    [ undefined, undefined, undefined, 'Normal', undefined, undefined, 'Fixed defect', 'Reversable defect' ]
    num:     [ '< 50% diameter narrowing ', '> 50% diameter narrowing ' ]

continuousVariables = [ 'age', 'trestbps', 'chol', 'thalach', 'oldpeak' ]

# Human-presentable names of each variable, from the website they came from
variableNames =
  age:      'Age (Years)'
  sex:      'Sex'
  cp:       'Chest Pain Type'
  trestbps: 'Resting Blood Pressure'
  chol:     'Serum Cholestoral (mg/dL)'
  fbs:      'Fasting Blood Sugar > 120 mg/dL'
  restecg:  'Resting Electrocardiographic'
  thalach:  'Maximum Heart Rate '
  exang:    'Exercise Induced Angina'
  oldpeak:  'ST Depression by Exercise'
  slope:    'Peak Exercise ST Segment Slope'
  ca:       'Major Vessels Colored by Flourosopy '
  thal:     'thal'
  num:      'Angiographic Disease Status'

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
      .text 'Axes'
    table = (d3.select '#selectionContainer').append 'table'
    for xField in continuousVariables
      row = table.append 'tr'
      for yField in continuousVariables
        if xField is yField
          (row.append 'td').text variableNames[xField]
            .attr
              width: '85px'
              height: '85px'
            .style 'text-align', 'center'
        else
          (row.append 'td').append 'svg'
            .attr
              width: '85px'
              height: '85px'
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
              updateDots dotsGroup, rows, selectedFields
              updateAxes rows, selectedFields
            .call () ->
              d = this.node().__data__
              updateDots this, rows, { x: d.xField, y: d.yField, c: selectedFields.c  }

    # Show a <select> to choose which discrete variable to use to color the
    # dots.
    (d3.select '#selectionContainer').append 'h2'
      .text 'Colors'
    colorFieldSelect = (d3.select '#selectionContainer').append 'select'
      .on 'change', () ->
        selectedFields.c = this.selectedOptions[0].value
        updateDots dotsGroup, rows, selectedFields
        updateColorKey selectedFields

        d3.selectAll 'svg.scatter-matrix-cell'
          .each (d) ->
            updateDots (d3.select this), rows, { x: d.xField, y: d.yField, c: selectedFields.c }

    # Show a color key for the currently selected discrete variable
    (d3.select '#selectionContainer').append 'ul'
      .attr 'id', 'color-key'

    for field of discreteVariableColors
      colorFieldSelect.append 'option'
        .attr 'value', field
        .text variableNames[field]

    updateDots dotsGroup, rows, selectedFields
    updateAxes rows, selectedFields
    updateColorKey selectedFields
