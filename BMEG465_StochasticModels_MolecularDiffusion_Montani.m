%% Molecular Diffusion
%Written by John Montani 10/14/2018

clear 
clc
close all

%Part A
%Determine the sample size and test duration

nWalkers = 1000;
nTime = 1000;
t = 1:nTime;

%Give all samples an initial location of 0
xWalkers = zeros(nWalkers,nTime);

%select the distance each can move at the time step
dL = 0.1;

%Determine whether each one moves forwards or backwards during each step
for k = 1:nTime
    for n = 1:nWalkers
        if k == 1
            if rand <= 0.5
                xWalkers(n,k) = dL;
            else
                xWalkers(n,k) = -dL;
            end
            
        elseif rand <= 0.5
            xWalkers(n,k) = xWalkers(n,k-1)+dL;
        else
            xWalkers(n,k) = xWalkers(n,k-1)-dL;
        end
    end
end

%Determine the distance squared each one is from the origin
squareDistance = xWalkers.^2;
meanSquaredDist = mean(squareDistance);

%Plot the mean squared distance as time passes
figure(1)
plot(t,meanSquaredDist)
ylabel('Distance from Origin')
xlabel('Time')

%make a histogram showing the distance of each sample at the last time step
figure(2)
count = histogram(xWalkers(:,nTime),'BinEdges',[-nTime*dL-1:nTime*dL]);
ylabel('Number of Samples')
xlabel('Distance from Origin')

%Determine the probability of a sample ending a certain distance from
%origin using the test data.

values = count.Values;
for k = 1:length(values)
    observedProbability(k) = values(k)/(nWalkers);
end

%Determine the estimate probability of a sample ending a certain distance
%from the origin.

x = -nTime*dL:nTime*dL;
D = 0.5 * dL^2;
estimatedProbability = 1 ./ sqrt((4 * pi * D * nTime)) .* exp(- x.^2 ./ (4*D* nTime));

%Plot the observed and estimated probabilities against eachother
figure(3)
plot(linspace(min(xWalkers(:,nTime)),max(xWalkers(:,nTime)),length(count.Values)) ...
    ,observedProbability,'r',linspace(min(xWalkers(:,nTime)),max(xWalkers(:,nTime)) ... 
    ,length(count.Values)),estimatedProbability,'k')
ylabel('Decimal Probability')
xlabel('Distance from Origin')
legend('Observed Probability','Estimated Probability')

%Part B
%Set the initial paramaters where each point has an initial x and y
%coordinate at 0.
xWalkers = zeros(nWalkers,nTime);
yWalkers = zeros(nWalkers,nTime);
locationX = zeros(nWalkers,nTime);
locationY = zeros(nWalkers,nTime);
magnitude = zeros(nWalkers,nTime);
unitVectorX = zeros(nWalkers,nTime);
unitVectorY = zeros(nWalkers,nTime);

%Determine the random movement of each sample and use the random values to
%create a unit vector in the x and y direction which is used to determine
%the new location of the point.

for k = 1:nTime
    for n = 1:nWalkers
        xWalkers(n,k) = (2*rand-1);
        yWalkers(n,k) = (2*rand-1);
        magnitude(n,k) = sqrt(xWalkers(n,k)^2+yWalkers(n,k)^2);
        unitVectorX(n,k) = dL * xWalkers(n,k)/magnitude(n,k);
        unitVectorY(n,k) = dL * yWalkers(n,k)/magnitude(n,k);
        if k == 1
            locationX(n,k) = unitVectorX(n,k);
            locationY(n,k) = unitVectorY(n,k);
        else
            locationX(n,k) = unitVectorX(n,k) + locationX(n,k-1);
            locationY(n,k) = unitVectorY(n,k) + locationY(n,k-1);
        end
    end
end

%Determine the mean distance from origin as time passes.
squareDistance2 = locationX.^2 + locationY.^2;
meanSquaredDist2 = mean(squareDistance2);

%Plot the mean distances against time
figure(4)
plot(t,meanSquaredDist2)
ylabel('Distance from Origin')
xlabel('Time')

%Determine the distance from origin of each sample at the last timestep
r = sqrt(locationX(:,nTime).^2+locationY(:,nTime).^2);

%Make a histogram showing the distances of each sample at the final
%timestep
figure(5)
count2 = histogram(r,'BinEdges',[0:nTime*dL]);
ylabel('Number of Samples')
xlabel('Distance from Origin')

%Calculate the probability of a sample being a certin distance from origin
%based on the sample data
values2 = count2.Values;
for k = 1:length(values2)
    observedProbability2(k) = values2(k)/ (2*pi*count2.BinEdges(1,k+1)*nWalkers);
end

%Determine the estimate probability of a sample being a certain distance
%from origin.
x2 = 0:nTime*dL-1;
D2 = 0.25 * dL^2;
estimatedProbability2 = 1 ./(4 * pi * D2 * nTime) .* exp(- x2.^2 ./ (4*D2* nTime));

%Overlay the observed and epected probabilities.
figure(6)
plot(linspace(0,max(r),length(values2)) ...
    ,observedProbability2,'r',linspace(0,max(r) ... 
    ,length(values2)),estimatedProbability2,'k')
ylabel('Decimal Probability')
xlabel('Distance from Origin')
legend('Observed Probability','Estimated Probability')
