svg = d3.select '#svgContainer'
  .append 'svg'
  .attr
    width: 500
    height: 500

xScale = d3.scale.linear().range [0, svg.attr 'width']
yScale = d3.scale.linear().range [0, svg.attr 'height']

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00']
shapes = ['.', '*', 'x', 'o', '#']

# Updates the visualization to show the given array of samples.  Each sample
# should have the following properties:
#   x = A continuous variable to show on the x axis
#   y = A continuous variable to show on the y axis
#   c = A discrete variable to show with color
#   s = A discrete variable to show with shape
update = (data) ->
  # Scale the X and Y axes to fit the new data
  xScale.domain [(d3.min data, (d) -> +d.x), (d3.max data, (d) -> +d.x)]
  yScale.domain [(d3.min data, (d) -> +d.y), (d3.max data, (d) -> +d.y)]

  # Update the document
  dots = (svg.selectAll '.dot').data data
  dots.exit().remove()
  dots.enter().append 'text'
    .attr
      class: 'dot'
  dots.transition()
    .ease 'sin'
    .text   (datum) -> shapes[datum.s % colors.length]
    .style
      fill: (datum) -> colors[datum.c % colors.length]
    .attr
      x:    (datum) -> xScale datum.x
      y:    (datum) -> yScale datum.y


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

# Show two <select>s to choose which continuous variables to show
xFieldSelect = d3.select 'select#xField'
yFieldSelect = d3.select 'select#yField'
for field in continuousVariables
  xFieldSelect.append 'option'
    .attr 'value', field
    .text field
  yFieldSelect.append 'option'
    .attr 'value', field
    .text field

# Show <select>s for which discrete variables to show
cFieldSelect = d3.select 'select#cField'
sFieldSelect = d3.select 'select#sField'
for field in discreteVariables
  cFieldSelect.append 'option'
    .attr 'value', field
    .text field
  sFieldSelect.append 'option'
    .attr 'value', field
    .text field

# Load the csv data, which comes from
# http://archive.ics.uci.edu/ml/datasets/Heart+Disease
d3.csv 'heartdisease.csv'
  .get (error, rows) ->
    histogram = d3.layout.histogram().bins 20

    # When a different field is selected for either axis, update the
    # visualization with the newly-selected data.
    onChange = () ->
      xField = xFieldSelect.node().value
      yField = yFieldSelect.node().value
      cField = cFieldSelect.node().value
      sField = sFieldSelect.node().value
      update ({ x: row[xField], y: row[yField], c: row[cField], s: row[sField] } for row in rows)

    xFieldSelect.on 'change', onChange
    yFieldSelect.on 'change', onChange
    cFieldSelect.on 'change', onChange
    sFieldSelect.on 'change', onChange
