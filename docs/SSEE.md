# SSEE
Smoothing Splines with Exponential Extrapolation to approximate magnetic characteristics

For a description of raw data see the README in the main directory.

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
- H_muMax	field strength at maximum permeability
- J_muMax	polarization at maximum permeability
- B_muMax	flux density at maximum permeability
- mu_rMax	maximum relative permeability
```

material has to be specified: The name of the material (fileName or sheetName)
optional parameters with default values:
```
- ft = 'txt', 'xslx', 'ods'    file type
- p  = 0.005                   parameter for smoothing
- H0 =  2000                   magnetic field strength where exponential extrapolation is based
- H1 =  5000                   field strength where switch-over from smoothed splines to exponential extrapolation starts
- H2 = 20000                   field strength where switch-over from smoothed splines to exponential extrapolation ends
```

The result is compared in figures J(H), mu_r(H) and mu_rd(H) with raw data.
Furthermore, the result is written into a text file named Par_material.txt
which can be used directly in Modelica to extend from the given Modelica record ShowCharacteristic.SSEE.BaseData;
with the Modelica example ShowCharacteristic.Examples.ShowSSEE the behaviour of the approximation can be investigated. 
