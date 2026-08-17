# Roschke-formula
Approximation formula for magnetic characteristics according to:
Thomas Roschke, Entwurf geregelter elektromagnischer Antriebe für Luftschütze, 
VDI-Verlag 2000, ISBN 3-18-329321-8

## Note: This is work in progress.
#### It is not easy to determine optimal parameters. 
#### We do not know how parameters were calculated in the original work.
### Please be very careful using the results!

For a description of raw data see the README in the main directory.

par = Roschke(material {, fT});
par is a struct containing the parameters:
```
- material      name of material
- HD            array of measured field strength
- JD            array of measured polarization
- mu_rD         relative permeabiility of raw data
- vRef          specific losses
- BRef          flux density for measurement of vRef
- fRef          frequency for measurement of vRef
- dens          density of material
- mu_ri         calculated initial reltive permeability
- H_muMax	field strength at maximum permeability
- J_muMax	polarization at maximum permeability
- B_muMax	flux density at maximum permeability
- mu_rMax	maximum relative permeability
```

material has to be specified: The name of the material, same as the name of the sheet in RD.ods
optional parameters with default values:
```
- ft = 'txt', 'xslx', 'ods'    file type
```

The result is compared in figures J(H), mu_r(H) and mu_rd(H) with raw data.
Furthermore, the result is written into a text file named Par_material.txt
which can be used directly in Modelica to extend from the given BaseData.mo.
