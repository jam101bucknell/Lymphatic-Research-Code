%% Neural Networks
%Written by John Montani 10/5/2018

clear 
clc
close all

% Part A

%Randomly give 100 neurons an x and y coordinate.
n = 100;
for i = 1:n
    x_Coordinate(i) = rand;
    y_Coordinate(i) = rand;
end

Coordinates = [x_Coordinate;y_Coordinate];

%Part B

%Set the max distance for connectivity.
dmax = 0.2;

%Create an adjacency matrix based on the connectivity data. A vertex cannot
%be connected to itself so the diagonal of the matrix is set to 0.
Array = zeros(n,n);

for i = 1:length(Array(1,:))
    for j = 1:length(Array(:,1))
        if i == j 
            Array(i,j) = 0;
        elseif sqrt((x_Coordinate(i) - x_Coordinate(j))^2 + (y_Coordinate(i) - y_Coordinate(j))^2) <= dmax
            Array(i,j) = 1;
        else
            Array(i,j) = 0;
        end
    end
end

%Use spy and gplot to visualize the connectivity in the system.
figure(3) 
spy(Array)

figure(4)
gplot(Array,Coordinates','-*')

%Create a weighted matrix for the adjacency matrix where the weights are
%between -0.5 and 0.5 (or -0.2 and 0.8)

Weight = Array;
for i = 1:length(Weight(:,1))
    for j = 1:length(Weight(1,:))
        Weight(i,j) = Array(i,j) * (rand - 0.5);
    end
end

%Part C
%Determine the properties of the system. Degree of Distribution is the
%number of connections each vertex has. The mean degree is the mean
%connections that each vertex has. eigen values represent the solutions to
%the adjacency matrix.

degreeOfDistribution = sum(Array);
meanDegree = mean(degreeOfDistribution);

figure(3)
histogram(degreeOfDistribution)
xlabel('Degree of Distribution')
ylabel('Number of Vertices')

eigenValues = eig(double(Array));

%Part D
%Rnadomly select the first 10 neurons that will fire.
for p = 1:10
    index(p) = round(rand*n);
end

%Set up an input array where the values are 0 for most and 1 for the 10
%selected neurons from above.

inputArray = zeros(n,1);
for x=1:10
    inputArray(index(x)) = 1;
end

%Initial state is 0 for all neurons.
V0 = zeros(n,1);

%Part E
%set the system to run for 100 time steps. Do you want plots (yes or no).
%Use Hopf to run the system for the 100 time steps.
ntime = 100;
plots = 'yes';
[Vsave, time] = Hopf(Coordinates', Weight, inputArray, V0, ntime, plots);
