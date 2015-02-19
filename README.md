# CS 4802 - Assignment 3

## Dataset
This project uses a dataset of medical data from participants in heart disease research.  I found it at [this website](http://archive.ics.uci.edu/ml/datasets/Heart+Disease).

## Transformations
The left view shows all of the continuous variables in a scatterplot matrix, which the user can click on to choose which variables are assigned to the X and Y axes in the right view.  In the right view, a single enlarged scatterplot is shown, complete with axis ticks and labels.

On the bottom left, I also included a drop-down menu to select a single discrete or binary variable, which is displayed in all scatterplots using one of several colors, as well as a color key.

The visualization will still work if a different dataset with more or less rows is dropped in, as long as it has the same columns.  The website has more datasets, which mostly work, but there is some variation in which columns are included in each file.

## Significance
### Biological
The use of a scatterplot matrix makes in simple for a user to notice biological patterns in the data by looking at a high-level view of every continuous variable.  In addition, the discrete variable coloring applies not just to the main view, but to the matrix view, making correlations between discrete and continuous variables also easy to spot.
### Technical
The visualization intuitively reacts to user input - to selected a different scatterplot, one can just click on one cell in the matrix.  The data is mapped to full names and appropriate colors, and a color key that responds to changes in the data is automatically generated as part of the document.

## Running
This assignment was written in Coffeescript, and a Cakefile is provided to compile it. Assuming npm is installed:

	$ git clone https://github.com/ThomasJClark/CS-4802-Assignment3
	$ cd CS-4802-Assignment3
	$ sudo npm install -g coffee-script
	$ cake build
	$ python3 -m http.server

To view, open `localhost:8000` in Firefox or Chrome.
