%% Pressure/Flow Equivalents
% Created on 06/06/2018 by John Montani

% Description: This code takes the output voltages from the pressure
% sensors and flow meters and converts them to pressure and flow values,
% respectively.

%%%THIS CODE NEEDS TO BE CHANGED ANY TIME A NEW PRESSURE SENSOR OR A NEW%%%
      %%%FLOW METER IS ADDED TO THE SYSTEM (OR IF ANY ARE REMOVED)%%%

%% Calculations

%All these equations for the pressure sensors came from the
%LymphaticModel_MouserPressureSensors_Calibration_06182018_Montani-Rev03 file
%found in the calibration folder.

pressure1 = 3.4339 .* analogInput(1,1) - 1.8326; %V
pressure2 = 3.4291 .* analogInput(1,2) - 1.9699; %V
pressure3 = 3.4638 .* analogInput(1,3) - 1.8193; %V
pressure4 = 3.471 .* analogInput(1,4) - 1.8304; %V
pressure5 = 3.4455 .* analogInput(1,5) - 1.8126; %V
pressure6 = 3.4553 .* analogInput(1,6) - 1.8432; %V
pressure7 = 3.4326 .* analogInput(1,7) - 1.8067; %V
pressure8 = 3.5493 .* analogInput(1,8) - 1.888; %V

outputPressures = [pressure1 pressure2 pressure3 pressure4 pressure5 pressure6 pressure7 pressure8]; %mV

%These equations for the flow meters came from
%LymphaticModel_FlowMeters_Calibration_06062018_Montani-Rev02 found in the
%calibration folder. In the excel file, the flow meter number corresponds
%to the number on the back of the flow meters.

flow1 = 200.12 .* analogInput(1,9) + 0.1621 ; %mL/min
flow2 = 200.67 .* analogInput(1,10) - 2.6025 ; %mL/min

outputFlows = [flow1 flow2]; %mL/min
