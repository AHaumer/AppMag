within ;
package ShowCharacteristic
  "Library for modelling of electromagnetic devices with lumped magnetic networks"
  import Modelica.Units.SI;
  import Modelica.Constants.mu_0;

  extends Modelica.Icons.Package;

  package Examples "Illustration of component usage with simple models of various devices"
    extends Modelica.Icons.ExamplesPackage;

    model ShowSSEE "Investigate magnetic characteristic"
      extends Modelica.Icons.Example;
      import ShowCharacteristic.SSEE.Functions.app_J;
      import ShowCharacteristic.SSEE.Functions.app_mu_r;
      import ShowCharacteristic.SSEE.Functions.app_mu_rd;
      parameter ShowCharacteristic.SSEE.M350_50A material
        annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
      constant SI.Time Tend=1;
      parameter SI.MagneticFieldStrength Hmin=-1000 "Start of H";
      parameter SI.MagneticFieldStrength Hmax=+1000 "End of H";
      SI.MagneticFieldStrength H=Hmin + (Hmax - Hmin)*time/Tend "Driving field strength";
      parameter SI.Area wA=1 "Number of turns x area";
      SI.MagneticPolarization J=app_J(H, material) "Approx. polarization";
      SI.MagneticFluxDensity B=mu_0*H + J "Approx. flux density";
      SI.RelativePermeability mu_r=app_mu_r(H, material) "Approx. relative permeability";
      SI.RelativePermeability mu_rd=app_mu_rd(H, material) "Approx. relative differential permeability";
      SI.MagneticFlux psi=wA*B "Flux linkage";
      SI.Voltage v=-der(psi) "Induced voltage";
      annotation (experiment(
          StopTime = 1,
          Interval=0.0001,
          Tolerance=1e-06), Documentation(info="<html>
<p>
Magnetic field Strength <code>H</code> is varied within 1 second from <code>Hmin</code> to <code>Hmax</code>. 
Magnetic polarization <code>J</code>, magnetic flux density <code>B</code>, relative permeability <code>mu_r</code>, differential relative permeability <code>mu_rd</code>, 
magnetic flux linkage <code>psi</code> and induced voltage <code>v</code> are calculated an can be plotted versus H to investigate the characteristic of the choosen material. 
Additionally, all approximation functions are tested. 
</p>
</html>"));
    end ShowSSEE;
    annotation (Documentation(info="<html>
</html>"));
  end Examples;

  package Roschke "Softmagnetic material with approximation acc. to Rischke"
    extends Modelica.Icons.MaterialPropertiesPackage;
    package Functions
      extends Modelica.Icons.FunctionsPackage;
      function app_mu_r
        "Approximation of relative permeability mu_r as a function of flux density B for soft magnetic materials"
        extends Modelica.Icons.Function;
        input SI.MagneticFluxDensity B
          "Flux density in ferromagnetic flux tube element";
        //Material specific parameter set:
        input ShowCharacteristic.Roschke.BaseData material "Material data";
        output SI.RelativePermeability mu_r=
          1 + (material.mu_i - 1 + material.c_a*B_N)/(1 + material.c_b*B_N + B_N^material.n)
          "Relative magnetic permeability of ferromagnetic flux tube element";
      protected
        Real B_N=abs(B/material.B_myMax)
          "Flux density B normalized to flux density at maximum relative permeability B_myMax";
        annotation (Inline=true, Documentation(info="<html>
<p>
The relative permeability mu_r as a function of flux density B for all soft magnetic materials currently included in this library is approximated with the following function <a href=\"modelica://Modelica.Magnetic.FluxTubes.UsersGuide.Literature\">[Ro00]</a>:
</p>

<div>
<img src=\"modelica://Modelica/Resources/Images/Magnetic/FluxTubes/Material/SoftMagnetic/eq_mu_rApprox.png\" alt=\"Equation for approximation mu_r(B)\"/>
</div>

<p>
Two of the five parameters of this equation have a physical meaning, namely the initial relative permeability mu_i at B=0 and the magnetic flux density at maximum permeability B_myMax. B_N is the flux density normalized to latter parameter.</p>
</html>"));
      end app_mu_r;
    end Functions;

    record BaseData "Coefficients for approximation of soft magnetic materials"

      extends Modelica.Icons.Record;
      parameter String label="SoftMagnetic" "Name of material";
      parameter SI.RelativePermeability mu_i=1
        "Initial relative permeability at B=0";
      parameter SI.MagneticFluxDensity B_myMax=1
        "Flux density at maximum relative permeability";
      parameter Real c_a=1 "Coefficient of approximation function";
      parameter Real c_b=1 "Coefficient of approximation function";
      parameter Real n=1 "Exponent of approximation function";

      annotation (defaultComponentPrefixes="parameter",
        Documentation(info="<html>
<p>
The parameters needed for <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic.mu_rApprox\">approximation of the magnetisation characteristics</a> of included soft magnetic materials are declared in this record.
</p>
</html>"),     Icon(graphics={Text(
              extent={{-100,-10},{100,-40}},
              textColor={0,0,255},
              textString="%label")}));
    end BaseData;

    package ElectricSheet "Various electric sheets"
      extends Modelica.Icons.MaterialPropertiesPackage;

      record M330_50A "M330-50A (1.0809) @ 50Hz complete core"
        extends ShowCharacteristic.Roschke.BaseData(
          label="M330-50A",
          mu_i=500,
          B_myMax=0.7,
          c_a=24000,
          c_b=9.38,
          n=9.6);
        annotation (defaultComponentPrefixes="parameter",
          preferredView="info",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Sample: complete core after machining and packet assembling<br>
</p>
<h4>Note</h4>
<p>
This material has been measured under different conditions (complete core / machined and packeted) as the other electric sheets (sheet strip / Epstein frame).
Direct comparison with other material is therefore not possible.
</p>
</html>"));
      end M330_50A;

      record M350_50A "M350-50A (1.0810) @ 50Hz"
        extends ShowCharacteristic.Roschke.BaseData(
          label="M350-50A",
          mu_i=1210,
          B_myMax=1.16,
          c_a=24630,
          c_b=2.44,
          n=14);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Sample: sheet strip<br>
Measurement: Epstein frame
</p>
</html>"));
      end M350_50A;

      record M530_50A "M530-50A (1.0813) @ 50Hz"
        extends ShowCharacteristic.Roschke.BaseData(
          label="M530-50A",
          mu_i=2120,
          B_myMax=1.25,
          c_a=12400,
          c_b=1.6,
          n=13.5);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Sample: sheet strip<br>
Measurement: Epstein frame
</p>
</html>"));
      end M530_50A;

      record M700_100A "M700-100A (1.0826) @ 50Hz"
        extends ShowCharacteristic.Roschke.BaseData(
          label="M700-100A",
          mu_i=1120,
          B_myMax=1.2,
          c_a=20750,
          c_b=3.55,
          n=13.15);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Sample: sheet strip<br>
Measurement: Epstein frame
</p>
</html>"));
      end M700_100A;

      record M940_100A "M940-100A @ 50Hz"
        extends ShowCharacteristic.Roschke.BaseData(
          label="M940-100A",
          mu_i=680,
          B_myMax=1.26,
          c_a=17760,
          c_b=3.13,
          n=13.9);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Sample: sheet strip<br>
Measurement: Epstein frame
</p>
</html>"));
      end M940_100A;
      annotation (Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
    end ElectricSheet;

    package PureIron "Pure iron"
      extends Modelica.Icons.MaterialPropertiesPackage;
      record RFe80 "Hyperm 0 (RFe80)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="RFe80",
          mu_i=123,
          B_myMax=1.27,
          c_a=44410,
          c_b=6.4,
          n=10);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Source of B(H) characteristics: Product catalogue <em>Magnequench</em>, 2000
</p>
</html>"));
      end RFe80;

      record VacoferS2 "VACOFER S2 (99.95% Fe)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="VACOFER S2",
          mu_i=2666,
          B_myMax=1.15,
          c_a=187000,
          c_b=4.24,
          n=19);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<dl>
<dt>Source of B(H) characteristics:</dt>
    <dd><p><em>Boll, R.</em>: Weichmagnetische Werkstoffe: Einf&uuml;hrung in den Magnetismus, VAC-Werkstoffe und ihre Anwendungen. 4th ed. Berlin, M&uuml;nchen: Siemens Aktiengesellschaft 1990</p>
    </dd>
</dl>
</html>"));
      end VacoferS2;
    end PureIron;

    package CobaltIron "Cobalt iron"
      extends Modelica.Icons.MaterialPropertiesPackage;

      record Vacoflux50 "VACOFLUX 50 (50% CoFe)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="VACOFLUX 50",
          mu_i=3850,
          B_myMax=1.75,
          c_a=11790,
          c_b=2.63,
          n=15.02);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Source of B(H) characteristics: VACUUMSCHMELZE GmbH &amp; Co. KG, Germany
</p>
</html>"));
      end Vacoflux50;
    end CobaltIron;

    package NickelIron "Nickel iron"
      extends Modelica.Icons.MaterialPropertiesPackage;
      record MuMetall "Mu-metal (77% NiFe)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="Mu-metal",
          mu_i=27300,
          B_myMax=0.46,
          c_a=1037500,
          c_b=3.67,
          n=10);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Source of B(H) characteristics:
</p>
<ul>
<li><em>Boll, R.</em>: Weichmagnetische Werkstoffe: Einf&uuml;hrung in den Magnetismus, VAC-Werkstoffe und ihre Anwendungen. 4th ed. Berlin, M&uuml;nchen: Siemens Aktiengesellschaft 1990</li>
</ul>
</html>"));
      end MuMetall;

      record Permenorm3601K3 "PERMENORM 3601 K3 (36% NiFe)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="PERMENORM 3601 K3",
          mu_i=3000,
          B_myMax=0.67,
          c_a=50000,
          c_b=2.39,
          n=9.3);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
<p>
Source of B(H) characteristics:
</p>
<ul>
<li><em>Boll, R.</em>: Weichmagnetische Werkstoffe: Einf&uuml;hrung in den Magnetismus, VAC-Werkstoffe und ihre Anwendungen. 4th ed. Berlin, M&uuml;nchen: Siemens Aktiengesellschaft 1990</li>
</ul>
</html>"));
      end Permenorm3601K3;
    end NickelIron;

    package Steel "Various ferromagnetic steels"
      extends Modelica.Icons.MaterialPropertiesPackage;

      record AISI_1008 "AISI 1008 (1.0204)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="AISI 1008",
          mu_i=200,
          B_myMax=1.17,
          c_a=8100,
          c_b=2.59,
          n=10);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end AISI_1008;

      record AISI_12L14 "AISI 12L14 (1.0718)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="AISI 12L14",
          mu_i=10,
          B_myMax=0.94,
          c_a=5900,
          c_b=4.19,
          n=6.4);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end AISI_12L14;

      record DC01 "DC01 (1.0330, previously St2)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="DC01",
          mu_i=5,
          B_myMax=1.1,
          c_a=6450,
          c_b=3.65,
          n=7.7);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end DC01;

      record DC03 "DC03 (1.0347, previously St3)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="DC03",
          mu_i=0,
          B_myMax=1.05,
          c_a=27790,
          c_b=16,
          n=10.4);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end DC03;

      record Steel_9SMn28K "9SMn28K (1.0715)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="9SMn28K",
          mu_i=500,
          B_myMax=1.036,
          c_a=43414,
          c_b=35.8,
          n=14);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end Steel_9SMn28K;

      record Steel_9SMnPb28 "9SMnPb28 (1.0718)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="9SMnPb28",
          mu_i=400,
          B_myMax=1.488,
          c_a=1200,
          c_b=3,
          n=12.5);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end Steel_9SMnPb28;

      record X6Cr17 "X6Cr17 (1.4016)"
        extends ShowCharacteristic.Roschke.BaseData(
          label="X6Cr17",
          mu_i=274,
          B_myMax=1.1,
          c_a=970,
          c_b=1.2,
          n=8.3);
        annotation (defaultComponentPrefixes="parameter",
          Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
      end X6Cr17;
      annotation (Documentation(info="<html>
<p>
Please refer to the description of  the enclosing package <a href=\"modelica://Modelica.Magnetic.FluxTubes.Material.SoftMagnetic\">SoftMagnetic</a> for a description of all soft magnetic material characteristics of this package.
</p>
</html>"));
    end Steel;
  end Roschke;

  package SSEE "Smoothing Splines with Exponential Extrapolation"
    extends Modelica.Icons.MaterialPropertiesPackage;

    package Functions
      extends Modelica.Icons.FunctionsPackage;

      function app_J "Approximation J(H)"
        extends Modelica.Icons.Function;
        input SI.MagneticFieldStrength H "Magnetic field strength";
        input BaseData material "Material data";
        output SI.MagneticPolarization J=
          if abs(H) < material.hH1 then Internal.app_J_SS(H, material)
          elseif abs(H) > material.hH2 then Internal.app_J_EE(H, material)
          else (1 - h)*Internal.app_J_SS(H, material) + h*Internal.app_J_EE(H, material)
          "Magnetic polarization";
      protected
        Real h=if abs(H)<material.hH1 then 0 elseif abs(H)>material.hH2 then 1
          else (abs(H) - material.hH1)/(material.hH2 - material.hH1)
          "Helper function";
        annotation (derivative(noDerivative=material)=der_J,
          Documentation(info="<html>
<p>
Returns magnetic polarization <code>J</code> calculated from smoothing splines and exponential extrapolation for magnetic field strength <code>H</code>.
</p>
</html>"));
      end app_J;

      function der_J "Derivative of J(H)"
        extends Modelica.Icons.Function;
        input SI.MagneticFieldStrength H "Magnetic field strength";
        input BaseData material "Material data";
        input ShowCharacteristic.Types.MagneticFieldStrengthSlope derH
          "Derivative of magnetic field strength";
        output ShowCharacteristic.Types.MagneticFluxDensitySlope derJ=mu_0*(
            app_mu_rd(H, material) - 1)*derH "Slope of magnetic polarization";
        annotation (Documentation(info="<html>
<p>
Returns slope of magnetic polarization <code>J</code> calculated from susceptibility.
</p>
</html>"));
      end der_J;

      function app_mu_r "Approximation mu_r(H)"
        extends Modelica.Icons.Function;
        input SI.MagneticFieldStrength H "Magnetic field strength";
        input BaseData material "Material data";
        output SI.RelativePermeability mu_r=if abs(H)<Heps then material.mu_ri
          else 1 + app_J(H, material)/(mu_0*H) "Relative permeability";
      protected
        SI.MagneticFieldStrength Heps=1e-6 "Below Heps mu_ri is returned";
        annotation (derivative(noDerivative=material)=der_mu_r,
          Documentation(info="<html>
<p>
Returns relative permeability <code>mu_r = J(H)/(mu_0*H)</code>; for <code>H</code> near 0, initial relative permeability <code>mu_ri</code> is used.
</p>
</html>"));
      end app_mu_r;

      function der_mu_r "Approximation der_mu_r(H)"
        extends Modelica.Icons.Function;
        input SI.MagneticFieldStrength H "Magnetic field strength";
        input BaseData material "Material data";
        input ShowCharacteristic.Types.MagneticFieldStrengthSlope derH
          "Derivative of magnetic field strength";
        output Real dermu_r=if abs(H)<Heps then 0
          else (app_mu_rd(H, material) - app_mu_r(H, material))/H*derH
          "Slope of relative permeability";
      protected
        SI.MagneticFieldStrength Heps=1e-6 "Below Heps dermu_r=0 is returned";
        annotation (Documentation(info="<html>
<p>
Returns slope of relative permeability <code>mu_r = J(H)/(mu_0*H)</code>.
</p>
</html>"));
      end der_mu_r;

      function app_mu_rd "Approximation mu_rd(H)"
        extends Modelica.Icons.Function;
        input SI.MagneticFieldStrength H "Magnetic field strength";
        input BaseData material "Material data";
        output SI.RelativePermeability mu_rd=
          if abs(H) < material.hH1 then 1 + Internal.app_chi_d_SS(H, material)
          elseif abs(H) > material.hH2 then 1 + Internal.app_chi_d_EE(H, material)
          else 1 + (1 - h)*Internal.app_chi_d_SS(H, material) + h*Internal.app_chi_d_EE(H, material)
          "Differential relative permeability";
      protected
        Real h=if abs(H)<material.hH1 then 0 elseif abs(H)>material.hH2 then 1
          else (abs(H) - material.hH1)/(material.hH2 - material.hH1)
          "Helper function";
        annotation (Documentation(info="<html>
<p>
Returns differential relative permeability <code>mu_rd</code> calculated from smoothing splines and exponential extrapolation for magnetic field strength <code>H</code>.
</p>
</html>"));
      end app_mu_rd;

      function makeTable "Make a table from raw data"
        extends Modelica.Icons.Function;
        import Modelica.Math.Vectors.reverse;
        input BaseData material "Material data";
        output Real table[2*(material.N - 1) + 3, 2]=[
          cat(1, -{material.Hsat}, -reverse(material.HD[2:material.N]), {0}, material.HD[2:material.N], {material.Hsat}),
          cat(1, -{material.Jsat}, -reverse(material.JD[2:material.N]), {0}, material.JD[2:material.N], {material.Jsat})]
          "Table for usage in table interpolation";
        annotation (Documentation(info="<html>
<p>
Takes arrays <code>HD</code> and <code>JD</code> from raw data in the material parameter record and returns a table that can be used as parameter 
of <a href=\"modelica://Modelica.Blocks.Tables.CombiTable1Ds\">CombiTable1Ds</a>. 
The given characteristic is amended by the last node <code>(Hsat, Jsat)</code> and mirrored at the origin. 
If <code>extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint</code> is used, the behaviour is as expected: 
an asymptote at saturation polarization <code>Jsat</code>.
</p>
</html>"));
      end makeTable;

      package Internal "Internal used functions"
        extends Modelica.Icons.InternalPackage;

        function app_J_SS "Approximation J(H) Smoothing Splines"
          extends Modelica.Icons.Function;
          import ShowCharacteristic.SSEE.Functions.Internal.findInterval;
          input SI.MagneticFieldStrength H "Magnetic field strength";
          input BaseData material "Material data";
          output SI.MagneticPolarization J "Magnetic polarization";
        protected
          SI.MagneticFieldStrength HD[:]=material.HD;
          Integer N=size(HD, 1);
          Real c0[:]=material.c0; // <> JD (smoothing splines)
          Real c1[:]=material.c1;
          Real c2[:]=material.c2;
          Real c3[:]=material.c3;
          Integer k=findInterval(abs(H), HD);
          SI.MagneticFieldStrength dH;
        algorithm
          if k<=0 then
            J:=sign(H)*(c0[1] + c1[1]*(abs(H) - HD[1]));
          elseif k>=N then
            dH:=HD[N] - HD[N - 1];
            J:=sign(H)*(((3*c3[N - 1]*dH + 2*c2[N - 1])*dH + c1[N - 1])*(abs(H) - HD[N]) + c0[N - 1]);
          else
            J:=sign(H)*(((c3[k]*(abs(H) - HD[k]) + c2[k])*(abs(H) - HD[k]) + c1[k])*(abs(H) - HD[k]) + c0[k]);
          end if;
          annotation (Documentation(info="<html>
<p>
Returns magnetic polarization <code>J</code> calculated from smoothing splines for magnetic field strength <code>H</code>.
</p>
</html>"));
        end app_J_SS;

        function app_J_EE "Approximation J(H) Exponential Extrapolation"
          extends Modelica.Icons.Function;
          input SI.MagneticFieldStrength H "Magnetic field strength";
          input BaseData material "Material data";
          output SI.MagneticPolarization J "Magnetic polarization";
        protected
          SI.MagneticFieldStrength HD[:]=material.HD;
          SI.MagneticPolarization  JD[:]=material.JD;
          Integer k0=material.k0;
          SI.MagneticFieldStrength Hpar=material.Hpar;
          SI.MagneticPolarization  Jsat=material.Jsat;
        algorithm
          J:=sign(H)*(JD[k0] + (Jsat - JD[k0])*(1 - exp(-(abs(H) - HD[k0])/Hpar)));
          annotation (Documentation(info="<html>
<p>
Returns magnetic polarization <code>J</code> calculated from exponential extrapolation for magnetic field strength <code>H</code>.
</p>
</html>"));
        end app_J_EE;

        function app_chi_d_SS "Approximation chi_d(H) Smoothing Splines"
          extends Modelica.Icons.Function;
          import ShowCharacteristic.SSEE.Functions.Internal.findInterval;
          input SI.MagneticFieldStrength H "Magnetic field strength";
          input BaseData material "Material data";
          output SI.MagneticSusceptibility chi_d "Differential susceptibility";
        protected
          SI.MagneticFieldStrength HD[:]=material.HD;
          Integer N=size(HD, 1);
          Real c1[:]=material.c1;
          Real c2[:]=material.c2;
          Real c3[:]=material.c3;
          Integer k=findInterval(abs(H), HD);
          SI.MagneticFieldStrength dH;
        algorithm
          if k<=0 then
            chi_d:=c1[1]/mu_0;
          elseif k>=N then
            dH:=HD[N] - HD[N - 1];
            chi_d:=(((3*c3[N - 1]*dH + 2*c2[N - 1]))*dH + c1[N - 1])/mu_0;
          else
            chi_d:=((3*c3[k]*(abs(H) - HD[k]) + 2*c2[k])*(abs(H) - HD[k]) + c1[k])/mu_0;
          end if;
          annotation (Documentation(info="<html>
<p>
Returns differential susceptibility <code>chi_d</code> calculated from smoothing splines for magnetic field strength <code>H</code>.
</p>
</html>"));
        end app_chi_d_SS;

        function app_chi_d_EE
          "Approximation chi_d(H) Exponential Extrapolation"
          extends Modelica.Icons.Function;
          input SI.MagneticFieldStrength H "Magnetic field strength";
          input BaseData material "Material data";
          output SI.MagneticSusceptibility chi_d "Differential susceptibility";
        protected
          SI.MagneticFieldStrength HD[:]=material.HD;
          SI.MagneticPolarization  JD[:]=material.JD;
          Integer k0=material.k0;
          SI.MagneticFieldStrength Hpar=material.Hpar;
          SI.MagneticPolarization  Jsat=material.Jsat;
        algorithm
          chi_d:=(Jsat - JD[k0])/(mu_0*Hpar)*exp(-(abs(H) - HD[k0])/Hpar);
          annotation (Documentation(info="<html>
<p>
Returns differential susceptibility <code>chi_d</code> calculated from exponential extrapolation for magnetic field strength <code>H</code>.
</p>
</html>"));
        end app_chi_d_EE;

        function findInterval "Find interval for interpolation"
          extends Modelica.Icons.Function;
          input Real x "Scalar";
          input Real xD[:] "Array";
          output Integer k "Index";
        protected
          Integer N=size(xD,1);
        algorithm
          if x<xD[1] then
            k:=0;
          else
            k:=1;
            while k<=N-1 loop
              if x>=xD[k] and x<xD[k + 1] then
                break;
              end if;
              k:=k+1;
            end while;
          end if;
          annotation (Documentation(info="<html>
<p>
Determines the interval <code>k</code> that includes the value <code>x</code>: <code>xD[k]&le;x&lt;xD[k+1]</code>.
<code>x&lt;xD[1]</code> returns <code>k=0</code>.
<code>x&gt;xD[N]</code> returns <code>k=N</code> where <code>N=size(xD, 1)</code>.
</p>
</html>"));
        end findInterval;
      end Internal;
    end Functions;

    record BaseData "CastIron"
      extends Modelica.Icons.Record;
      parameter String Type="CastIron";
      parameter ShowCharacteristic.Types.SpecificPower vRef=25.
        "Specific losses at BRef and fRef";
      parameter SI.MagneticFluxDensity BRef=1.5 "Ref. flux density for spec. losses";
      parameter SI.Frequency fRef=50 "Ref. frequency for spec. losses";
      parameter SI.Density dens = 7500 "Density of material";
      parameter SI.RelativePermeability mu_ri= 155.80 "Initial relative permeability";
      // Exponential Extrapolation
      parameter Integer k0                    =     12    "Start of EE"
        annotation(Dialog(group="Exponential Extrapolation"));
      parameter SI.MagneticFieldStrength Hpar =  9901.06 "Parameter of EE"
        annotation(Dialog(group="Exponential Extrapolation"));
      parameter SI.MagneticFieldStrength Hsat = 132113.5 "Saturation field strength"
        annotation(Dialog(group="Exponential Extrapolation"));
      parameter SI.MagneticPolarization  Jsat =  1.27765 "Saturation polarization"
        annotation(Dialog(group="Exponential Extrapolation"));
      // Homotopy
      parameter SI.MagneticFieldStrength hH1  =   5000.00 "Start of homotopy"
        annotation(Dialog(group="Homotopy"));
      parameter SI.MagneticFieldStrength hH2  =  15000.00 "End   of homotopy"
        annotation(Dialog(group="Homotopy"));
      // Length of Raw Data
      parameter Integer N    = 22 "Count of nodes"
        annotation(Dialog(tab="Smoothing Splines"));
      // Smoothing Spline coefficients
      parameter Real c3[:](each unit="V.s.m/A2")={
         1.05287e-10, 3.46651e-10,-1.34759e-10,-4.61913e-10,-1.76527e-10,
        -6.93774e-11, 7.12008e-12, 2.24874e-11, 3.31106e-11, 5.09619e-11,
         2.08923e-11, 2.78107e-12, 6.36022e-13, 8.74410e-14, 7.61594e-14,
         5.22203e-14, 4.77447e-14, 3.63249e-14, 4.27105e-14,-1.86138e-15,
         8.60434e-14}
        annotation(Dialog(tab="Smoothing Splines"));
      parameter Real c2[:](each unit="V.s/A2")={
         0.00000e+00, 6.31721e-08, 2.71163e-07, 1.49880e-07, 1.13056e-08,
        -9.46106e-08,-1.46644e-07,-1.43440e-07,-1.33320e-07,-1.13454e-07,
        -7.52325e-08,-1.25556e-08,-4.21242e-09,-2.30435e-09,-2.04203e-09,
        -1.81355e-09,-1.57856e-09,-1.36371e-09,-1.14576e-09,-8.89495e-10,
        -9.03455e-10}
        annotation(Dialog(tab="Smoothing Splines"));
      parameter Real c1[:](each unit="V.s/(m.A)")={
         1.94531e-04, 2.07166e-04, 2.74033e-04, 4.00345e-04, 4.16464e-04,
         3.99803e-04, 3.39489e-04, 2.95977e-04, 2.54463e-04, 2.05108e-04,
         1.57936e-04, 7.01484e-05, 5.33803e-05, 4.68636e-05, 4.25172e-05,
         3.86616e-05, 3.35735e-05, 2.91601e-05, 2.41411e-05, 2.00706e-05,
         1.55882e-05}
        annotation(Dialog(tab="Smoothing Splines"));
      parameter Real c0[:](each unit="V.s/m2")={
         0.00000e+00, 3.97486e-02, 8.64819e-02, 1.89458e-01, 2.30529e-01,
         3.12862e-01, 4.05816e-01, 4.53464e-01, 4.94709e-01, 5.40533e-01,
         5.85516e-01, 6.89112e-01, 7.49486e-01, 7.99290e-01, 8.43936e-01,
         8.84488e-01, 9.38576e-01, 9.85545e-01, 1.03870e+00, 1.08274e+00,
         1.12733e+00}
        annotation(Dialog(tab="Smoothing Splines"));
      // Raw Data: Magnetic field strength H and Magnetic polarization J
      parameter SI.MagneticFieldStrength HD[:]={
             0.00,   200.00,   400.00,   700.00,   800.00,  1000.00,  1250.00,
          1400.00,  1550.00,  1750.00,  2000.00,  3000.00,  4000.00,  5000.00,
          6000.00,  7000.00,  8500.00, 10000.00, 12000.00, 14000.00, 16500.00,
         20000.00}
        annotation(Dialog(tab="Raw Data"));
      parameter SI.MagneticPolarization  JD[:]={
          0.00000,  0.03975,  0.08648,  0.18946,  0.23053,  0.31286,  0.40582,
          0.45346,  0.49471,  0.54053,  0.58552,  0.68911,  0.74949,  0.79929,
          0.84394,  0.88449,  0.93858,  0.98555,  1.03870,  1.08274,  1.12733,
          1.17451}
        annotation(Dialog(tab="Raw Data"));
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false),
          graphics={Text(extent={{-100,-10},{100,-40}},
            textColor={0,0,255}, textString="%Type"), Text(
              extent={{-100,10},{100,40}},
              textColor={0,0,255},
              textString="SS + EE")}),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end BaseData;

    record CastIron "CastIron (artificial)"
      extends BaseData(
        Type="CastIron",
        vRef =     25.00,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7500.00,
        mu_ri=    155.80,
        k0   = 12,
        Hpar =   9901.06,
        Hsat =  132113.5,
        Jsat =   1.27765,
        hH1  =   5000.00,
        hH2  =  15000.00,
        N    = 22,
        c3={
         1.05287e-10, 3.46651e-10,-1.34759e-10,-4.61913e-10,-1.76527e-10,
        -6.93774e-11, 7.12008e-12, 2.24874e-11, 3.31106e-11, 5.09619e-11,
         2.08923e-11, 2.78107e-12, 6.36022e-13, 8.74410e-14, 7.61594e-14,
         5.22203e-14, 4.77447e-14, 3.63249e-14, 4.27105e-14,-1.86138e-15,
         8.60434e-14},
        c2={
         0.00000e+00, 6.31721e-08, 2.71163e-07, 1.49880e-07, 1.13056e-08,
        -9.46106e-08,-1.46644e-07,-1.43440e-07,-1.33320e-07,-1.13454e-07,
        -7.52325e-08,-1.25556e-08,-4.21242e-09,-2.30435e-09,-2.04203e-09,
        -1.81355e-09,-1.57856e-09,-1.36371e-09,-1.14576e-09,-8.89495e-10,
        -9.03455e-10},
        c1={
         1.94531e-04, 2.07166e-04, 2.74033e-04, 4.00345e-04, 4.16464e-04,
         3.99803e-04, 3.39489e-04, 2.95977e-04, 2.54463e-04, 2.05108e-04,
         1.57936e-04, 7.01484e-05, 5.33803e-05, 4.68636e-05, 4.25172e-05,
         3.86616e-05, 3.35735e-05, 2.91601e-05, 2.41411e-05, 2.00706e-05,
         1.55882e-05},
        c0={
         0.00000e+00, 3.97486e-02, 8.64819e-02, 1.89458e-01, 2.30529e-01,
         3.12862e-01, 4.05816e-01, 4.53464e-01, 4.94709e-01, 5.40533e-01,
         5.85516e-01, 6.89112e-01, 7.49486e-01, 7.99290e-01, 8.43936e-01,
         8.84488e-01, 9.38576e-01, 9.85545e-01, 1.03870e+00, 1.08274e+00,
         1.12733e+00},
        HD={ 0.00,   200.00,   400.00,   700.00,   800.00,  1000.00,  1250.00,
          1400.00,  1550.00,  1750.00,  2000.00,  3000.00,  4000.00,  5000.00,
          6000.00,  7000.00,  8500.00, 10000.00, 12000.00, 14000.00, 16500.00,
         20000.00},
        JD={
          0.00000,  0.03975,  0.08648,  0.18946,  0.23053,  0.31286,  0.40582,
          0.45346,  0.49471,  0.54053,  0.58552,  0.68911,  0.74949,  0.79929,
          0.84394,  0.88449,  0.93858,  0.98555,  1.03870,  1.08274,  1.12733,
          1.17451});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)),
        Documentation(info="<html>
<p>
This is an artificially created but nevertheless realistic characteristic of cast iron for teaching purposes.
</p>
</html>"));
    end CastIron;

    record HP210_35A "HP210-35A @ 50Hz"
      extends BaseData(
        Type="HP210-35A",
        vRef=2.10,
        BRef=1.50000,
        fRef=50.00,
        dens=7600.00,
        mu_ri=1963.43,
        k0=23,
        Hpar=8789.76,
        Hsat=109609.0,
        Jsat=1.92077,
        hH1=5000.00,
        hH2=20000.00,
        N=33,
        c3={3.17716e-06,4.78835e-06,2.22395e-06,-4.72852e-06,-7.62674e-06,-3.89339e-06,
            9.28841e-07,1.15464e-06,7.99849e-07,8.54364e-07,4.96313e-07,2.05030e-07,
            8.58676e-08,5.24916e-08,1.86816e-08,5.01632e-09,9.57227e-10,1.78691e-10,
            4.98256e-11,1.81759e-11,7.68136e-12,4.80361e-12,2.17701e-12,4.52619e-13,
            5.52355e-14,5.44633e-14,1.91615e-14,9.10655e-15,1.68918e-14,2.72506e-15,
            1.26456e-14,1.29232e-14},
        c2={0.00000e+00,9.51788e-05,2.39082e-04,3.05720e-04,1.63841e-04,-6.39068e-05,
            -1.82028e-04,-1.54216e-04,-1.19952e-04,-9.56450e-05,-6.48606e-05,-3.06002e-05,
            -1.52799e-05,-8.92801e-06,-4.94486e-06,-2.14280e-06,-6.35941e-07,-2.05868e-07,
            -7.19679e-08,-3.49917e-08,-2.12863e-08,-1.54602e-08,-8.30923e-09,-5.03797e-09,
            -1.66175e-09,-1.25020e-09,-8.46485e-10,-5.53463e-10,-4.40746e-10,-2.38517e-10,
            -2.12284e-10,-7.33053e-11},
        c1={2.46607e-03,3.41650e-03,6.76497e-03,1.22065e-02,1.69028e-02,1.78976e-02,
            1.54104e-02,1.20543e-02,9.34241e-03,7.15839e-03,5.23062e-03,3.03408e-03,
            1.89131e-03,1.29441e-03,9.43509e-04,5.89148e-04,3.10913e-04,1.84841e-04,
            1.15443e-04,8.89842e-05,7.48389e-05,6.55484e-05,5.37536e-05,4.70683e-05,
            3.04099e-05,2.31778e-05,1.79971e-05,1.08610e-05,6.75904e-06,4.04833e-06,
            2.60176e-06,1.55553e-06},
        c0={0.00000e+00,2.77891e-02,7.63790e-02,1.70014e-01,3.17950e-01,4.94912e-01,
            6.65347e-01,8.01951e-01,9.07214e-01,9.90376e-01,1.06404e+00,1.15610e+00,
            1.21585e+00,1.25449e+00,1.28236e+00,1.31951e+00,1.36205e+00,1.39757e+00,
            1.43368e+00,1.45859e+00,1.47903e+00,1.49671e+00,1.52602e+00,1.55113e+00,
            1.64398e+00,1.71010e+00,1.76056e+00,1.83284e+00,1.86887e+00,1.88990e+00,
            1.90052e+00,1.90783e+00},
        HD={0.00,9.99,20.00,29.99,39.99,49.95,60.06,70.04,79.93,90.06,102.07,125.08,
            149.99,174.65,199.94,249.94,350.07,499.83,749.61,996.98,1248.33,1501.16,
            1997.38,2498.25,4984.69,7468.28,9939.15,15036.56,19162.44,23153.10,26361.99,
            30025.40,31916.19},
        JD={0.00000,0.02592,0.06952,0.15792,0.31070,0.49558,0.66731,0.79843,0.90300,
            0.98665,1.05981,1.15196,1.21192,1.25065,1.27853,1.31570,1.35826,1.39377,
            1.42989,1.45479,1.47524,1.49292,1.52223,1.54734,1.64018,1.70631,1.75676,
            1.82905,1.86508,1.88610,1.89673,1.90403,1.90680});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end HP210_35A;

    record HP235_35A "HP235-35A @ 50Hz"
      extends BaseData(
        Type="HP235-35A",
        vRef=2.35,
        BRef=1.50000,
        fRef=50.00,
        dens=7600.00,
        mu_ri=1912.63,
        k0=23,
        Hpar=9188.67,
        Hsat=114657.6,
        Jsat=1.94700,
        hH1=5000.00,
        hH2=20000.00,
        N=33,
        c3={2.08550e-06,3.30432e-06,3.27691e-06,3.04227e-07,-6.25804e-06,-7.62492e-06,
            -2.08555e-06,1.30794e-06,2.07358e-06,1.13906e-06,4.78423e-07,2.38029e-07,
            7.80164e-08,5.06005e-08,2.04353e-08,5.43196e-09,1.08269e-09,1.93647e-10,
            5.20938e-11,1.47175e-11,1.06675e-11,4.42248e-12,2.30494e-12,4.42892e-13,
            4.48039e-14,6.03047e-14,1.67131e-14,1.00106e-14,1.12512e-14,1.27016e-14,
            1.80143e-15,2.88347e-14},
        c2={0.00000e+00,6.25469e-05,1.61648e-04,2.60172e-04,2.69294e-04,8.20771e-05,
            -1.46188e-04,-2.08964e-04,-1.69751e-04,-1.05957e-04,-6.58849e-05,-3.29410e-05,
            -1.50574e-05,-9.32891e-06,-5.36852e-06,-2.32709e-06,-7.06864e-07,-2.18208e-07,
            -7.34371e-08,-3.39163e-08,-2.29641e-08,-1.49749e-08,-8.34307e-09,-4.91415e-09,
            -1.59116e-09,-1.25602e-09,-8.01605e-10,-5.64597e-10,-4.16767e-10,-2.70639e-10,
            -1.59450e-10,-1.40560e-10},
        c1={2.40223e-03,3.02752e-03,5.26882e-03,9.49634e-03,1.47883e-02,1.82922e-02,
            1.76524e-02,1.40890e-02,1.03043e-02,7.47686e-03,5.46176e-03,3.19340e-03,
            1.99133e-03,1.39445e-03,1.01101e-03,6.29226e-04,3.27573e-04,1.88400e-04,
            1.15722e-04,8.85746e-05,7.44653e-05,6.49941e-05,5.33385e-05,4.67645e-05,
            3.04948e-05,2.33958e-05,1.82275e-05,1.17695e-05,6.93879e-06,3.96281e-06,
            2.70781e-06,1.65921e-06},
        c0={0.00000e+00,2.60990e-02,6.59180e-02,1.38258e-01,2.59466e-01,4.27510e-01,
            6.10643e-01,7.70934e-01,8.92171e-01,9.82226e-01,1.05717e+00,1.15361e+00,
            1.21666e+00,1.25753e+00,1.28845e+00,1.32789e+00,1.37279e+00,1.40976e+00,
            1.44615e+00,1.47156e+00,1.49167e+00,1.50900e+00,1.53830e+00,1.56297e+00,
            1.65612e+00,1.72296e+00,1.77476e+00,1.84477e+00,1.89022e+00,1.91336e+00,
            1.92294e+00,1.93053e+00},
        HD={0.00,10.00,19.99,30.02,40.01,49.98,59.96,70.00,79.99,90.24,101.97,124.92,
            149.97,174.44,200.53,250.14,349.57,500.01,749.21,1002.10,1250.15,1499.79,
            1999.65,2495.53,4996.51,7489.87,10001.65,14728.63,19651.05,23980.32,26898.32,
            30393.56,32018.46},
        JD={0.00000,0.02506,0.06340,0.13222,0.24914,0.42339,0.61477,0.77250,0.89060,
            0.97862,1.05389,1.15083,1.21398,1.25500,1.28593,1.32539,1.37029,1.40727,
            1.44366,1.46907,1.48918,1.50651,1.53581,1.56048,1.65363,1.72047,1.77227,
            1.84228,1.88773,1.91087,1.92045,1.92804,1.93049});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end HP235_35A;

    record HP250_35A "HP250-35A @ 50Hz"
      extends BaseData(
        Type="HP250-35A",
        vRef=2.50,
        BRef=1.50000,
        fRef=50.00,
        dens=7600.00,
        mu_ri=1679.39,
        k0=23,
        Hpar=10106.33,
        Hsat=125744.7,
        Jsat=1.97342,
        hH1=5000.00,
        hH2=20000.00,
        N=33,
        c3={1.51213e-06,2.36937e-06,2.94020e-06,1.49079e-06,-1.40036e-06,-7.84078e-06,
            -4.55521e-06,-1.41872e-06,2.01492e-06,1.70493e-06,7.70183e-07,1.93125e-07,
            1.08769e-07,5.73077e-08,2.20060e-08,6.25400e-09,1.16481e-09,2.27740e-10,
            4.41909e-11,2.90033e-11,6.76438e-12,5.66514e-12,2.01710e-12,4.75622e-13,
            3.73539e-14,5.72447e-14,1.38457e-14,1.08916e-14,-1.31308e-15,2.01916e-14,
            -1.29830e-14,3.92358e-14},
        c2={0.00000e+00,4.53973e-05,1.16643e-04,2.04523e-04,2.49305e-04,2.07354e-04,
            -2.88969e-05,-1.65933e-04,-2.08033e-04,-1.47692e-04,-8.63761e-05,-3.27905e-05,
            -1.81951e-05,-1.03123e-05,-5.93635e-06,-2.65365e-06,-7.75438e-07,-2.46702e-07,
            -7.61873e-08,-4.30462e-08,-2.16609e-08,-1.65303e-08,-7.91722e-09,-4.98941e-09,
            -1.40625e-09,-1.12862e-09,-6.95118e-10,-4.86831e-10,-3.26512e-10,-3.40451e-10,
            -1.21983e-10,-2.43425e-10},
        c1={2.10912e-03,2.56343e-03,4.18760e-03,7.38739e-03,1.19316e-02,1.64917e-02,
            1.82840e-02,1.63303e-02,1.26313e-02,9.08031e-03,6.27434e-03,3.51066e-03,
            2.22625e-03,1.53758e-03,1.12400e-03,6.96872e-04,3.53595e-04,1.98936e-04,
            1.18351e-04,8.85445e-05,7.26408e-05,6.29851e-05,5.05955e-05,4.43508e-05,
            2.82900e-05,2.20100e-05,1.74063e-05,1.14795e-05,7.48883e-06,5.12884e-06,
            3.46103e-06,2.32169e-06},
        c0={0.00000e+00,2.26222e-02,5.52628e-02,1.11470e-01,2.07442e-01,3.50053e-01,
            5.28663e-01,7.04512e-01,8.48435e-01,9.55799e-01,1.04637e+00,1.15503e+00,
            1.22574e+00,1.27044e+00,1.30384e+00,1.34776e+00,1.39720e+00,1.43698e+00,
            1.47481e+00,1.50032e+00,1.51992e+00,1.53701e+00,1.56542e+00,1.58827e+00,
            1.67571e+00,1.73774e+00,1.78703e+00,1.85858e+00,1.90447e+00,1.92682e+00,
            1.94184e+00,1.95105e+00},
        HD={0.00,10.01,20.03,29.99,40.01,49.99,60.04,70.06,79.96,89.94,101.93,125.12,
            150.31,174.47,199.92,249.64,349.75,501.06,750.64,1000.62,1246.40,1499.22,
            2006.01,2489.84,5001.05,7478.51,10002.79,15017.25,19923.76,23462.17,27068.77,
            30186.75,32254.81},
        JD={0.00000,0.02184,0.05414,0.10793,0.20218,0.34056,0.53078,0.70645,0.85073,
            0.95362,1.04344,1.15253,1.22384,1.26857,1.30199,1.34593,1.39539,1.43518,
            1.47300,1.49852,1.51811,1.53520,1.56361,1.58647,1.67391,1.73593,1.78522,
            1.85677,1.90266,1.92502,1.94003,1.94924,1.95335});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end HP250_35A;

    record HP270_35A "HP270-35A @ 50Hz"
      extends BaseData(
        Type="HP270-35A",
        vRef=2.70,
        BRef=1.50000,
        fRef=50.00,
        dens=7650.00,
        mu_ri=1236.68,
        k0=23,
        Hpar=10260.10,
        Hsat=127477.7,
        Jsat=1.98697,
        hH1=5000.00,
        hH2=20000.00,
        N=33,
        c3={4.45856e-07,5.97169e-07,2.22409e-06,3.95433e-06,3.29031e-06,-5.37869e-06,
            -6.94374e-06,-3.65298e-06,-5.14321e-07,1.84139e-06,8.98537e-07,3.91313e-07,
            1.31492e-07,8.39373e-08,3.24497e-08,7.47365e-09,1.33257e-09,2.59533e-10,
            5.82247e-11,1.94585e-11,1.51687e-11,4.27467e-12,2.80085e-12,4.49517e-13,
            4.54953e-14,4.98586e-14,1.53509e-14,9.41689e-15,4.94327e-15,8.45370e-15,
            -7.59286e-16,3.94808e-14},
        c2={0.00000e+00,1.33976e-05,3.12322e-05,9.79205e-05,2.17298e-04,3.16853e-04,
            1.56823e-04,-5.09554e-05,-1.61223e-04,-1.76590e-04,-1.21854e-04,-5.39168e-05,
            -2.39299e-05,-1.45662e-05,-8.08813e-06,-3.16125e-06,-8.70375e-07,-2.78749e-07,
            -8.56513e-08,-4.11718e-08,-2.68242e-08,-1.53502e-08,-8.97356e-09,-4.78401e-09,
            -1.41131e-09,-1.06411e-09,-6.93682e-10,-4.74788e-10,-3.46962e-10,-2.83366e-10,
            -1.89247e-10,-1.95687e-10},
        c1={1.55280e-03,1.68700e-03,2.13129e-03,3.42215e-03,6.59420e-03,1.19815e-02,
            1.66792e-02,1.77352e-02,1.56003e-02,1.22358e-02,9.27866e-03,4.84870e-03,
            2.86020e-03,1.94641e-03,1.36361e-03,7.94278e-04,3.82346e-04,2.12286e-04,
            1.21912e-04,8.96172e-05,7.29052e-05,6.22712e-05,5.01764e-05,4.33168e-05,
            2.78224e-05,2.15254e-05,1.71721e-05,1.16182e-05,7.90006e-06,5.19698e-06,
            3.44305e-06,2.35481e-06},
        c0={0.00000e+00,1.60016e-02,3.47127e-02,6.13552e-02,1.09738e-01,2.01725e-01,
            3.46470e-01,5.21547e-01,6.91116e-01,8.29988e-01,9.35680e-01,1.10651e+00,
            1.20171e+00,1.25788e+00,1.29974e+00,1.35224e+00,1.40837e+00,1.45021e+00,
            1.48967e+00,1.51612e+00,1.53595e+00,1.55287e+00,1.58056e+00,1.60370e+00,
            1.68914e+00,1.75153e+00,1.79907e+00,1.86667e+00,1.91039e+00,1.93828e+00,
            1.95410e+00,1.96230e+00},
        HD={0.00,10.02,19.97,29.97,40.03,50.12,60.03,70.01,80.07,90.03,99.94,125.14,
            150.68,174.42,200.15,250.76,352.93,500.92,748.93,1003.57,1249.35,1501.50,
            1998.74,2497.34,4998.32,7542.14,10018.69,14771.81,19296.52,23584.89,27296.03,
            30123.12,31775.29},
        JD={0.00000,0.01565,0.03612,0.06289,0.10841,0.19084,0.34407,0.52494,0.69433,
            0.83227,0.93402,1.10538,1.20087,1.25729,1.29915,1.35168,1.40783,1.44967,
            1.48914,1.51559,1.53542,1.55234,1.58003,1.60317,1.68861,1.75100,1.79854,
            1.86614,1.90986,1.93775,1.95356,1.96177,1.96530});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end HP270_35A;

    record M270_50A "M270-50A @ 50Hz"
      extends BaseData(
        Type="M270-50A",
        vRef =      2.70,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7600.00,
        mu_ri=   1902.23,
        k0   = 23,
        Hpar =  10284.44,
        Hsat =  129186.5,
        Jsat =   1.96017,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         2.27864e-06, 2.32901e-06, 1.40801e-06,-6.86202e-07,-3.20815e-06,
        -5.32239e-06,-4.53197e-07, 1.96980e-07, 9.85862e-07, 6.20767e-07,
         2.48655e-07, 1.72769e-07, 1.06935e-07, 6.59337e-08, 3.23798e-08,
         8.34756e-09, 1.51137e-09, 2.61362e-10, 5.69454e-11, 2.38477e-11,
         9.55963e-12, 5.40335e-12, 2.43257e-12, 4.58038e-13, 4.98279e-14,
         4.90381e-14, 1.11934e-14, 9.99504e-15, 4.62001e-15, 1.65527e-14,
         6.74648e-15, 2.89091e-14},
        c2={
         0.00000e+00, 6.84949e-05, 1.38361e-04, 1.80685e-04, 1.60156e-04,
         6.47927e-05,-9.58308e-05,-1.09426e-04,-1.03534e-04,-7.38923e-05,
        -5.15038e-05,-3.42036e-05,-2.12643e-05,-1.31499e-05,-8.30411e-06,
        -3.43640e-06,-9.64732e-07,-2.78886e-07,-8.49613e-08,-4.17113e-08,
        -2.38917e-08,-1.67094e-08,-8.62512e-09,-4.92342e-09,-1.49179e-09,
        -1.11839e-09,-7.50541e-10,-5.83338e-10,-4.49504e-10,-3.90539e-10,
        -1.92032e-10,-1.33433e-10},
        c1={
         2.38915e-03, 3.07546e-03, 5.14389e-03, 8.34067e-03, 1.17396e-02,
         1.39685e-02, 1.36562e-02, 1.16038e-02, 9.48040e-03, 7.70222e-03,
         6.19471e-03, 4.20700e-03, 2.82228e-03, 1.95181e-03, 1.42622e-03,
         8.37897e-04, 4.03512e-04, 2.15398e-04, 1.25410e-04, 9.33406e-05,
         7.70005e-05, 6.68324e-05, 5.41976e-05, 4.73252e-05, 3.13042e-05,
         2.47842e-05, 2.01111e-05, 1.34694e-05, 8.85949e-06, 5.28571e-06,
         2.95690e-06, 2.01459e-06},
        c0={
         0.00000e+00, 2.62311e-02, 6.61610e-02, 1.33009e-01, 2.33471e-01,
         3.62395e-01, 5.04051e-01, 6.30570e-01, 7.35587e-01, 8.21194e-01,
         9.04189e-01, 1.02325e+00, 1.10965e+00, 1.16916e+00, 1.21006e+00,
         1.26475e+00, 1.32200e+00, 1.36619e+00, 1.40636e+00, 1.43359e+00,
         1.45462e+00, 1.47255e+00, 1.50240e+00, 1.52799e+00, 1.62260e+00,
         1.69227e+00, 1.74801e+00, 1.83092e+00, 1.88031e+00, 1.91022e+00,
         1.92617e+00, 1.93328e+00},
        HD={ 0.00,    10.02,    20.02,    30.04,    40.01,    49.92,    59.98,
            69.98,    79.95,    89.97,   101.99,   125.19,   150.15,   175.44,
           199.94,   250.05,   348.75,   500.01,   747.34,  1000.51,  1249.58,
          1500.02,  1998.74,  2505.98,  5003.32,  7501.24, 10001.65, 14980.88,
         19444.24, 23698.52, 27696.00, 30591.27, 32129.82},
        JD={
          0.00000,  0.02357,  0.06234,  0.12779,  0.22774,  0.35715,  0.50714,
          0.62863,  0.73381,  0.81804,  0.90102,  1.02044,  1.10685,  1.16639,
          1.20730,  1.26200,  1.31927,  1.36347,  1.40364,  1.43087,  1.45190,
          1.46983,  1.49968,  1.52527,  1.61988,  1.68955,  1.74529,  1.82820,
          1.87759,  1.90750,  1.92345,  1.93056,  1.93345});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M270_50A;

    record M310_50A "M310-50A @ 50Hz"
      extends BaseData(
        Type="M310-50A",
        vRef =      3.10,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7650.00,
        mu_ri=   1699.69,
        k0   = 23,
        Hpar =  11518.06,
        Hsat =  144257.7,
        Jsat =   1.99336,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         1.44661e-06, 2.09739e-06, 2.29241e-06, 1.41891e-06,-9.62814e-07,
        -8.20755e-06,-2.02674e-06,-8.51108e-07, 6.73648e-07, 1.40857e-06,
         6.21560e-07, 2.05805e-07, 1.21435e-07, 6.07374e-08, 2.73919e-08,
         6.91040e-09, 1.33975e-09, 2.62388e-10, 5.30131e-11, 2.67045e-11,
         1.20841e-11, 5.22862e-12, 2.63937e-12, 4.60859e-13, 3.88419e-14,
         4.73304e-14, 1.10133e-14, 7.56026e-15, 3.22164e-15, 1.50163e-14,
        -3.48333e-14, 1.01212e-13},
        c2={
         0.00000e+00, 4.34352e-05, 1.06711e-04, 1.75119e-04, 2.17394e-04,
         1.88380e-04,-5.91743e-05,-1.19489e-04,-1.45151e-04,-1.24978e-04,
        -8.26751e-05,-3.62940e-05,-2.06983e-05,-1.16036e-05,-7.08173e-06,
        -2.95826e-06,-8.84796e-07,-2.81945e-07,-8.54518e-08,-4.57306e-08,
        -2.55669e-08,-1.65703e-08,-8.73324e-09,-4.75105e-09,-1.29576e-09,
        -1.00442e-09,-6.51162e-10,-4.86949e-10,-3.79814e-10,-3.31317e-10,
        -1.31578e-10,-3.50539e-10},
        c1={
         2.13464e-03, 2.56936e-03, 4.07925e-03, 6.88264e-03, 1.07808e-02,
         1.48567e-02, 1.61557e-02, 1.43834e-02, 1.17236e-02, 9.02711e-03,
         6.94835e-03, 3.98918e-03, 2.54956e-03, 1.74317e-03, 1.27946e-03,
         7.75667e-04, 3.91298e-04, 2.16298e-04, 1.24588e-04, 9.18242e-05,
         7.38794e-05, 6.34223e-05, 5.07800e-05, 4.39984e-05, 2.88864e-05,
         2.31356e-05, 1.90166e-05, 1.33600e-05, 9.26583e-06, 5.69746e-06,
         3.64507e-06, 2.63488e-06},
        c0={
         0.00000e+00, 2.28147e-02, 5.51781e-02, 1.08570e-01, 1.95584e-01,
         3.24834e-01, 4.84902e-01, 6.37363e-01, 7.68989e-01, 8.72225e-01,
         9.51481e-01, 1.08273e+00, 1.16365e+00, 1.21629e+00, 1.25333e+00,
         1.30316e+00, 1.35806e+00, 1.40137e+00, 1.44187e+00, 1.46849e+00,
         1.48913e+00, 1.50607e+00, 1.53427e+00, 1.55794e+00, 1.64542e+00,
         1.71015e+00, 1.76222e+00, 1.84200e+00, 1.89504e+00, 1.93238e+00,
         1.95244e+00, 1.95917e+00},
        HD={ 0.00,    10.01,    20.06,    30.01,    39.94,    49.99,    60.04,
            69.96,    80.01,    89.99,   100.01,   124.88,   150.14,   175.10,
           199.92,   250.10,   350.11,   500.11,   749.73,   999.48,  1251.17,
          1499.34,  1998.97,  2501.89,  5001.05,  7501.24,  9989.15, 14959.29,
         19682.86, 24700.73, 29134.55, 31229.87, 32384.34},
        JD={
          0.00000,  0.02186,  0.05368,  0.10580,  0.19101,  0.31446,  0.49055,
          0.63704,  0.76908,  0.87138,  0.94881,  1.08050,  1.16182,  1.21449,
          1.25156,  1.30141,  1.35633,  1.39964,  1.44015,  1.46676,  1.48740,
          1.50434,  1.53255,  1.55621,  1.64369,  1.70842,  1.76049,  1.84027,
          1.89331,  1.93065,  1.95071,  1.95745,  1.96018});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M310_50A;

    record M330_50A "M330-50A @ 50Hz"
      extends BaseData(
        Type="M330-50A",
        vRef =      3.30,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7650.00,
        mu_ri=   1462.80,
        k0   = 23,
        Hpar =  11652.25,
        Hsat =  145834.7,
        Jsat =   1.99525,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         8.25303e-07, 1.04832e-06, 2.39026e-06, 2.82476e-06,-2.43534e-07,
        -4.05353e-06,-4.25414e-06,-3.17212e-06,-1.28737e-07, 1.10264e-06,
         8.25003e-07, 3.07108e-07, 1.27944e-07, 7.93928e-08, 3.05904e-08,
         7.37865e-09, 1.39556e-09, 2.64253e-10, 4.86781e-11, 3.55725e-11,
         5.63774e-12, 6.80921e-12, 2.01021e-12, 4.99912e-13, 3.66876e-14,
         4.33535e-14, 1.16344e-14, 7.61233e-15, 3.00991e-15, 1.26397e-14,
        -4.21798e-16, 1.27806e-13},
        c2={
         0.00000e+00, 2.48138e-05, 5.61757e-05, 1.27863e-04, 2.12773e-04,
         2.05481e-04, 8.32747e-05,-4.51393e-05,-1.38837e-04,-1.42774e-04,
        -1.03419e-04,-4.63850e-05,-2.31544e-05,-1.37032e-05,-7.74366e-06,
        -3.11367e-06,-9.15301e-07,-2.83150e-07,-8.56847e-08,-4.91369e-08,
        -2.24834e-08,-1.83264e-08,-8.00183e-09,-4.99220e-09,-1.24343e-09,
        -9.65164e-10,-6.43580e-10,-4.69115e-10,-3.61373e-10,-3.13128e-10,
        -2.04549e-10,-2.10867e-10},
        c1={
         1.83695e-03, 2.08563e-03, 2.89327e-03, 4.73312e-03, 8.14623e-03,
         1.23209e-02, 1.52227e-02, 1.56064e-02, 1.37950e-02, 1.09247e-02,
         7.99573e-03, 4.54364e-03, 2.79025e-03, 1.88269e-03, 1.34607e-03,
         7.98301e-04, 3.98176e-04, 2.17221e-04, 1.25349e-04, 9.16075e-05,
         7.37198e-05, 6.36896e-05, 5.03827e-05, 4.38979e-05, 2.83112e-05,
         2.27273e-05, 1.87496e-05, 1.31877e-05, 9.26956e-06, 5.66580e-06,
         4.18346e-06, 2.10934e-06},
        c0={
         0.00000e+00, 1.92409e-02, 4.35461e-02, 8.04729e-02, 1.43577e-01,
         2.45841e-01, 3.86296e-01, 5.43562e-01, 6.89819e-01, 8.15866e-01,
         9.27485e-01, 1.06692e+00, 1.15691e+00, 1.21349e+00, 1.25326e+00,
         1.30539e+00, 1.36119e+00, 1.40525e+00, 1.44587e+00, 1.47264e+00,
         1.49301e+00, 1.50985e+00, 1.53824e+00, 1.56164e+00, 1.64798e+00,
         1.71221e+00, 1.76316e+00, 1.84225e+00, 1.89483e+00, 1.93449e+00,
         1.94845e+00, 1.96418e+00},
        HD={ 0.00,    10.02,    19.99,    29.99,    40.01,    49.99,    60.04,
            70.10,    79.95,    90.14,   102.04,   125.08,   150.30,   174.92,
           199.94,   250.39,   349.71,   500.70,   749.78,  1000.05,  1249.81,
          1495.59,  2001.01,  2500.07,  4999.69,  7527.94, 10000.51, 14999.06,
         19716.95, 25059.80, 27923.26, 32916.13, 33466.10},
        JD={
          0.00000,  0.01852,  0.04416,  0.08001,  0.13893,  0.24031,  0.38507,
          0.54387,  0.69247,  0.81635,  0.92617,  1.06531,  1.15572,  1.21245,
          1.25222,  1.30438,  1.36020,  1.40426,  1.44489,  1.47165,  1.49202,
          1.50887,  1.53725,  1.56065,  1.64700,  1.71122,  1.76217,  1.84126,
          1.89384,  1.93351,  1.94746,  1.96320,  1.96432});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M330_50A;

    record M350_50A "M350-50A @ 50Hz"
      extends BaseData(
        Type="M350-50A",
        vRef =      3.50,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7650.00,
        mu_ri=   1253.27,
        k0   = 23,
        Hpar =  12495.23,
        Hsat =  156864.8,
        Jsat =   2.01894,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         1.30943e-06, 1.76540e-06, 2.95940e-06, 8.74022e-07,-2.07419e-06,
        -3.02623e-06,-3.76862e-06,-2.76685e-06,-1.79994e-07, 1.17601e-06,
         9.48923e-07, 2.47131e-07, 1.30776e-07, 5.82667e-08, 2.83000e-08,
         7.02395e-09, 1.36506e-09, 2.31282e-10, 5.53054e-11, 2.83632e-11,
         8.01659e-12, 6.25850e-12, 2.15443e-12, 4.77822e-13, 2.87350e-14,
         4.84878e-14, 8.98326e-15, 5.84281e-15, 5.82329e-15, 3.98637e-15,
        -1.61346e-15, 7.04108e-14},
        c2={
         0.00000e+00, 3.93565e-05, 9.23332e-05, 1.80928e-04, 2.07070e-04,
         1.42811e-04, 5.26492e-05,-5.66896e-05,-1.41199e-04,-1.46620e-04,
        -1.11663e-04,-4.01098e-05,-2.15256e-05,-1.14907e-05,-7.16862e-06,
        -2.97211e-06,-8.85651e-07,-2.59315e-07,-8.55251e-08,-4.46425e-08,
        -2.33521e-08,-1.73920e-08,-8.04107e-09,-4.72884e-09,-1.17830e-09,
        -9.62544e-10,-6.03205e-10,-4.71803e-10,-3.81537e-10,-3.10788e-10,
        -2.60672e-10,-2.76985e-10},
        c1={
         1.57364e-03, 1.96794e-03, 3.28521e-03, 6.01206e-03, 9.88033e-03,
         1.34934e-02, 1.54346e-02, 1.53955e-02, 1.33808e-02, 1.04913e-02,
         7.93211e-03, 4.11734e-03, 2.57235e-03, 1.72786e-03, 1.26649e-03,
         7.65250e-04, 3.83267e-04, 2.08150e-04, 1.21777e-04, 8.97031e-05,
         7.26901e-05, 6.25926e-05, 4.99260e-05, 4.33819e-05, 2.87505e-05,
         2.33924e-05, 1.95246e-05, 1.42830e-05, 9.88858e-06, 7.08484e-06,
         4.69005e-06, 2.87801e-06},
        c0={
         0.00000e+00, 1.70826e-02, 4.24723e-02, 8.73903e-02, 1.66179e-01,
         2.88007e-01, 4.33134e-01, 5.83917e-01, 7.31866e-01, 8.51784e-01,
         9.42486e-01, 1.08638e+00, 1.16828e+00, 1.22218e+00, 1.25876e+00,
         1.30726e+00, 1.36072e+00, 1.40350e+00, 1.44300e+00, 1.46864e+00,
         1.48874e+00, 1.50544e+00, 1.53307e+00, 1.55684e+00, 1.64254e+00,
         1.70756e+00, 1.76021e+00, 1.84211e+00, 1.90395e+00, 1.93812e+00,
         1.96265e+00, 1.97543e+00},
        HD={ 0.00,    10.02,    20.02,    30.00,    39.97,    50.30,    60.23,
            69.90,    80.08,    90.12,   100.03,   125.16,   150.23,   175.81,
           200.53,   249.96,   348.98,   501.92,   752.40,   998.80,  1249.01,
          1496.84,  1994.88,  2507.34,  4984.23,  7487.03,  9957.33, 14833.17,
         19982.85, 24032.59, 28223.24, 31593.49, 32904.77},
        JD={
          0.00000,  0.01606,  0.04233,  0.08334,  0.16110,  0.28531,  0.43068,
          0.58355,  0.73339,  0.85184,  0.94065,  1.08398,  1.16658,  1.22053,
          1.25716,  1.30567,  1.35915,  1.40194,  1.44144,  1.46708,  1.48717,
          1.50388,  1.53151,  1.55527,  1.64097,  1.70600,  1.75864,  1.84054,
          1.90238,  1.93656,  1.96108,  1.97387,  1.97732});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M350_50A;

    record M400_50A "M400-50A @ 50Hz"
      extends BaseData(
        Type="M400-50A",
        vRef =      4.00,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7700.00,
        mu_ri=    973.82,
        k0   = 23,
        Hpar =  12403.56,
        Hsat =  155318.2,
        Jsat =   2.02447,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         5.72271e-07, 2.43302e-07, 7.99627e-07, 3.11504e-06, 3.84620e-06,
        -3.00575e-06,-4.85923e-06,-3.87915e-07,-3.15109e-06,-2.04888e-06,
         9.58726e-07, 5.83564e-07, 1.72141e-07, 1.02202e-07, 4.56211e-08,
         9.25520e-09, 1.38354e-09, 2.53440e-10, 5.78433e-11, 2.13267e-11,
         1.52527e-11, 4.25375e-12, 2.88466e-12, 4.46033e-13, 3.22002e-14,
         4.37365e-14, 1.22564e-14, 4.35679e-15, 4.35068e-15, 4.66512e-15,
         6.43326e-15, 5.95883e-14},
        c2={
         0.00000e+00, 1.71866e-05, 2.44918e-05, 4.84246e-05, 1.42316e-04,
         2.57380e-04, 1.67336e-04, 2.09721e-05, 9.44116e-06,-8.70191e-05,
        -1.47644e-04,-7.56783e-05,-3.06605e-05,-1.81439e-05,-1.04305e-05,
        -3.68724e-06,-9.00131e-07,-2.75880e-07,-8.61578e-08,-4.26992e-08,
        -2.66615e-08,-1.52019e-08,-8.84488e-09,-4.52603e-09,-1.18646e-09,
        -9.44450e-10,-6.18683e-10,-4.32760e-10,-3.72358e-10,-3.15556e-10,
        -2.58401e-10,-1.92566e-10},
        c1={
         1.22248e-03, 1.39453e-03, 1.81167e-03, 2.53913e-03, 4.45552e-03,
         8.44133e-03, 1.26824e-02, 1.45731e-02, 1.48745e-02, 1.40829e-02,
         1.17684e-02, 6.18060e-03, 3.44617e-03, 2.26330e-03, 1.54444e-03,
         8.48864e-04, 3.88383e-04, 2.11511e-04, 1.21172e-04, 8.89011e-05,
         7.15147e-05, 6.10305e-05, 4.90516e-05, 4.23787e-05, 2.81217e-05,
         2.27832e-05, 1.89022e-05, 1.35856e-05, 9.86488e-06, 6.87108e-06,
         4.52713e-06, 2.98882e-06},
        c0={
         0.00000e+00, 1.28121e-02, 2.87347e-02, 5.00409e-02, 8.35992e-02,
         1.45997e-01, 2.52961e-01, 3.92247e-01, 5.38326e-01, 6.87739e-01,
         8.16207e-01, 1.03325e+00, 1.15206e+00, 1.22003e+00, 1.26711e+00,
         1.32334e+00, 1.38076e+00, 1.42352e+00, 1.46305e+00, 1.48891e+00,
         1.50884e+00, 1.52532e+00, 1.55248e+00, 1.57511e+00, 1.65962e+00,
         1.72313e+00, 1.77455e+00, 1.85589e+00, 1.90986e+00, 1.94610e+00,
         1.96922e+00, 1.98191e+00},
        HD={ 0.00,    10.01,    20.02,    30.00,    40.04,    50.02,    60.00,
            70.04,    79.95,    90.15,   100.02,   125.04,   150.75,   174.99,
           200.15,   249.42,   349.80,   500.20,   749.73,  1000.16,  1250.83,
          1501.27,  1999.42,  2498.48,  4994.23,  7499.53,  9982.33, 15038.84,
         19660.14, 24012.14, 28095.98, 31507.13, 32584.33},
        JD={
          0.00000,  0.01174,  0.02872,  0.05212,  0.08379,  0.13713,  0.25006,
          0.39690,  0.53434,  0.68837,  0.81912,  1.03212,  1.15089,  1.21926,
          1.26636,  1.32261,  1.38007,  1.42283,  1.46237,  1.48822,  1.50816,
          1.52464,  1.55179,  1.57443,  1.65894,  1.72245,  1.77386,  1.85521,
          1.90918,  1.94542,  1.96853,  1.98122,  1.98429});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M400_50A;

    record M470_50A "M470-50A @ 50Hz"
      extends BaseData(
        Type="M470-50A",
        vRef =      4.70,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7700.00,
        mu_ri=    719.13,
        k0   = 23,
        Hpar =  13221.84,
        Hsat =  165628.7,
        Jsat =   2.05381,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         4.23501e-07, 1.99147e-07, 8.70201e-08, 8.70152e-07, 3.15225e-06,
         2.87889e-06,-1.00541e-06,-4.49788e-06,-2.54532e-06,-2.55462e-06,
        -7.49111e-07, 1.29739e-06, 3.69753e-07, 1.01680e-07, 4.91171e-08,
         8.82758e-09, 1.63533e-09, 2.86210e-10, 5.61168e-11, 3.02473e-11,
         1.06894e-11, 6.24386e-12, 2.64901e-12, 4.58480e-13, 2.45429e-14,
         4.64264e-14, 8.89366e-15, 6.03648e-15, 2.77430e-15, 6.00954e-15,
         4.24588e-15, 4.99038e-14},
        c2={
         0.00000e+00, 1.26667e-05, 1.86679e-05, 2.12682e-05, 4.74186e-05,
         1.42410e-04, 2.28418e-04, 1.97589e-04, 6.57279e-05,-7.19967e-06,
        -8.74040e-05,-1.43609e-04,-4.63113e-05,-1.86824e-05,-1.10776e-05,
        -3.68708e-06,-1.03958e-06,-3.05729e-07,-9.06358e-08,-4.85317e-08,
        -2.58270e-08,-1.78542e-08,-8.56134e-09,-4.53750e-09,-1.09505e-09,
        -9.12746e-10,-5.60455e-10,-4.27453e-10,-3.45677e-10,-2.98939e-10,
        -2.40842e-10,-1.94613e-10},
        c1={
         9.02431e-04, 1.02872e-03, 1.34347e-03, 1.74126e-03, 2.42933e-03,
         4.33613e-03, 8.02901e-03, 1.23832e-02, 1.49564e-02, 1.55154e-02,
         1.45253e-02, 8.74770e-03, 3.99998e-03, 2.38115e-03, 1.63922e-03,
         8.98684e-04, 4.26155e-04, 2.24923e-04, 1.25630e-04, 9.08249e-05,
         7.22195e-05, 6.13594e-05, 4.82546e-05, 4.16222e-05, 2.75251e-05,
         2.25538e-05, 1.88275e-05, 1.39029e-05, 1.04117e-05, 6.79182e-06,
         5.05237e-06, 3.47196e-06},
        c0={
         0.00000e+00, 9.41676e-03, 2.12299e-02, 3.65500e-02, 5.70022e-02,
         8.93838e-02, 1.49531e-01, 2.54384e-01, 3.90066e-01, 5.36685e-01,
         6.95341e-01, 9.92227e-01, 1.14143e+00, 1.21804e+00, 1.26737e+00,
         1.32791e+00, 1.38973e+00, 1.43569e+00, 1.47734e+00, 1.50397e+00,
         1.52413e+00, 1.54066e+00, 1.56747e+00, 1.59005e+00, 1.67298e+00,
         1.73480e+00, 1.78675e+00, 1.86778e+00, 1.92240e+00, 1.97046e+00,
         1.98944e+00, 2.00481e+00},
        HD={ 0.00,     9.97,    20.01,    29.98,    39.99,    50.04,    60.00,
            70.22,    79.99,    89.54,   100.01,   125.01,   150.01,   174.92,
           199.85,   250.01,   349.98,   499.56,   750.07,  1000.16,  1250.38,
          1499.00,  1995.10,  2501.43,  5004.23,  7480.22, 10009.60, 14994.52,
         19510.15, 25125.71, 28348.23, 31977.55, 33277.47},
        JD={
          0.00000,  0.00864,  0.02059,  0.03698,  0.05922,  0.08855,  0.14439,
          0.24971,  0.39189,  0.53617,  0.69699,  0.99416,  1.13982,  1.21722,
          1.26680,  1.32736,  1.38921,  1.43518,  1.47684,  1.50347,  1.52363,
          1.54015,  1.56696,  1.58954,  1.67248,  1.73429,  1.78625,  1.86728,
          1.92190,  1.96995,  1.98894,  2.00431,  2.00860});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M470_50A;

    record M530_50A "M530-50A @ 50Hz"
      extends BaseData(
        Type="M530-50A",
        vRef =      5.30,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7700.00,
        mu_ri=    196.58,
        k0   = 23,
        Hpar =  13814.11,
        Hsat =  173137.7,
        Jsat =   2.06747,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         9.07813e-08,-3.16847e-08, 3.34104e-07, 9.23527e-07, 1.58810e-06,
         3.39753e-06, 2.67545e-06,-3.39965e-06,-3.71597e-06,-4.22437e-06,
        -6.29441e-07, 3.03955e-07, 1.03457e-06, 9.68701e-08, 5.47453e-08,
         9.73747e-09, 1.82644e-09, 2.98321e-10, 6.72683e-11, 2.36689e-11,
         1.56235e-11, 5.50840e-12, 2.62096e-12, 4.41805e-13, 2.47881e-14,
         4.11538e-14, 8.62826e-15, 5.76601e-15, 4.04312e-15, 1.21516e-15,
         1.02087e-14, 3.75784e-14},
        c2={
         0.00000e+00, 2.72389e-06, 1.77038e-06, 1.17929e-05, 3.95033e-05,
         8.70783e-05, 1.88071e-04, 2.67919e-04, 1.64487e-04, 5.39018e-05,
        -7.36856e-05,-1.20526e-04,-9.75857e-05,-1.95744e-05,-1.24219e-05,
        -4.08373e-06,-1.13080e-06,-3.20164e-07,-9.66411e-08,-4.59866e-08,
        -2.83974e-08,-1.66059e-08,-8.24057e-09,-4.35404e-09,-1.04463e-09,
        -8.58486e-10,-5.49079e-10,-4.19928e-10,-3.38495e-10,-2.84909e-10,
        -2.68671e-10,-1.46034e-10},
        c1={
         2.45779e-04, 2.73022e-04, 3.18105e-04, 4.53729e-04, 9.66775e-04,
         2.23079e-03, 4.95710e-03, 9.49340e-03, 1.38786e-02, 1.60450e-02,
         1.58458e-02, 1.10284e-02, 5.54120e-03, 2.59641e-03, 1.80891e-03,
         9.70925e-04, 4.43817e-04, 2.29153e-04, 1.25053e-04, 8.92525e-05,
         7.08267e-05, 5.95050e-05, 4.69272e-05, 4.07018e-05, 2.72220e-05,
         2.24582e-05, 1.89307e-05, 1.40959e-05, 1.05255e-05, 7.77134e-06,
         5.30555e-06, 3.64495e-06},
        c0={
         0.00000e+00, 2.54902e-03, 5.52987e-03, 9.22178e-03, 1.58635e-02,
         3.10378e-02, 6.49958e-02, 1.35557e-01, 2.55843e-01, 4.06075e-01,
         5.68762e-01, 9.06876e-01, 1.11288e+00, 1.20694e+00, 1.26043e+00,
         1.32741e+00, 1.39388e+00, 1.44071e+00, 1.48262e+00, 1.50898e+00,
         1.52863e+00, 1.54490e+00, 1.57148e+00, 1.59298e+00, 1.67434e+00,
         1.73632e+00, 1.78786e+00, 1.86972e+00, 1.92737e+00, 1.96761e+00,
         1.99668e+00, 2.01428e+00},
        HD={ 0.00,    10.00,    20.03,    30.03,    40.03,    50.02,    59.93,
            69.88,    80.02,    89.94,   100.01,   124.81,   149.97,   175.10,
           199.71,   250.48,   351.57,   499.51,   749.27,  1000.28,  1247.99,
          1499.57,  2005.78,  2500.07,  4996.96,  7500.10, 10006.19, 14995.66,
         19703.32, 24121.22, 28575.49, 32579.79, 33875.16},
        JD={
          0.00000,  0.00229,  0.00586,  0.00982,  0.01655,  0.03309,  0.06403,
          0.12820,  0.25536,  0.40536,  0.57295,  0.90788,  1.11364,  1.20571,
          1.26027,  1.32725,  1.39377,  1.44060,  1.48251,  1.50887,  1.52852,
          1.54479,  1.57137,  1.59287,  1.67423,  1.73621,  1.78775,  1.86961,
          1.92726,  1.96751,  1.99658,  2.01417,  2.01873});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M530_50A;

    record M600_50A "M600-50A @ 50Hz"
      extends BaseData(
        Type="M600-50A",
        vRef =      6.00,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7750.00,
        mu_ri=    439.73,
        k0   = 22,
        Hpar =  13477.55,
        Hsat =  168677.0,
        Jsat =   2.07351,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 32,
        c3={
         1.50523e-07, 2.02462e-08,-6.07255e-08,-4.84084e-08, 3.37181e-07,
         2.13336e-06, 5.43918e-06, 5.93800e-07,-4.95943e-06,-2.87895e-06,
        -2.46534e-07, 1.17840e-06, 2.47271e-07, 9.94426e-08, 1.43707e-08,
         2.54377e-09, 3.78158e-10, 6.85175e-11, 3.51174e-11, 1.61473e-11,
         5.68986e-12, 2.99489e-12, 4.81343e-13, 2.89820e-14, 4.07497e-14,
         8.63194e-15, 7.63187e-15, 6.57039e-16, 6.75484e-15, 2.17377e-15,
         6.04702e-14},
        c2={
         0.00000e+00, 9.04927e-06, 9.65455e-06, 7.84325e-06, 6.37854e-06,
         1.67727e-05, 7.90969e-05, 2.41613e-04, 2.59204e-04, 1.09585e-04,
        -1.10543e-04,-1.28654e-04,-3.94360e-05,-2.08413e-05,-5.80378e-06,
        -1.53987e-06,-3.92123e-07,-1.07311e-07,-5.60660e-08,-2.99570e-08,
        -1.76877e-08,-9.15534e-09,-4.67962e-09,-1.08421e-09,-8.62347e-10,
        -5.49728e-10,-4.26318e-10,-3.16608e-10,-3.07663e-10,-2.21682e-10,
        -1.97066e-10},
        c1={
         5.51326e-04, 7.32671e-04, 9.19060e-04, 1.09303e-03, 1.23647e-03,
         1.47436e-03, 2.40794e-03, 5.60209e-03, 1.05473e-02, 1.42560e-02,
         1.42315e-02, 8.37428e-03, 4.13218e-03, 2.62123e-03, 1.27816e-03,
         5.51854e-04, 2.61283e-04, 1.35899e-04, 9.51684e-05, 7.38497e-05,
         6.17823e-05, 4.83647e-05, 4.14728e-05, 2.71217e-05, 2.21545e-05,
         1.85435e-05, 1.38921e-05, 1.03322e-05, 7.49900e-06, 5.25304e-06,
         3.67236e-06},
        c0={
         0.00000e+00, 1.22598e-02, 2.04797e-02, 3.05122e-02, 4.22844e-02,
         5.60291e-02, 7.39470e-02, 1.11149e-01, 1.90596e-01, 3.17831e-01,
         7.04694e-01, 9.83279e-01, 1.13162e+00, 1.21432e+00, 1.30623e+00,
         1.38977e+00, 1.44659e+00, 1.49346e+00, 1.52173e+00, 1.54240e+00,
         1.55945e+00, 1.58662e+00, 1.60881e+00, 1.69049e+00, 1.75312e+00,
         1.80482e+00, 1.88164e+00, 1.93926e+00, 1.97969e+00, 2.00649e+00,
         2.02327e+00},
        HD={ 0.00,    20.04,    30.00,    39.95,    50.03,    60.31,    70.05,
            80.01,    89.88,    99.94,   125.42,   149.91,   175.15,   200.21,
           250.62,   349.52,   499.92,   750.98,  1000.28,  1248.10,  1501.38,
          2001.24,  2499.39,  4989.23,  7541.01, 10098.23, 14863.85, 19655.59,
         24193.95, 28436.86, 32211.63, 33297.92},
        JD={
          0.00000,  0.01192,  0.02020,  0.03035,  0.04257,  0.05799,  0.07771,
          0.10518,  0.18379,  0.32014,  0.70766,  0.98480,  1.13033,  1.21396,
          1.30594,  1.38958,  1.44641,  1.49328,  1.52155,  1.54222,  1.55927,
          1.58644,  1.60863,  1.69031,  1.75294,  1.80464,  1.88146,  1.93908,
          1.97951,  2.00631,  2.02309,  2.02693});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M600_50A;

    record M700_50A "M700-50A @ 50Hz"
      extends BaseData(
        Type="M700-50A",
        vRef =      7.00,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7800.00,
        mu_ri=    395.25,
        k0   = 23,
        Hpar =  13185.51,
        Hsat =  164989.8,
        Jsat =   2.08224,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         2.25292e-07, 2.17369e-08, 2.69107e-08, 4.53339e-08, 7.62918e-08,
         4.10301e-09, 6.17063e-07, 2.12893e-06, 4.09689e-06, 2.85051e-06,
        -5.62987e-06,-2.68036e-07, 1.22849e-06, 3.02997e-07, 1.30077e-07,
         1.50981e-08, 2.75726e-09, 3.90964e-10, 8.10450e-11, 3.84346e-11,
         1.19977e-11, 7.73065e-12, 2.65775e-12, 4.91951e-13, 2.67480e-14,
         3.89445e-14, 1.08901e-14, 6.35911e-15, 2.70478e-15, 3.83695e-15,
         5.17925e-15, 2.38654e-14},
        c2={
         0.00000e+00, 6.77061e-06, 7.42609e-06, 8.22951e-06, 9.59068e-06,
         1.18803e-05, 1.20035e-05, 3.05037e-05, 9.44037e-05, 2.17652e-04,
         3.02385e-04,-1.19829e-04,-1.40004e-04,-4.82916e-05,-2.55269e-05,
        -6.28255e-06,-1.64018e-06,-4.12656e-07,-1.18785e-07,-5.80880e-08,
        -2.94735e-08,-2.04431e-08,-8.72660e-09,-4.78915e-09,-1.07761e-09,
        -8.78016e-10,-5.85552e-10,-4.23213e-10,-3.36178e-10,-2.92382e-10,
        -2.54111e-10,-1.73284e-10},
        c1={
         4.95428e-04, 5.63253e-04, 7.05954e-04, 8.61753e-04, 1.04011e-03,
         1.25490e-03, 1.49380e-03, 1.91861e-03, 3.16831e-03, 6.29754e-03,
         1.14503e-02, 1.60139e-02, 9.49487e-03, 4.80918e-03, 2.96048e-03,
         1.39179e-03, 5.79763e-04, 2.75122e-04, 1.41968e-04, 9.78131e-05,
         7.60832e-05, 6.35595e-05, 4.88231e-05, 4.21486e-05, 2.73946e-05,
         2.25303e-05, 1.88666e-05, 1.38540e-05, 1.03895e-05, 6.99695e-06,
         5.17997e-06, 2.95669e-06},
        c0={
         0.00000e+00, 5.18946e-03, 1.15572e-02, 1.93446e-02, 2.88392e-02,
         4.02806e-02, 5.40259e-02, 7.07692e-02, 9.51506e-02, 1.40546e-01,
         2.27086e-01, 6.14343e-01, 9.36459e-01, 1.10497e+00, 1.19988e+00,
         1.29940e+00, 1.39231e+00, 1.45123e+00, 1.50041e+00, 1.52971e+00,
         1.55099e+00, 1.56842e+00, 1.59630e+00, 1.61861e+00, 1.70214e+00,
         1.76402e+00, 1.81553e+00, 1.89616e+00, 1.95116e+00, 1.99787e+00,
         2.01804e+00, 2.03884e+00},
        HD={ 0.00,    10.02,    20.07,    30.02,    40.03,    50.03,    60.04,
            70.03,    80.03,    90.06,    99.97,   124.97,   150.06,   174.94,
           199.99,   249.30,   351.80,   500.20,   750.75,  1000.39,  1248.56,
          1499.45,  2004.65,  2498.48,  5013.32,  7500.67, 10003.92, 14972.93,
         19535.15, 24932.54, 28257.33, 33459.28, 35879.58},
        JD={
          0.00000,  0.00468,  0.01129,  0.01910,  0.02861,  0.03993,  0.05449,
          0.07231,  0.09723,  0.13879,  0.21669,  0.62048,  0.93798,  1.10360,
          1.19941,  1.29899,  1.39202,  1.45096,  1.50014,  1.52944,  1.55072,
          1.56815,  1.59604,  1.61834,  1.70187,  1.76376,  1.81526,  1.89589,
          1.95089,  1.99760,  2.01777,  2.03857,  2.04505});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M700_50A;

    record M800_50A "M800-50A @ 50Hz"
      extends BaseData(
        Type="M800-50A",
        vRef =      8.00,
        BRef =   1.50000,
        fRef =     50.00,
        dens =   7800.00,
        mu_ri=    411.68,
        k0   = 23,
        Hpar =  13353.77,
        Hsat =  166704.9,
        Jsat =   2.09350,
        hH1  =   5000.00,
        hH2  =  20000.00,
        N    = 33,
        c3={
         1.90315e-07, 2.08524e-08,-2.04512e-08, 2.98284e-08, 1.88974e-08,
         1.10009e-08, 7.91359e-08, 1.94741e-07, 1.94884e-06, 3.76409e-06,
        -6.04043e-07,-3.77056e-06, 3.40141e-07, 9.52723e-07, 1.74006e-07,
         2.65371e-08, 2.85748e-09, 5.81237e-10, 7.30224e-11, 4.76474e-11,
         1.35706e-11, 7.91860e-12, 3.29524e-12, 4.93526e-13, 2.86204e-14,
         4.60034e-14, 9.66755e-15, 6.83894e-15, 1.76070e-15, 4.65897e-15,
        -1.60819e-15, 3.35981e-14},
        c2={
         0.00000e+00, 5.74283e-06, 6.36652e-06, 5.75497e-06, 6.65160e-06,
         7.21746e-06, 7.54802e-06, 9.93005e-06, 1.57686e-05, 7.40974e-05,
         1.88039e-04, 1.42163e-04,-1.34057e-04,-1.09278e-04,-3.58149e-05,
        -9.81053e-06,-1.84448e-06,-5.57140e-07,-1.22468e-07,-6.74554e-08,
        -3.17383e-08,-2.16443e-08,-9.75633e-09,-4.79581e-09,-1.10469e-09,
        -8.91893e-10,-5.45869e-10,-4.02414e-10,-3.02611e-10,-2.79251e-10,
        -2.19757e-10,-2.37081e-10},
        c1={
         5.16081e-04, 5.73846e-04, 6.94574e-04, 8.15395e-04, 9.39707e-04,
         1.07814e-03, 1.22603e-03, 1.40140e-03, 1.65822e-03, 2.55479e-03,
         5.19982e-03, 1.35594e-02, 1.37573e-02, 7.84854e-03, 4.11922e-03,
         1.84639e-03, 6.80167e-04, 3.19510e-04, 1.50097e-04, 1.02403e-04,
         7.76177e-05, 6.43821e-05, 4.86685e-05, 4.13664e-05, 2.66563e-05,
         2.17080e-05, 1.81032e-05, 1.34128e-05, 9.98320e-06, 7.40994e-06,
         5.28589e-06, 3.64553e-06},
        c0={
         0.00000e+00, 5.38466e-03, 1.16973e-02, 1.92328e-02, 2.80107e-02,
         3.80715e-02, 4.96058e-02, 6.27469e-02, 7.79382e-02, 9.79865e-02,
         1.35176e-01, 3.77537e-01, 7.38511e-01, 9.98399e-01, 1.14411e+00,
         1.28195e+00, 1.39506e+00, 1.46528e+00, 1.51931e+00, 1.55044e+00,
         1.57256e+00, 1.59006e+00, 1.61785e+00, 1.64023e+00, 1.72120e+00,
         1.78091e+00, 1.83046e+00, 1.90782e+00, 1.96433e+00, 2.00271e+00,
         2.02955e+00, 2.04562e+00},
        HD={ 0.00,    10.06,    20.03,    30.00,    40.02,    50.00,    60.01,
            70.05,    80.04,    90.02,   100.11,   125.42,   149.84,   174.13,
           199.83,   249.64,   349.71,   499.88,   749.16,  1000.28,  1250.15,
          1498.09,  1998.51,  2500.30,  4993.33,  7471.69,  9978.92, 14925.21,
         19789.68, 24212.13, 28468.68, 32059.37, 34411.49},
        JD={
          0.00000,  0.00496,  0.01142,  0.01907,  0.02777,  0.03783,  0.04946,
          0.06266,  0.07981,  0.09993,  0.12973,  0.37353,  0.74319,  0.99890,
          1.14296,  1.28154,  1.39480,  1.46505,  1.51909,  1.55021,  1.57233,
          1.58983,  1.61762,  1.64000,  1.72097,  1.78069,  1.83023,  1.90759,
          1.96410,  2.00248,  2.02932,  2.04540,  2.05310});
      annotation(defaultComponentPrefixes="parameter",
        defaultComponentName="material",
        Icon(coordinateSystem(preserveAspectRatio=false)),
        Diagram(coordinateSystem(preserveAspectRatio=false)));
    end M800_50A;
    annotation (preferredView="info", Documentation(info="<html>
<p>The parameter records contain the following data:</p>
<p>Common parameters:</p>
<ul>
<li>specific losses <code>vRef</code></li>
<li>at specified flux density <code>BRef</code></li>
<li>and frequency <code>fRef</code></li>
<li>density <code>dens</code></li>
<li>initial relative permeability <code>mu_ri</code></li>
</ul>
<p>Parameters for Exponential Extrapolation:
<code>J(H) = JD[k0] + (Jsat - JD[k0])*(1 - exp(-(H - HD(k0))/Hpar))</code></p>
<ul>
<li>Index in raw data where exponential extrapolation starts <code>k0</code></li>
<li>Parameter in exponential function <code>Hpar</code></li>
<li>Field strength where saturation is nearly reached <code>Hsat</code></li>
<li>Saturation polarization <code>Jsat</code></li>
</ul>
<p>Homotopy borders for mixing Smoothing Splines with Exponential Extrapolation:</p>
<ul>
<li>Field strength where mixing starts <code>hH1</code></li>
<li>Field strength where mixing ends   <code>hH2</code></li>
</ul>
<p>For <code>H&lt;hH1</code> pure spline interpolation is used. 
   For <code>H&gt;hH2</code> pure exponential extrapolation is used. 
   In the region between both are mixed, linearly dependent on <code>H</code>.</p>
<p>Number of raw data nodes = 1 + number of spline coefficients <code>N</code>.</p>
<p>Parameters for Spline interpolation: 
<code>J(H) = c0[k] + c1[k]*(H - HD[k]) + c2[k]*(H - HD[k])^2 + c3[k]*(H - HD[k])^3</code></p>
<ul>
<li>coefficients for 3<sup>rd</sup> power <code>c3</code></li>
<li>coefficients for 2<sup>nd</sup> power <code>c2</code></li>
<li>coefficients for 1<sup>st</sup> power <code>c1</code></li>
<li>constant coefficients <code>c0</code></li>
</ul>
<p>Raw Data nodes:</p>
<ul>
<li>field strength array <code>HD</code></li>
<li>polarization  array  <code>JD</code></li>
</ul>
<p>
Measured data were provided by <a href=\"https://www.voestalpine.com/isovac/Downloads/Datenblaetter\">VoestAlpine</a>. 
Many thanks to that company for allowing us to use this data!
</p>
<p>Note:</p>
<ul>
<li>The origin <code>(0, 0)</code> has to be included as first node in the arrays.</li>
<li>The arrays have to be specified in ascending order.</li>
<li>The arrays are only specified for positive field strength, it is assumed that the characteristic is point symmetric to the origin.</li>
</ul>
</html>"));
  end SSEE;

  package Types "Types with choices, especially to build menus"
    extends Modelica.Icons.TypesPackage;

    type MagType       = enumeration(
      Roschke "Approximation formula according to Roschke",
      SSEE "Approximation with Smoothing Splines and Exponential Extrapolation")
      "Enumeration defining the approximation of the magnetization characteristic";
    type SpecificPower=Real(final quantity="SpecificPower", final unit="W/kg");
    type MagneticFieldStrengthSlope=Real(final quantity="MagneticFieldStrengthSlope",
          final unit="A/(m.s)");
    type MagneticFluxDensitySlope=Real(final quantity="MagneticFluxDensitySlope",
          final unit="V/m2");
  end Types;
  annotation (uses(Modelica(version="4.1.0")));
end ShowCharacteristic;
