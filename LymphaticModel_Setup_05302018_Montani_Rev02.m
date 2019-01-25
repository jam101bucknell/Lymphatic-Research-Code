%% Lymphatic Model Set Up
% Created on May 30, 2018 by John Montani

% Description: This code takes the initial inputs in the
% LymphaticModel_CommandCode_Summer2018_Rev06 file and manipulates them in
% order to determine the proper input/output Channel numbers for the
% device. Many of the variables used in this code originate from the
% CommandCode file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE SURE TO KEEP ALL FILE NAMES UPDATED
% DO NOT EDIT IN BETWEEN PERCENTAGE SYMBOL LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Setting up the Digital Output System
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit %

% Adds the appropriate digital output channels. These channels start at 0
% so for example six channels would be comprised of Port0/Line0:5.

IDNumbers = channels - 1;
channelID = strcat('Port0/Line0:',num2str(IDNumbers));
s.addDigitalChannel(d.ID,channelID,'OutputOnly')

% produces a vector with the appropriate length based on the number of
% channels used for the system. Each lymphangion is comprised of two
% channels. The initial setup of the lymphangionsState vector is with all
% lymphangions in steady state.

steadyState = [1 0];
activeState = [0 1];

numberOfLymphangions = channels / 2;

lymphangionsState = [];
for cntr = 1 : numberOfLymphangions
    lymphangionsState = cat(2,lymphangionsState,steadyState);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting up the Analog Inputs 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit %

% Add the required AI ports based on the number of pressure sensors and
% flow meters within the system. As with the digital output channels, the 
% analog input channels start at 0.
%CHANGE FROM REV01 TO REV02 IS THAT ALL TERMINALS ARE SINGLE ENDED NOW%
totalInputs = pressureSensors + flowMeters;
for a = 1 : totalInputs
    sensorID = a - 1;
    
    %After ai7, the port names swith to ai16 and so on
    
    if sensorID > 7
        sensorID = 16 + (a - 9) * 1;
    end
    portID = strcat('ai',num2str(sensorID));
    ch(a) = s.addAnalogInputChannel(d.ID,portID,'Voltage');
    ch(a).TerminalConfig = 'SingleEnded';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%