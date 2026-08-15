# SSEE
Smoothing Splines with Exponential Extrapolation to approximate magnetic characteristics

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

Raw data were provided by [VoestAlpine](https://www.voestalpine.com/isovac/en/Downloads/Datasheets).
Many thanks for that valuable support!

Furthermore there is a collection of functions that can be called in Octave or Matlab.
The main function is named as the file: SSEE
par = SSEE(material {, fT, p, H0, H1, H2});
par is a struct containing the parameters:
```
- material      name of material
- HD            array of measured field strength
- JD            array of measured polarization
- mu_rD         relative permeabiility of raw data
- mu_rdD        relative differential permeabiility of raw data
- vRef          specific losses
- BRef          flux density for measurement of vRef
- fRef          frequency for measurement of vRef
- dens          density of material
- k0            index of raw data field strength where exponential extrapolation is based
- hH1           field strength where switch-over from smoothed splines to exponential extrapolation starts
- hH2           field strength where switch-over from smoothed splines to exponential extrapolation ends
- mu_ri         calculated initial reltive permeability
- Jsat          calculated saturation polarization
- Hsat          calculated field strength to reach Jsat with an error of 1 ppm
- Hpar          parameter for exponential extrapolation
- pp            struct containing the parameters of the smoothing splines
- dpp           struct containing the parameters of the derivatives of the smoothing splines
```

material has to be specified: The name of the material, same as the name of the sheet in RD.ods
optional parameters with default values:
```
- ft = 'ods', 'xslx', 'txt'    file type
- p  = 0.005                   parameter for smoothing
- H0 =  2000                   magnetic field strength where exponential extrapolation is based
- H1 =  5000                   field strength where switch-over from smoothed splines to exponential extrapolation starts
- H2 = 20000                   field strength where switch-over from smoothed splines to exponential extrapolation ends
```

The result is compared in figures J(H), mu_r(H) and mu_rd(H) with raw data.
Furthermore, the result is written into a text file named Par_material.txt
which can be used directly in Modelica to extend from the given BaseData.mo.
