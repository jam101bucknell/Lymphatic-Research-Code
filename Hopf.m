function [Vsave, time] = Hopf(xy, w, I, V0, ntime, plots)
% Hopf runs a binary, discrete time, simultaneous update Hopfield model
% See: http://www.scholarpedia.org/article/Hopfield_network
% J. Baish
% 3/12/13

% Vsave records of all states (ntimexn)
% time is the time vector
% xy is an nx2 array of coordinates for the vertices
% w is the nxn weighting matrix for strengths of synaptic transmission
% I is the input or bias or offset or threshold for each neuron (nx1). 
% V0 is the initial column vectors (nx1) of the states (0 or 1)
% ntime is the number of time steps
% plots is string that will make plots if 'yes'

n = length(V0);
time = 1:ntime;
% Save values of states
Vsave = zeros(ntime, n);
Vsave(1,:) = V0; 
V = V0; 

for itime = 2:ntime
% Update state vector    
    % New firing is those exceeding firing threshold
    V = (w*V) + I > 0;  
    % Save the current state for later plotting
    Vsave(itime,:) = V;
    % Plot infected at each time step
    if strcmpi(char(plots), 'yes')
        figure(1); clf
        plot(xy(:,1),xy(:,2),'o'); axis square; hold on % Show all vertices
        plot(xy(find(V),1),xy(find(V),2),'*r') % Show all firing vertices
        gplot(w,xy); hold off   % Show the graph of connections
        title(['Firing at Time ', num2str(itime)]);
        pause(0.1)
    end
end

% Plot how many are in each state at each time
figure(2)
t = 1:ntime;
plot(t,sum(Vsave')/n)
axis([0 ntime 0 1])
xlabel('Time');ylabel('Fraction of Neurons Firing')