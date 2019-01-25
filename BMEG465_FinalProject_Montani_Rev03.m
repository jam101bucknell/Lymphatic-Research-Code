%% Final Project Rev 02
% Written by John Montani
% Programmed following C.D Bertram's and Luke Reixinger's Computational
% Models
% November 1, 2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THE GOAL OF THIS REVISION IS TO GENERALIZE THE CODE ENOUGH SO THAT IT CAN
% ADD OR REMOVE THE TOTAL NUMBER OF LYMPHANGIONS IN THE SYSTEM BY JUST
% CHANGING ONE PARAMETER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup

clear
clc
close all

%% Initialize constants

BMEG465_FinalProject_Constants_Montani_rev02

%% Initial Conditions

%Determine how many lymphangion units are desired in this model.
units = 2;

%Since there is a valve at the beginning of the vessel and ones after each
%unit, there is 1 more valve than there are lymphangions.
valves = units + 1;

%Set the initial Diameter and transmural pressures for each lymphangion.
for i = 1:units
    D(1,i) = 0.025; %cm
    PM(1,i) = Pa + (Pb-Pa)/valves * i; %dyne/cm^2
end

%Determine the initial pressure difference across each valve and the 
for i = 1:valves
    dPV(1,i) = 35; %dyne/cm^2
    dP0(1,i) = -35; %dyne/cm^2
end


%% Time constants

%tr represents the period following the contraction cycle where another
%contraction cannot occur.

tr = 1; %seconds

%tbegin is used as a varying parameter where it can offset each
%lymphangions contraction cycle. In this model, when the time divided by
%the total contraction cycle has a remainder of zero, the next contraction
%cycle is initiated but it waits a period of length tbegin before it
%actually starts.

for i = 1:units
    tbegin(i) = 0.25 + 0.5*(i-1); %seconds
end

% Total period of contraction and relaxation for a unit.
tcycle = 1/f+tr; %seconds

% Total time the program will run so that 50 contraction cycles will occur.
tmax = 50*tcycle; %seconds

% Time step
dt = 0.01; %seconds

% Length variable used to determine how many cycles will occur.
xmax = round(tmax/dt);



%% Calculations

% Set an empty variable to input values for the contribution of active
% tension.
MT = zeros(xmax,units);

% Begin the test
for i = 1:xmax
    
    %Time starts at 0
    time(i) = (i-1)*dt; %seconds
    
    %Set a variable to determine how many valves were closed during this
    %loop of the program.
    ValvesClosed(i) = 0;
    
    %Calculate the resistances of each valve.
    for j = 1:valves
        if j == 1
            Rv(i,j) = Rvn + Rvx / (1+exp(-So*(-dPV(i,j) + dP0(i,j)))); %dyn s /cm^5 
        else
            Rv(i,j) = Rvn + Rvx / (1+exp(-So*(-dPV(i,j) + dP0(i,j)))); %dyn s / cm^5 
        end
        
        %If the valve's resistance is greater than Rvx then it is
        %determined to be closed.
        if Rv(i,j) > Rvx 
            ValvesClosed(i) = ValvesClosed(i) + 1;
            ValveState(i,j) = 0;
        else
            ValveState(i,j) = 1;
        end
    end
    
    % Calculate the pressure to flow relation for the Hagen?Poiseuille
    % equation.
    for j = 1:units
        A(i,j) = 64*mu*L/(pi*D(i,j)^4); %Poise/cm^3
    end
    
    % Calculate the flow through each valve. If the valve is closed then
    % the flow through it is zero.
    for j = 1:valves
        if ValveState(i,j) == 0
            Q(i,j) = 0; %cm^3/s
        elseif j == 1
            Q(i,j) = (Pa - PM(i,j))/(A(i,j) + Rv(i,j)); %cm^3/s
        elseif j == valves
            Q(i,j) = (PM(i,j-1) - Pb)/(A(i,j-1) + Rv(i,j));  %cm^3/s
        else
            Q(i,j) = (PM(i,j-1) - PM(i,j))/(A(i,j-1) + A(i,j) + Rv(i,j));  %cm^3/s
        end
        
    end
        
    %Calculate the pressures in each lymphangion unit. Pin represents the
    %pressure in the front half of the vessel and pout represents the
    %pressure in the back half of it.
    for j = 1:units
        Pin(i,j) = A(i,j)*Q(i,j) + PM(i,j); %dyne/cm^2
        Pout(i,j) = PM(i,j) - A(i,j)*Q(i,j+1); %dyne/cm^2
    end
    
    %Calculate the pressure drop across each valve for the next run of the
    %code by using the previously calculated pressures for this run of the
    %code.
    for j = 1:valves
        if j == 1
            dPV(i+1,j) = Pa - Pin(i,j); %dyne/cm^2
        elseif j == valves
            dPV(i+1,j) = Pout(i,j-1) - Pb; %%dyne/cm^2
        else
            dPV(i+1,j) = Pout(i,j-1) - Pin(i,j); %dyne/cm^2
        end
    end
    
    % Calculations for the diameters and contraction cycles of the
    % lymphangions.
    for j = 1:units
        
        %Diameters for the next run of the program
        D(i+1,j) = D(i,j)+2*(Q(i,j)-Q(i,j+1))/(pi*L*D(i,j))*dt; %cm
        
        %Passive contraction of the vessel.
        fP(i,j) = Pd*(c(1)*(D(i,j)/c(9)-c(2))^2+c(3)*exp(c(4)*(D(i,j)/c(9) ... 
            -c(5)))+c(6)+c(7)*(D(i,j)/c(9)-c(8))+c(10)*(c(11)/D(i,j))^3); %dyne/cm^2
        
        %Active length tension relation
        MD(i,j) = 1/(1+exp(-Sd*(D(i,j)-Da)))+1/(1+exp(Sd*(D(i,j)-Db)))-1; %unitless
        
        %Determine the start time and period for a contraction cycle. Also
        %calculate the wave of active tension MT.
        if rem(time(i),tcycle) == 0
            tstart(j) = time(i) + tbegin(j); %seconds
            tfinish(j) = time(i) + 1/f + tbegin(j); %seconds
            timeRange(:,j) = tstart(j):dt:tfinish(j); %seconds
            if length(timeRange(:,j)) > length(tstart(j)/dt:(tfinish(j)/dt))
                iRange(:,j) = tstart(j)/dt:(tfinish(j)/dt+1);
            else
                iRange(:,j) = tstart(j)/dt:tfinish(j)/dt;
            end
            MT(round(iRange(:,j)),j) = M0.*(1-cos(2.*pi.*f.*(timeRange(:,j)-tstart(j))))./2; %dyne/cm
        else
            MT(i,j) = MT(i,j); %dyne/cm
        end
        
        %Combination of active tension and active length tension relation.
        M(i,j) = MD(i,j) * MT(i,j); %dyne/cm
        
        %Active contraction cycle. 
        fA(i,j) = 2*M(i,j)/D(i,j); %dyne/cm^2
        
        %law of Laplace relating transmural pressure and radius to wall
        %tension. Manipulated to calculate the pressure in the center of
        %each vessel for the next cycle of the code.
        PM(i+1,j) = fP(i,j) + fA(i,j) + Pe; %dyne/cm^2
        
    end
    
    %Calculate the valve state change offset for the next run of the code.
    %This variable has two equations. One for when the valve is opening and
    %another for when it is closing. Also the equations are set in cm H20
    %thus all calculated values of pressure used in these equations needed
    %to be changed to cm H20 and then the final value for dP0 was converted
    %back to dyne cm^-2. The factor for going from cm H20 to dyne cm^-2 is
    %980.665 dyne cm^-2/cm H20.
    for j = 1:units
        if time(i) >= (tfinish(j)+tstart(j))/2 && time(i) <= tfinish(j)
            
            %Calculate the transmural pressure that will be used.
            if j == 1
                dPM1(i,j) = (Pa - Pe)/980.665; %dyne/cm^2
                dPM2(i,j) = (Pin(i,j) - Pe)/980.665; %dyne/cm^2
            elseif j == valves
                dPM2(i,j) = (Pb - Pe)/980.665; %dyne/cm^2
                dPM1(i,j) = (Pout(i,j) - Pe)/980.665; %dyne/cm^2
            else
                dPM1(i,j) = (Pout(i,j) - Pe)/980.665; %dyne/cm^2
                dPM2(i,j) = (Pin(i,j) - Pe)/980.665; %dyne/cm^2
            end
            
            %Calculate dP0.
            dP0(i+1,j) =  980.665 * (b1(1) - b2(1) * dPM1(i,j) ... 
                - b3(1)*(1 - exp( - b4(1) * dPM1(i,j)^2))); %dyne/cm^2
            dP0(i+1,j+1) = 980.665 * ( b1(2) - b2(2) * dPM2(i,j) ... 
                - b3(2)*(1 - exp( - b4(2) * dPM2(i,j)^2))); %dyne/cm^2

        else 
            
            %Calculate the transmural pressure that will be used.
            dPM1(i,j) = (Pin(i,j) - Pe)/980.665; %dyne/cm^2
            dPM2(i,j) = (Pout(i,j) - Pe)/980.665; %dyne/cm^2
            
            %Calculate dP0.
            dP0(i+1,j) =  980.665 * ( b1(2) - b2(2) * dPM1(i,j) ... 
                - b3(2)*(1 - exp( - b4(2) * dPM1(i,j)^2))); %dyne/cm^2
            dP0(i+1,j+1) =  980.665 * (b1(1) - b2(1) * dPM2(i,j) ... 
                - b3(1)*(1 - exp( - b4(1) * dPM2(i,j)^2))); %dyne/cm^2
            
        end
            
    end
            
end

% All flow calculations were done in cm^3/s so now they must be converted
% to mL/hr for plotting reasons. The conversion factor is 3600 (ml/hr)/(cm^3/s)

newFlow = Q.*3600; %ml/hr

count = zeros(xmax,units);
for i = 1:xmax
    for j = 1:units
        if MT(i,j) == max(MT(:,j))
            count(j) = count(j)+1;
            Peaks(count(j),j) = i;
        end
    end
end

%Calculate the average flow out of the system.
averageFlowOut = mean(newFlow(Peaks(30,units):Peaks(40,units),valves)); %ml/hr

%% Graphing

% Produce all the plots for that run of the trial.
BMEG465_FinalProject_GraphingCode_Montani

figure
plot(time,D(1:xmax,:))
xlabel('Time (s)')
ylabel('Diameter (cm)')
legend('D1','D2')