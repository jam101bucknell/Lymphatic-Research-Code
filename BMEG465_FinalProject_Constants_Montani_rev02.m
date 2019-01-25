%% Constants Code
% Written by John Montani
% November 1, 2018

% Constant values used for the valve state change offset. First column is
% opening second is closing.
b1 = [0.140,-0.1274]; %no units
b2 = [0.01060,0.04790]; %no units
b3 = [0.2465,1.208]; %no units
b4 = [0.6728,0.4354]; %no units

% passive ?ptm-D diameter scale
Dd = 0.025; %cm

%Constants used in the passive contraction cycle.
c = zeros(11,1);
c(11) = 0.32538081; %no units
c(1) = -2.34457751; %no units
c(2) = 1.1262924; %no units
c(3) = 3.76013762; %no units
c(4) = 79.991135; %no units
c(5) = 1.0028029; %no units
c(6) = 1.59133174; %no units
c(7) = 3.69692633; %no units
c(8) = 0.20699868; %no units
c(9) = Dd / c(11); %cm
c(10) = -0.0180867408; %no units

%Upstream pressure
Pa = 2270; %dyne/cm^2

%Downstream pressure
Pb = 2570; %dyne/cm^2

%?ptm-D pressure scale
Pd = 35; %dyne/cm^2

%External pressure
Pe = 2000; %dyne/cm^2

%min. valve resistance RVn 
Rvn = 6000000; %dyn s / cm^5 

%valve resistance RVx increase
Rvx = 96000000; %dyn s / cm^5 

%valve state-change slope constant
So = 0.2; %cm^2/dyn

%Vessel length
L = 3; %cm

%Viscosity
mu = 0.01; %Poise

%Maximum active tension
M0 = 700; %dyn/cm

%Active length tension relations
Da = 0.85 * c(9); %cm 
Db = 2 * c(9); %cm
Sd = 3.25/Dd; %cm^2/dyn

%Contraction frequency
f = 0.5 ; %Hz
