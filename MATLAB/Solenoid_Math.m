%import CSV from MICROCAP

%data=readtable();

%--------------constants

%permeability of free space
mu_0=4.*pi.*10^(-7); %Henry/Meter
%relative permeability of copper
mu_copper=0.999994;
%Iron (99.8% pure)
mu_iron=5000;
%permeativity of free space
e_0=8.85.*10^(-12); %Farad/Meter

%Calculations

%----enterables----%
N=80; %number of turns [unit less]
Length=0.1; %length of solenoid [meters]
I=10; %current conducted [Amps]

%Henry=Weber/I
%Weber=Henry*I
%Tesla=Weber/Area

%B is magnetic Flux Density [Weber/Meter^2 or Newtons/{columb*(meter/s^2)} or Teslas] 
% pg 237 of book
%phi is magnetic flux [Weber]
%H is magnetic field [Amp/Meter]

B=(mu_copper.*mu_0.*N.*I)/(Length); %B is assumed along axis of a solenoid with length >> radius
%B is in Teslas

H=B/(mu_0.*mu_copper); %Henry, equation 5.2 B=muH or H=B/Mu
%H is in Amp/Meter

%need magnetization of material
%from https://royalsocietypublishing.org/doi/10.1098/rspa.1971.0044#:~:text=The%20saturation%20magnetizations%20of%20very,method%20are%20investigated%20and%20discussed.
m_iron=217.6*10^3;% emu/g 10^-3 emu/g = 1 A/M

%energy is m*H

Energy=m_iron.*H;

