# Routines

The routines run both in Matlab and in Octave.

In future, more routines might be added for different approximation methods.

To use the routines, copy the routine together with the directories *functions* and *rawData* in your working directory.

### showRd

should give an overview over the data set under investigation.

Usage: `par=showRD(`'*material*'`)`

*material* refers to the name of the text-file RD_*material*.txt or the name of the sheet *material* in RD.xlsx or RD.ods.

With an optional parameter it is possible to choose the filetype to be used:

* 'txt' (default) uses the text file.

* 'ods' uses the open document spreadsheet.

* 'xlsx' uses the Excel spreadsheet.

The function produces 4 figures described separately in the Description of Results.

## SSEE

calculates the parameters for **Smoothing Splines** with **Exponential Extrapolation**.

Usage: `par=SSEE(`'*material*'`)`

*material* refers to the name of the text-file RD_*material*.txt or the name of the sheet *material* in RD.xlsx or RD.ods.

With an optional parameter it is possible to choose the filetype to be used:

- 'txt' (default) uses the text file.

- 'ods' uses the open document spreadsheet.

- 'xlsx' uses the Excel spreadsheet.

There are 4 additonal optional parameters to control the parameter calculation with the followign default values:

* `p=0.005` defines the smoothing parameter (of the smoothing splines).

* `H0=2000` defines the starting point (root) of the exponential extrapolation.

* `H1=5000` defines the begin of switch-over from *SS* to *EE*.

* `H2=20000` defines the end of switch-over from *SS* to *EE*.

The function produces 4 figures described separately in the Description of Results.

Additionally, the user is asked whether the maximum of  relative permeability&mu;<sub>r</sub> is visible in figure 4. If the answer is "yes", this special point is marked in figure 2 and 4.

The routine's output is a struct par, the structure is explaines separately.

Additionally, the routine stores a file named Par_*material*.txt containing the parameters that could be used in a Modelica record (just copy and paste).
