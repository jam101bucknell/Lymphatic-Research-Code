%% Lymphatic Model Command Code
% Description: This is the primary code for running the lymphatic model.
% All initial inputs are put into this code, and from there it calls upon
% other files ( LymphaticModel_Setup_05302018_Montani_Rev02,
% LymphaticPumpingPattern_PressureBased_05292018_Rev06, 
% voltageConverter_06062018_Montani_Rev02, 
% voltageConverter2_07132018_Montani_Rev01 and
% GraphingGenerator_05302018_Montani_Rev05 ) to run the lymphatic model.

% Updated by John Montani on 7/9/2018

clear;
clc;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE SURE TO KEEP ALL FILE NAMES UPDATED
% DO NOT EDIT IN BETWEEN PERCENTAGE SYMBOL LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Connecting To DAQ Device
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit %

%First step of the process is creating a session and establishing a
%connection to the device.

d = daq.getDevices;
s = daq.createSession('ni');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inputs
% Alter the inputs in the code based on the amount of pressure sensors and
% solenoids in the system. If desired, change the amount of cycles or the
% pumping interval in order to alter the duration or rate of the test. The
% thresholds and switchPoint just are constants that determine when changes
% in the  lymphangions' states will occur.

flowMeters = 2; %Number of flow meters in the system
channels = 6; %Number of output channels used
pressureSensors = channels + 2; %Number of pressure sensors in the system.
pressureThreshold = 0; %Threshold at which solenoids will be opened or closed based on pressure sensors
flowThreshold = 500; %Threshold at which solenoids will be opened or closed based on flow meters
cycles = 200; %How many times the code will be run
pumpingInterval = 0.25; %How much time in between each cycle
switchPoint = 20; %How many times a lymphangion can stay the same state before momentarily switching to the other state.

%% Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit Unless Updating File Name %

% Initiates the programs setup code, which adds the necessary input/output
% ports to the code.

LymphaticModel_Setup_05302018_Montani_Rev02
outputSingleScan(s,lymphangionsState)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Commands
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit Unless Updating File Name %

% ADDED IN: This code gets the system running a bit before data collection
% so that the data represents the model properly functioning as opposed to
% having a 5-10s portion of the data that is staggered and illogical.

for t = 1:20
    pause(pumpingInterval)
    for v = 1:numberOfLymphangions
        if lymphangionsState(1,2*v-1:2*v) == activeState
            lymphangionsState(1,2*v-1:2*v) = steadyState;
        else
            lymphangionsState(1,2*v-1:2*v) = activeState;
        end
    end
    outputSingleScan(s,lymphangionsState)
end

%These variables will save the data produced by each run of the code.

analogHistory = [];
outputPressuresHistory = [];
outputFlowsHistory = [];
averagePressureHistory = [];
lymphangionsStateHistory = lymphangionsState;
 
%These variables track the time at which analog inputs and digital outputs
%are determined.

inputTiming = [];
pumpingTiming = [];

% counter is a variable used in the
% LymphaticPumpingPatter_PressureBased_05292018_Montani_Rev02 file to
% keep track of how many times a lymphangion has a certain state
% repeatively. If counter gets to a high enough value, then the code
% commands the lymphangion to switch states momentarily.

counter = zeros(1,numberOfLymphangions);
saveCounter = counter;

%Run the system
tic
for run = 1 : cycles
    %Inputs the analog data for each active port and marks the time that it
    %occurs at.
    analogInput = inputSingleScan(s);
    analogHistory = cat(1,analogHistory,analogInput);
    inputTiming = cat (1, inputTiming, toc);
    
    % Calls for the voltage converter code in order to transformm the input
    % voltage readings to either pressures or flow rates.
    
    VoltageConverter_06062018_Montani_Rev02
   
    %Runs the pumping pattern code to determine the appropriate pumping
    %matrix for the system based on the inputted analog data.
    LymphaticPumpingPattern_PressureBased_05292018_Montani_Rev06
    
end
finalTime = toc - pumpingTiming(1,1);
% Since it takes a half a second or so for the code to begin working, the
% timing vectors need to be zeroed in reference to when they begin.

zeroedInputTiming = inputTiming - inputTiming(1,1);
zeroedPumpingTiming = pumpingTiming - inputTiming(1,1);

%Shuts off all solenoids to prevent overheating
outputSingleScan(s,ones(1,channels))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit Unless updating File Name/Variable Names in Excel Sheet

% Calls for second voltage converter to switch all voltage readings to flow
% and pressure values that are saved into a variable.

VoltageConverter2_07132018_Montani_Rev01

% Calls for the graphing generator code to plot the appropriate data.

GraphingGenerator_05302018_Montani_Rev05

% Output data to the excel file LymphaticModel_RawData_06062018_Montani
% in case further data analysis is desired. Save each data set as a
% different Rev if desired so that it could be looked at at a future date.

A = array2table(analogHistory, 'VariableNames',{'Sensor1', 'Sensor2', ...
    'Sensor3','Sensor4', 'Sensor5', 'Sensor6', 'Sensor7', 'Sensor8',...
    'Meter1', 'Meter2'});
B = array2table(outputFlowsHistory, 'VariableNames',{'Flow1','Flow2'});
C = array2table(outputPressuresHistory, 'VariableNames',{'Sensor1', 'Sensor2', ...
    'Sensor3', 'Sensor4', 'Sensor5', ' Sensor6', 'Sensor7', 'Sensor8'});
D = array2table(averagePressureHistory,'VariableNames',{'Lymphangion1'...
    'Lymphangion2', 'Lymphangion3'});
E = array2table(lymphangionsStateHistory,'VariableNames',{'Channel1',...
    'Channel2', 'Channel3','Channel4', 'Channel5', 'Channel6'});
F = array2table(zeroedInputTiming,'VariableNames',{'InputTiming'});
G = array2table(zeroedPumpingTiming,'VariableNames',{'PumpingTiming'});

writetable(A,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Analog Input History')
writetable(B,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Flow History')
writetable(C,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Pressure History')
writetable(D,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Averaged Pressure History')
writetable(E,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Lymphangions State History')
writetable(F,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Input Timing')
writetable(G,'LymphaticModel_RawData_06062018_Montani.xlsx','Sheet', 'Output Timing')

xlswrite('LymphaticModel_RawData_06062018_Montani.xlsx',{'Pumping Interval',...
    'Cycles', 'Pressure Threshold', 'Flow Threshold', 'Switch Point'; pumpingInterval,...
    cycles, pressureThreshold, flowThreshold, switchPoint},...
    'Initial Conditions')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 