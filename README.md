# AppMag
Approximation of Magnetization characteristics
taking into account saturation but neglecting hysteresis

This repository hosts in subdirectory RawData datasets of softmagnetic materials 
as single txt-files, as spreadsheet file RD.ods in OpenDocument format ods 
and as Microsoft Excel format xlsx.
Each material is stored in a separate sheet with the following format:
```
- CastIron                 name of material
- vRef      25.    W/kg    specific lossed
- BRef      1.5    T       flux density for measurement of vRef
- fRef      50.    Hz      frequency for measurement of vRef
- dens    7500.    kg/m3   density of material
- N          22            number of knots
- J[T]   H[A/m]            table of measurements
- 0      0                 starting at the origin
```

Copy data set(s) together with the approximation function into a working directory.
There is a growing collection of functions that can be called in Octave or Matlab.
It is planned to provide different methods of approximation.
First, Smoothing Splines with Exponential Extrapolation [SSEE](https://github.com/AHaumer/AppMag/tree/main/SSEE) are implemented.

## Acknowledgements
Raw data sets were provided by [VoestAlpine](https://www.voestalpine.com/isovac/en/Downloads/Datasheets).
Many thanks for that valuable support!
