%% Graphing Code for Final Project
% Written by John Montani 
% November 1, 2018

% length vector to account for the number of cycles that should be plotted.
% Due to the code setup, some vectors have 1 too many rows which needs to
% be omitted.
lengthTime = length(time);

%Plot resistances of each valve in subplots
figure
for i = 1:valves
    subplot(valves,1,i)
    plot(time,Rv(:,i))
    xlabel('Time (s)')
    ylabel(['R_',num2str(i),' (dyne s cm^{-1})'])
end


%Plot the pressure drops across each valve in subplots
figure
for i = 1:valves
    subplot(valves,1,i)
    plot(time,dPV(1:lengthTime,i))
    xlabel('Time (s)')
    ylabel(['\DeltaP_',num2str(i),' (dyne cm^{-2})'])
end

%Plot flow through each valve in subplots
figure
for i = 1:valves
    subplot(valves,1,i)
    plot(time,Q(:,i))
    xlabel('Time (s)')
    ylabel(['Q_',num2str(i),' (cm^{-2} s^{-1})'])
end

%Plot the resistances, pressures, and associated vessels diameters for each
%valve
for i = 1:valves
    if i == 1
        figure
        subplot(3,1,1)
        plot(time,Rv(:,i))
        xlabel('Time (s)')
        ylabel(['R_',num2str(i),' (dyne s cm^{-1})'])
        title('Valve 1')
        subplot(3,1,2)
        plot(time,dPV(1:lengthTime,i))
        xlabel('Time (s)')
        ylabel(['\DeltaP_',num2str(i),' (dyne cm^{-2})'])
        subplot(3,1,3)
        plot(time,D(1:lengthTime,i))
        xlabel('Time (s)')
        ylabel(['D_',num2str(i),' (cm)'])
    elseif i == valves
        figure
        subplot(3,1,1)
        plot(time,Rv(:,i))
        xlabel('Time (s)')
        ylabel(['R_',num2str(i),' (dyne s cm^{-1})'])
        title(['Valve ', num2str(valves)])
        subplot(3,1,2)
        plot(time,dPV(1:lengthTime,i))
        xlabel('Time (s)')
        ylabel(['\DeltaP_',num2str(i),' (dyne cm^{-2})'])
        subplot(3,1,3)
        plot(time,D(1:lengthTime,i-1))
        xlabel('Time (s)')
        ylabel(['D_',num2str(i-1),' (cm)'])
    else
        figure
        subplot(4,1,1)
        plot(time,Rv(:,i))
        xlabel('Time (s)')
        ylabel(['R_',num2str(i),' (dyne s cm^{-1})'])
        title(['Valve ', num2str(i)])
        subplot(4,1,2)
        plot(time,dPV(1:lengthTime,i))
        xlabel('Time (s)')
        ylabel(['\DeltaP_',num2str(i),' (dyne cm^{-2})'])
        subplot(4,1,3)
        plot(time,D(1:lengthTime,i))
        xlabel('Time (s)')
        ylabel(['D_',num2str(i),' (cm)'])
        subplot(4,1,4)
        plot(time,D(1:lengthTime,i-1))
        xlabel('Time (s)')
        ylabel(['D_',num2str(i-1),' (cm)'])
    end
end

%Plot the number of valves closed at each time step
figure
scatter(time,ValvesClosed)
xlabel('Time (s)')
ylabel('Number of Valves Closed')

%Plot the flow, diameter, and central pressure for each unit
for i = 1:units
    figure
    subplot(3,1,1)
    plot(time,Q(:,i+1))
    xlabel('Time (s)')
    ylabel(['Q_',num2str(i),' (cm^{-2} s^{-1})'])
    title(['Lymphangion ' num2str(i)])
    subplot(3,1,2)
    plot(time,D(1:lengthTime,i))
    xlabel('Time (s)')
    ylabel(['D_',num2str(i),' (cm)'])
    subplot(3,1,3)
    plot(time,PM(1:lengthTime,i))
    xlabel('Time (s)')
    ylabel(['Central Pressure_',num2str(i),' (dyne cm^{-2})'])
end

%Plot the valve states at each time step
for i = 1:valves
    names(i) = {['valve ', num2str(i)]};
end

% The plots are not generalized. They were written strictly for the
% parametric study and only work for two lymphangion units.
figure
plot(time,(ValveState(:,1)+0.01),time,(ValveState(:,2)),time,(ValveState(:,3)-0.01),'LineWidth',4)
legend(names)
title('1 = open, 0 = closed')
xlim([18 24])
xlabel('Time (s)')
%Plot the active tension characteristics for each units as time passes
figure
plot(time,MT(1:lengthTime,1),'--k',time,MD(1:lengthTime,1),'--r',time,M(1:lengthTime,1),'--m',time,MT(1:lengthTime,2),'-k',time,MD(1:lengthTime,2),'-r',time,M(1:lengthTime,2),'-m')
legend('M_{T1}','M_{D1}','M_{1}','M_{T2}','M_{D2}','M_{2}')
xlim([18 24])

%Plot the flow through the system
figure
plot(time,newFlow)
xlim([18 24])
legend('Q1','Q2','Q3')
xlabel('Time (s)')
ylabel('Flow (ml/hr)')
