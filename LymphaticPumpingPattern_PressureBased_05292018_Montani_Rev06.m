%% Lymphatic Model Pumping Pattern
% Created on May 30, 2018 by John Montani

% Description: This code takes the analog input data acquired from the
% pressure sensors and alters the lymphangions' states accordingly. While
% doing so it keeps the first lymphangion pumping at a constant rate in
% order to ensure flow through the system at all times.

% All pressure data input in is PSI and all flow data is in mL/min.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAKE SURE TO KEEP ALL FILE NAMES UPDATED
% DO NOT EDIT IN BETWEEN PERCENTAGE SYMBOL LINES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pressure Data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%DO NOT EDIT%%%%

%CHANGE FROM REV 05 TO 06 IS THAT EACH CYCLE CAN RESULT IN MORE THAN ONE
%CONTRACTION THUS ALL CONDITIONAL CODE HAD TO BE GROUPED TOGETHER TO
%DETERMINE THE PUMPING CYCLE. IT IS SET TO HAVE THE UNIT WITH THE HIGHEST
%PRESSURE OVER THE THRESHOLD TO PUMP FIRST FOLLOWED BY THE NEXT HIGHEST AND
%SO ON. THIS RESULTS IN NO SIMULTANEOUS PUMPING PATTERNS AND SHOULD ALLOW
%ALL UNITS OVER THE THRESHOLD TO CONTRACT ONCE.

% The average pressure of the two pressure sensors in each lymphangion's
% system will be used as the reference for whether the lymphangion needs
% to switch states or not.

for c = 1 : numberOfLymphangions
    averagePressure(c) = mean(outputPressures(1,2 * c:2 * c + 1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determining Pumping Sequence 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%DO NOT EDIT%%%%

% In order to avoid simultaneously pumping units, sequential pumping is
% hard coded into this program where the unit with the greatest difference
% from the threshold will pump first followed by the next greatest and so
% on.

% This code just sets up the threshold differences for all units in order
% from highest difference to lowest.

thresholdDifference = averagePressure - pressureThreshold;
sortedThresholds = sort(thresholdDifference,'descend');
lymphangionsStateMatrix = repmat(steadyState, numberOfLymphangions, numberOfLymphangions);
sizeMatrix = size(lymphangionsStateMatrix,1);

%This for loop sets up the proposed pumping sequence based on the input
%data.  If flow is higher than its threshold, then all units are kept in
%steady state and the loop breaks. If it is below the threshold, then the
%code will make a matrix n x n large (n being how many solenoids are in the
%system), which in each row has one of the units, that has surpassed the
%pressure threshold, contract.

for position = 1:length(sortedThresholds)
    for meter = 1:flowMeters
        if outputFlows(1,meter) >= flowThreshold
            brokenFlowThreshold = 1;
            lymphangionsState = repmat(steadyState,1,numberOfLymphangions);
            break
        else
            brokenFlowThreshold = 0;
            for l = 1:numberOfLymphangions
                if thresholdDifference(1,l) == sortedThresholds(1,position) && thresholdDifference(1,l) >= 0
                    lymphangionsStateMatrix(position,2*l-1:2*l) = activeState; 
                end
            end
        end
    end
end

% If after that for loop, the lymphangionsStateMatrix remains the same as a
% n x n steady state matrix, then the pressure threshold has not been
% surpassed in the system. 

if lymphangionsStateMatrix == repmat(steadyState, numberOfLymphangions, numberOfLymphangions)
    brokenPressureThreshold = 0;
else
    brokenPressureThreshold = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Final Pumping Sequence

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%DO NOT EDIT%%%%

% This section dictates the final output pumping sequence. If the flow in
% either flow meter is above the threshold, steady state sequnces will be
% send out to each unit unless a unit has been stuck in a state for a long
% time (then it will momentarily switch states). If threshold has not been
% broken, then the matrix produced in the above for loop is further
% adjusted based on other requirements. These requirements include forcing 
% a unit to go steadystate if it was just active in its last run, removing 
% any rows from the matrix if it represents a unit that has not surpassed 
% the threshold and will just output a steady state command, or switch a 
% unit momentarily if it has been stuck in the same state for a while. In 
% any case, analog data is input following each pumping cycle in order to
% analyze how the internal conditions change for the system. 

%REMEMBER THE FIRST AND LAST PRESSURE SENSORS HAVE NO IMPACT ON THE PUMPING
%SCHEME SINCE NEITHER LIE WITHIN THE DOMAIN OF A LYMPHANGION UNIT

%For when the flow threshold has been surpassed

if brokenFlowThreshold == 1
    sample = length(lymphangionsStateHistory(:,1));
    
    %This loop just makes sure that the units do not get stuck in a single
    %state and will switch states momentarily if they do.
    
    for d = 1:numberOfLymphangions
        if lymphangionsState(1,(2 * d - 1): (2 * d)) == lymphangionsStateHistory(sample,(2 * d - 1): (2 * d))
            counter(1,d) = counter(1,d) + 1;
        else
            counter(1,d) = 0;
        end
        if counter(1,d) >= switchPoint
            if lymphangionsState(1,(2 * d - 1): (2 * d)) == steadyState
                lymphangionsState(1,(2 * d - 1): (2 * d)) = activeState;
            else
                lymphangionsState(1,(2 * d - 1): (2 * d)) = steadyState;
            end
            counter(1,d) = 0;
        end
    end
    
    %Save the timing and pumping scheme of any run that uses this pathway.
    %Output the desired pumping scheme.
    
    saveCounter = cat(1,saveCounter,counter);
    outputSingleScan(s,lymphangionsState)
    pumpingTiming = cat(1, pumpingTiming, toc);
    lymphangionsStateHistory = cat(1,lymphangionsStateHistory,lymphangionsState);
    pause(pumpingInterval)
    
% If both flow and pressure are below their respective thresholds.

elseif brokenPressureThreshold == 0
    
    %Set up a variable that references the previous run. This run is
    %necessary in determing the following pumping sequence.
    
    sample = length(lymphangionsStateHistory(:,1));
    lymphangionsState = repmat(steadyState,1,numberOfLymphangions);
    
    %Similar to above, this ensures that no unit gets stuck in a set state.
    
    for d = 1:numberOfLymphangions
        if lymphangionsState(1,(2 * d - 1): (2 * d)) == lymphangionsStateHistory(sample,(2 * d - 1): (2 * d))
            counter(1,d) = counter(1,d) + 1;
        else
            counter(1,d) = 0;
        end
        if counter(1,d) >= switchPoint
            if lymphangionsState(1,(2 * d - 1): (2 * d)) == steadyState
                lymphangionsState(1,(2 * d - 1): (2 * d)) = activeState;
            else
                lymphangionsState(1,(2 * d - 1): (2 * d)) = steadyState;
            end
            counter(1,d) = 0;
        end
    end
    
    %Save all required information and output the proper pumping scheme
    
    saveCounter = cat(1,saveCounter,counter);
    outputSingleScan(s, lymphangionsState)
    pumpingTiming = cat(1, pumpingTiming, toc);
    lymphangionsStateHistory = cat(1,lymphangionsStateHistory,lymphangionsState);
    pause(pumpingInterval)

%If the pressure is above the threshold but not flow

else
    
    %Need to analyze each row of the lymphangionsStateMatrix to truncate
    %any lines that are not desired.
    
    row = 1;
    while row <= sizeMatrix
        if lymphangionsStateMatrix(row,:) == repmat(steadyState,1,numberOfLymphangions)
            lymphangionsStateMatrix(row:sizeMatrix,:) = [];
            sizeMatrix = size(lymphangionsStateMatrix,1);
        else
            row = row + 1;
        end
    end
    
    %Takes the refined lymphangionsStateMatrix and passes it through a
    %series of tests, altering the matrix if desires.
    
    %This section ensures no lymphangion has been stuck in a specific state
    %for too long.
    
    for row = 1:size(lymphangionsStateMatrix,1)
        sample = length(lymphangionsStateHistory(:,1));
        for d = 1:numberOfLymphangions
            if lymphangionsStateMatrix(row,(2 * d - 1): (2 * d)) == lymphangionsStateHistory(sample,(2 * d - 1): (2 * d))
                counter(1,d) = counter(1,d) + 1;
            else
                counter(1,d) = 0;
            end
            if counter(1,d) >= switchPoint
                if lymphangionsStateMatrix(row,(2 * d - 1): (2 * d)) == steadyState
                    lymphangionsStateMatrix(row,(2 * d - 1): (2 * d)) = activeState;
                else
                    lymphangionsStateMatrix(row,(2 * d - 1): (2 * d)) = steadyState;
                end
                counter(1,d) = 0;
            end
            
            %This section makes sure that any unit that was set to contract
            %last run will be switched back to steady state on this next
            %run. 
            
            if lymphangionsStateHistory(sample,(2 * d - 1): (2 * d)) == activeState
                lymphangionsStateMatrix(row,(2 * d - 1): (2 * d)) = steadyState;
            end
        end
        
        %Save all necessary data and output the desired scheme. Data is
        %input for each one of these loops where pressure is above the
        %threshold because many of these contraction cycles occur some time
        %after the initial input that determined this sequence was taken.
        %Thus we want to know exactly what impact the pumping sequence had
        %on the system. The last run of this loop does not input any data
        %though because the main loop in the Command Code will do it.
        
       
        outputSingleScan(s,lymphangionsStateMatrix(row,:))
        saveCounter = cat(1,saveCounter,counter);
        pumpingTiming = cat(1, pumpingTiming, toc);
        lymphangionsStateHistory = cat(1,lymphangionsStateHistory,lymphangionsStateMatrix(row,:));
        if row == size(lymphangionsStateMatrix,1)
            pause(pumpingInterval)
            break
        else
            analogInput = inputSingleScan(s);
            analogHistory = cat(1,analogHistory,analogInput);
            inputTiming = cat (1, inputTiming, toc);
        end
        pause(pumpingInterval)
    end
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%