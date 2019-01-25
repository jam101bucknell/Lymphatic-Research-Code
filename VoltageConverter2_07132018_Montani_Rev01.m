%% Pressure/Flow Equivalents
% Created on 07/13/2018 by John Montani

% Description: This code takes the output voltages from the pressure
% sensors and flow meters and converts them to pressure and flow values,
% respectively.

%%%THIS CODE NEEDS TO BE CHANGED ANY TIME A NEW PRESSURE SENSOR OR A NEW%%%
      %%%FLOW METER IS ADDED TO THE SYSTEM (OR IF ANY ARE REMOVED)%%%

%% Calculations

%All these equations for the pressure sensors came from the
%LymphaticModel_MouserPressureSensors_Calibration_06182018_Montani-Rev03 file
%found in the calibration folder.

pressureHistory1 = 3.4339 .* analogHistory(:,1) - 1.8326; %V
pressureHistory2 = 3.4291 .* analogHistory(:,2) - 1.9699; %V
pressureHistory3 = 3.4638 .* analogHistory(:,3) - 1.8193; %V
pressureHistory4 = 3.471 .* analogHistory(:,4) - 1.8304; %V
pressureHistory5 = 3.4455 .* analogHistory(:,5) - 1.8126; %V
pressureHistory6 = 3.4553 .* analogHistory(:,6) - 1.8432; %V
pressureHistory7 = 3.4326 .* analogHistory(:,7) - 1.8067; %V
pressureHistory8 = 3.5493 .* analogHistory(:,8) - 1.888; %V

outputPressuresHistory = [pressureHistory1 pressureHistory2 pressureHistory3 pressureHistory4 pressureHistory5 pressureHistory6 pressureHistory7 pressureHistory8]; %mV

for row = 1:length(pressureHistory1)
    for column = 1:numberOfLymphangions
        averagePressureHistory(row,column) = mean(outputPressuresHistory(row,2*column:2*column+1));
    end
end

%These equations for the flow meters came from
%LymphaticModel_FlowMeters_Calibration_06062018_Montani-Rev02 found in the
%calibration folder. In the excel file, the flow meter number corresponds
%to the number on the back of the flow meters.

flowHistory1 = 200.12 .* analogHistory(:,9) + 0.1621 ; %mL/min
flowHistory2 = 200.67 .* analogHistory(:,10) - 2.6025 ; %mL/min

outputFlowsHistory = [flowHistory1 flowHistory2]; %mL/min
