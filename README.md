# AppMag
Approximation of Magnetization characteristics
taking into account saturation but neglecting hysteresis

This repository hosts raw data of softmagnetic materials in a spreadsheet file RD.ods
in OpenDocument format ods (which can be read by LibreOffice and Microsoft Excel).
Each material is stored in a separate sheet with the following format:
```
- CastIron                 name of material
- vRef      25.    W/kg    specific lossed
- BRef      1.5    T       flux density for measurement of vRef
- fRef      50.    Hz      frequency for measurement of vRef
- dens    7500.    kg/m3   density of material
- thick    0.35    mm      thickness of sheet
- N          22            number of knots
- J[T]   H[A/m]            table of measurements
- 0      0                 starting at the origin
```
Furthermore there is a growing collection of functions that can be called in Octave or Matlab.
It is planned to provide different methods of approximation.
First, Smoothing Splines with Exponential Extrapolation [SSEE](https://github.com/AHaumer/AppMag/tree/main/SSEE) are implemented.

## Acknowledgements
Raw data was provided by [VoestAlpine](https://www.voestalpine.com/isovac/en/Downloads/Datasheets).
Many thanks for that valuable support!
