## Result: struct par of SSEE

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
- hH1      field strength where switch-over from smoothed splines to exponential extrapolation starts
- hH2      field strength where switch-over from smoothed splines to exponential extrapolation ends
- mu_ri    calculated initial relative permeability
- Jsat     calculated saturation polarization
- Hsat     calculated field strength to reach Jsat with an error of 1 ppm
- Hpar     parameter for exponential extrapolation
- pp       struct containing the parameters of the smoothing splines
- dpp      struct containing the parameters of the derivatives of the smoothing splines
- H_muMax  field strength at maximum permeability
- J_muMax  polarization at maximum permeability
- B_muMax  flux density at maximum permeability
- mu_rMax  maximum relative permeability
```
