%% Graphing Generator
%Created May 30, 2018 by John Montani
%Last Updated July 09, 2018 by John Montani

%Description: This code takes the data acquired and saved by the command
%code and plots it. The plots include the analog data associated with each
%pressure sensor/flow meter plotted against time, and each lymphangion's 
%state plotted against time.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE SURE TO KEEP ALL FILE NAMES UPDATED
% DO NOT EDIT IN BETWEEN PERCENTAGE SYMBOL LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Plotting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit %
% Unless different designs are desired%

%Since the digital outputs are either 0 or 1 its fine to set the upper and
%lower limits as 2 and -1 respectively. This gives a +/- 1 spacing around
%the digital output range. Makes the plot better visually. 

limits = [-1,2];

%This for loop creates figures for the average voltage of each lymphangion.
%Each figure has a plot of the average voltage data versus time and two
%plots of the digital outputs data versus time. There are two for the
%digital outputs because there are two channels associated with each
%lymphangion. A horizontal line is on the analog data plot, representing
%the voltage threshold value. At any time the average voltage intersects 
%the voltage threshold a change in the digital output data can be seen. The
%plots are in a vertical subplot form to make it easy to compare each plot.

for e = 1 : numberOfLymphangions
    titleSensor = strcat('Lymphangion  ', num2str(e));
    figure(e)
    subplot(3,1,1)
    plot(zeroedInputTiming,averagePressureHistory(:,e), 'k', 'LineWidth', 1)
    xlabel('Time (s)')
    ylabel('Pressure (PSI)')
    xlim([0 , max(zeroedInputTiming)])
    title(titleSensor)
    line([0 max(inputTiming)], [pressureThreshold pressureThreshold],'Color','red','LineWidth', 1)
    
    subplot(3,1,2)
    plot(zeroedPumpingTiming, lymphangionsStateHistory(2:length(lymphangionsStateHistory),(e)*2-1), 'k', 'LineWidth', 1)
    xlabel('Time (s)')
    ylabel('Digital Output')
    ylim(limits)
    xlim([0 , max(zeroedPumpingTiming)])
    titleChannel1 = strcat('Channel ', num2str(e*2-1));
    title(titleChannel1)
    
    subplot(3,1,3)
    plot(zeroedPumpingTiming, lymphangionsStateHistory(2:length(lymphangionsStateHistory),(e)*2), 'k', 'LineWidth', 1)
    xlabel('Time (s)')
    ylabel('Digital Output')
    ylim(limits)
    xlim([0 , max(zeroedPumpingTiming)])
    titleChannel2 = strcat('Channel ', num2str(e*2));
    title(titleChannel2)
end

%Figure produced to compare the flow rate to the digital outputs. Note if
%the legend is in the way, just drag it with cursor out of the way.

for f = numberOfLymphangions + 1 : numberOfLymphangions * 2
    figure(f)
    subplot(3,1,1)
    plot(zeroedInputTiming, outputFlowsHistory(:,1),'-k', zeroedInputTiming, outputFlowsHistory(:,2),'-b')
    legend('Flow Meter 1','Flow Meter 2','Location','best')
    xlabel('Time (s)')
    ylabel('Flow (mL/min)')
    title('Flow Meters')
    line([0 max(inputTiming)], [flowThreshold flowThreshold],'Color','red','LineWidth', 1)
    xlim([0 , max(zeroedInputTiming)])
    
    subplot(3,1,2)
    plot(zeroedPumpingTiming, lymphangionsStateHistory(2:length(lymphangionsStateHistory),(f-numberOfLymphangions)*2 - 1), 'k', 'LineWidth', 1)
    xlabel('Time (s)')
    ylabel('Digital Output')
    ylim(limits)
    xlim([0 , max(zeroedPumpingTiming)])
    titleChannel1 = strcat('Channel ', num2str((f-numberOfLymphangions)*2 - 1));
    title(titleChannel1)
    
    subplot(3,1,3)
    plot(zeroedPumpingTiming, lymphangionsStateHistory(2:length(lymphangionsStateHistory),(f-numberOfLymphangions)*2), 'k', 'LineWidth', 1)
    xlabel('Time (s)')
    ylabel('Digital Output')
    ylim(limits)
    xlim([0 , max(zeroedPumpingTiming)])
    titleChannel2 = strcat('Channel ', num2str((f-numberOfLymphangions)*2));
    title(titleChannel2)
end


% The final two figures represent the readings coming from the first and
% last pressure sensor. Since neither of these sensors have an impact on 
% the states of the lymphangions, these figures only have the plot of their
% analog data versus time.

figure(numberOfLymphangions * 2 + 1)
plot(zeroedInputTiming, outputPressuresHistory(:,1), 'k', 'LineWidth', 1)
xlabel('Time (s)')
ylabel('Pressure (PSI)')
xlim([0 , max(zeroedInputTiming)])
title('Pressure Sensor 1')



figure(numberOfLymphangions * 2 + 2)
plot(zeroedInputTiming, outputPressuresHistory(:,pressureSensors), 'k', 'LineWidth', 1)
xlabel('Time (s)')
ylabel('Pressure (PSI)')
xlim([0 , max(zeroedInputTiming)])
titleSensor = strcat('Pressure Sensor', num2str(pressureSensors));
title(titleSensor)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
