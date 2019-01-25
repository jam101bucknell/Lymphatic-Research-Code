%% Sheep and Wolves Cellular Automata
% Framework of code was taken by James Baish
% Modified by John Montani on September 25, 2018

clear
clc
close all

%% Setup

% Randomly select the total amount of initial sheep. Maximum could be 75.
numbsheep = rand*75;
nsheep = round(numbsheep);
originalSheep = nsheep;

% Calculate how many male and female sheep
maleSheep = nsheep - round(nsheep/2);
femaleSheep = nsheep - maleSheep;

% Assign genders and generation values to each sheep by creating/using the
% structure sheep. Generation is under sheep.Generation and gender is under
% sheep.Gender. The initial group is part of the original generation
% labelled G.

for isheep = 1:maleSheep
    sheep(isheep).Gender = 'M';
    sheep(isheep).Generation = 'G';
end
for jsheep = 1:femaleSheep
    sheep(maleSheep+jsheep).Gender = 'F';
    sheep(maleSheep+jsheep).Generation = 'G';
end

% Randomly select how many wolves to start off with. Maximum is 50.
numbwolves =  rand * 50;
nwolves = round(numbwolves);

% Select how many male and female wolves there will be.
maleWolves = nwolves - round(nwolves/2);
femaleWolves = nwolves - maleWolves;

% Give each wolf a gender assignment and generation assignment within the
% structure wolves. gender is placed under wolves.Gender and generation is
% under wolves.Generation. The starting wolves are part of the original
% generation labelled G.

for iwolves = 1:maleWolves
    wolves(iwolves).Gender = 'M';
    wolves(iwolves).Generation = 'G';
end
for jwolves = 1:femaleWolves
    wolves(maleWolves+jwolves).Gender = 'F';
    wolves(maleWolves+jwolves).Generation = 'G';
end

% Initialize Parameters
sheepSpeed = 0.02;
wolfSpeed = 0.04;
nstep = 500;
eatinrange = 0.05;
reproducingRange = 0.03;

% Give all the wolves and sheep random initial starting locations. The
% Sheep are more clumped up at the beginning.

for iwolves = 1:nwolves
    wolves(iwolves).x = rand - 0.5;
    wolves(iwolves).y = rand - 0.5;
end
for isheep = 1:nsheep
    sheep(isheep).x = 0.5*rand-0.5;
    sheep(isheep).y = 0.5*rand-0.5;
end

% Establish counter variables to keep track of how long its been since each
% wolf or sheep has mated.
counterfemaleSheep = zeros(femaleSheep*20,1);
countermaleSheep = zeros(maleSheep*20,1);
counterfemaleWolves = zeros(femaleWolves*20,1);
countermaleWolves = zeros(maleWolves*20,1);

% Create variables that will store data within them for each run.
reproductionSheep = 0;
reproductionWolves = 0;
savedEatenSheep = 0;
savedReproductionSheep = 0;
savedReproductionWolves = 0;
herd = nsheep;
pack = nwolves;

%% Cellular Automata Model

istep = 0;

while istep<nstep && nsheep>0
    
    %Since each run goes through every male and female pairing for each
    %species, the reproduction threshold is set to be a constant times the
    %total amount of that species alive at the moment to prevent the wolves and
    %sheep to reproduce at an ever increasing rate.
    
    reproducingTimeLimitWolves = 70*nwolves;
    reproducingTimeLimitSheep = 50*nsheep;
    
    %Set up a ton of variables that will store location data to be used for
    %figures 1 and 2.
    
    xmaleWolves = [];
    ymaleWolves = [];
    xfemaleWolves = [];
    yfemaleWolves = [];
    xmaleSheep = [];
    ymaleSheep = [];
    xfemaleSheep = [];
    yfemaleSheep = [];
    xmaleWolves2 = [];
    ymaleWolves2 = [];
    xfemaleWolves2 = [];
    yfemaleWolves2 = [];
    xmaleSheep2 = [];
    ymaleSheep2 = [];
    xfemaleSheep2 = [];
    yfemaleSheep2 = [];
    newSheepX = [];
    newSheepY = [];
    newWolvesX = [];
    newWolvesY = [];
    istep = istep + 1;
    
    % Find the distances between all wolves and all sheep
    distance = zeros(nwolves,nsheep);
    for iwolves = 1:nwolves
        for jsheep = 1:nsheep
            distance(iwolves,jsheep) = sqrt((wolves(iwolves).x-sheep(jsheep).x).^2 ...
                + (wolves(iwolves).y-sheep(jsheep).y).^2);
        end
    end
    
    % Find the range and identity of each closest sheep
    [rangetonearsheep,nearsheep] = min(distance,[],2);
    
    % For each wolf move toward the closest sheep or eat it if close enough
    wolffood = [];
    for iwolves = 1:nwolves
        if rangetonearsheep < eatinrange % eat nearsheep if not already eaten
            if ~ismember(nearsheep(iwolves),wolffood)
                wolffood = [wolffood,nearsheep(iwolves)];
            end
        else % move toward nearsheep
            % find the unit vector to nearsheep
            ux = (sheep(nearsheep(iwolves)).x-wolves(iwolves).x)/rangetonearsheep(iwolves);
            uy = (sheep(nearsheep(iwolves)).y-wolves(iwolves).y)/rangetonearsheep(iwolves);
            % move
            wolves(iwolves).x = wolves(iwolves).x + wolfSpeed * ux;
            wolves(iwolves).y = wolves(iwolves).y + wolfSpeed * uy;
        end
    end
    
    % Find the range and identity of each closest wolf
    [rangetonearwolf,nearwolf] = min(distance,[],1);
    
    % Move away from the nearest wolf
    for isheep = 1:nsheep
        dx = sheep(isheep).x-wolves(nearwolf(isheep)).x;
        dy = sheep(isheep).y-wolves(nearwolf(isheep)).y;
        ux = dx/rangetonearwolf(isheep);
        uy = dy/rangetonearwolf(isheep);
        sheep(isheep).x = sheep(isheep).x + sheepSpeed*ux;
        sheep(isheep).y = sheep(isheep).y + sheepSpeed*uy;
    end
    
    %Save the new locations of each sheep and wolf to the designated memory
    %variables.
    
    for isheep = 1:nsheep
        if sheep(isheep).Gender == 'M'
            xmaleSheep = cat(1,xmaleSheep,sheep(isheep).x);
            ymaleSheep = cat(1,ymaleSheep,sheep(isheep).y);
        else
            xfemaleSheep = cat(1,xfemaleSheep,sheep(isheep).x);
            yfemaleSheep = cat(1,yfemaleSheep,sheep(isheep).y);
        end
    end
    for iwolves = 1:nwolves
        if wolves(iwolves).Gender == 'M'
            xmaleWolves = cat(1,xmaleWolves,wolves(iwolves).x);
            ymaleWolves = cat(1,ymaleWolves,wolves(iwolves).y);
        else
            xfemaleWolves = cat(1,xfemaleWolves,wolves(iwolves).x);
            yfemaleWolves = cat(1,yfemaleWolves,wolves(iwolves).y);
        end
    end
    
    % Find the distance between each male and female sheep
    distance2 = zeros(length(xmaleSheep),length(xfemaleSheep));
    for isheep = 1:length(xmaleSheep)
        for jsheep = 1:length(xfemaleSheep)
            distance2(isheep,jsheep) = sqrt((xmaleSheep(isheep)-xfemaleSheep(jsheep))^2+...
                + (ymaleSheep(isheep)-yfemaleSheep(jsheep))^2);
        end
    end
    %Find the distance between each male and female wolf
    distance3 = zeros(maleWolves,femaleWolves);
    for iwolves = 1:length(xmaleWolves)
        for jwolves = 1:length(xfemaleWolves)
            distance3(iwolves,jwolves) = sqrt((xmaleWolves(iwolves)-xfemaleWolves(jwolves))^2+...
                + (ymaleWolves(iwolves)-yfemaleWolves(jwolves))^2);
        end
    end
    
    %Set up length variables that establish how many cycles the for loop
    %will run for. This prevents it from having any new sheep alter how
    %many runs it will undergo.
    
    length1 = length(xmaleSheep);
    length2 = length(xfemaleSheep);
    
    %Determine if their are any male and female pairings that could
    %reproduce at the moment. If there are then create a new sheep and
    %randomly select whether it will be a male or female. All new sheep are
    %part of the second generation labelled by S. The new sheep will have
    %the same location as their fathers to start.
    
    for isheep = 1:length1
        for jsheep = 1:length2
            if countermaleSheep(isheep) > reproducingTimeLimitWolves && counterfemaleSheep(jsheep) > reproducingTimeLimitSheep
                if distance2(isheep,jsheep) <= reproducingRange
                    reproductionSheep = reproductionSheep + 1;
                    nsheep = nsheep + 1;
                    reproducingTimeLimitSheep = 30*nsheep;
                    if rand < 0.5
                        maleSheep = maleSheep + 1;
                        sheep(nsheep).Gender = 'M';
                        sheep(nsheep).x = xfemaleSheep(jsheep);
                        sheep(nsheep).y = yfemaleSheep(jsheep);
                        sheep(nsheep).Generation = 'S';
                        xmaleSheep(maleSheep) = xfemaleSheep(jsheep);
                        ymaleSheep(maleSheep) = yfemaleSheep(jsheep);
                        locationNewSheep = [sheep(nsheep).x,sheep(nsheep).y]
                        
                    else
                        femaleSheep = femaleSheep + 1;
                        sheep(nsheep).Gender = 'F';
                        sheep(nsheep).Generation = 'S';
                        xfemaleSheep(femaleSheep) = xfemaleSheep(jsheep);
                        yfemaleSheep(femaleSheep) = yfemaleSheep(jsheep);
                        sheep(nsheep).x = xfemaleSheep(jsheep);
                        sheep(nsheep).y = yfemaleSheep(jsheep);
                        locationNewSheep = [sheep(nsheep).x,sheep(nsheep).y]
                    end
                    counterfemaleSheep(jsheep) = 0;
                    countermaleSheep(isheep) = 0;
                    
                end
            else
                counterfemaleSheep(jsheep) = counterfemaleSheep(jsheep) + 1;
                countermaleSheep(isheep) = countermaleSheep(isheep) + 1;
            end
        end
    end
    
    %Set up length variables that establish how many cycles the for loop
    %will run for. This prevents it from having any new wolves alter how
    %many runs it will undergo.
    
    length1 = length(xmaleWolves);
    length2 = length(xfemaleWolves);
    
    %Determine if their are any male and female pairings that could
    %reproduce at the moment. If there are then create a new wolf and
    %randomly select whether it will be a male or female. All new wolves are
    %part of the second generation labelled by S. The new wolves will have
    %the same location as their fathers to start.
    
    for iwolves = 1:length1
        for jwolves = 1:length2
            if countermaleWolves(iwolves) > reproducingTimeLimitWolves && counterfemaleWolves(jwolves) > reproducingTimeLimitWolves
                if distance3(iwolves,jwolves) <= reproducingRange
                    nwolves = nwolves + 1;
                    reproducingTimeLimitWolves = 30 * nwolves;
                    reproductionWolves = reproductionWolves + 1;
                    if rand < 0.5
                        maleWolves = maleWolves + 1;
                        wolves(nwolves).Gender = 'M';
                        wolves(nwolves).Generation = 'S';
                        xmaleWolves(maleWolves) = xfemaleWolves(jwolves);
                        ymaleWolves(maleWolves) = yfemaleWolves(jwolves);
                        wolves(nwolves).x = xfemaleWolves(jwolves);
                        wolves(nwolves).y = yfemaleWolves(jwolves);
                        locationNewWolf = [ wolves(nwolves).x ,wolves(nwolves).y]
                    else
                        femaleWolves = femaleWolves + 1;
                        wolves(nwolves).Gender = 'F';
                        wolves(nwolves).Generation = 'S';
                        xfemaleWolves(femaleWolves) = xfemaleWolves(jwolves);
                        yfemaleWolves(femaleWolves) = yfemaleWolves(jwolves);
                        wolves(nwolves).x = xfemaleWolves(jwolves);
                        wolves(nwolves).y = yfemaleWolves(jwolves);
                        locationNewWolf = [ wolves(nwolves).x ,wolves(nwolves).y]
                    end
                    counterfemaleWolves(jwolves) = 0;
                    countermaleWolves(iwolves) = 0;
                    
                end
            else
                counterfemaleWolves(jwolves) = counterfemaleWolves(jwolves) + 1;
                countermaleWolves(iwolves) = countermaleWolves(iwolves) + 1;
            end
        end
    end
    
    
    % move sheep randomly
    for isheep = 1:nsheep
        angle = 2*pi*rand;
        sheep(isheep).x = sheep(isheep).x + sheepSpeed*cos(angle)/2;
        sheep(isheep).y = sheep(isheep).y + sheepSpeed*sin(angle)/2;
        if sheep(isheep).x>1;sheep(isheep).x=1;end
        if sheep(isheep).x<-1;sheep(isheep).x=-1;end
        if sheep(isheep).y>1;sheep(isheep).y=1;end
        if sheep(isheep).y<-1;sheep(isheep).y=-1;end
    end
    
    
    % update the flock
    survivors = setdiff([1:nsheep],wolffood);
    nsheep = length(survivors);
    for i = 1:nsheep
        sheep(i).x = sheep(survivors(i)).x;
        sheep(i).y = sheep(survivors(i)).y;
    end
    herd = [herd,nsheep];
    pack = [pack,nwolves];
    
    %Again determine the locations of each male and female sheep/wolf in order
    %to plot both individually in figure 2.
    
    for isheep = 1:nsheep
        if sheep(isheep).Gender == 'M'
            xmaleSheep2 = cat(1,xmaleSheep2,sheep(isheep).x);
            ymaleSheep2 = cat(1,ymaleSheep2,sheep(isheep).y);
        else
            xfemaleSheep2 = cat(1,xfemaleSheep2,sheep(isheep).x);
            yfemaleSheep2 = cat(1,yfemaleSheep2,sheep(isheep).y);
        end
    end
    for iwolves = 1:nwolves
        if wolves(iwolves).Gender == 'M'
            xmaleWolves2 = cat(1,xmaleWolves2,wolves(iwolves).x);
            ymaleWolves2 = cat(1,ymaleWolves2,wolves(iwolves).y);
        else
            xfemaleWolves2 = cat(1,xfemaleWolves2,wolves(iwolves).x);
            yfemaleWolves2 = cat(1,yfemaleWolves2,wolves(iwolves).y);
        end
    end
    
    %Determine the locations of second generation sheep and wolves for
    %figure 1.
    
    for isheep = 1:nsheep
        if sheep(isheep).Generation == 'S'
            newSheepX = cat(1,newSheepX,sheep(isheep).x);
            newSheepY = cat(1,newSheepY,sheep(isheep).y);
        end
    end
    for iwolves = 1:nwolves
        if wolves(iwolves).Generation == 'S'
            newWolvesX = cat(1,newWolvesX,wolves(iwolves).x);
            newWolvesY = cat(1,newWolvesY,wolves(iwolves).y);
        end
    end
    
    %Calculate how many sheep have been eaten and add that value to the
    %memory variable.
    
    eatenSheep = originalSheep + reproductionSheep - nsheep;
    savedEatenSheep = [savedEatenSheep,eatenSheep];
    
    %Save how many sheep/wolves have been produced in total and add those
    %values to their respective memory variables.
    
    savedReproductionSheep = [savedReproductionSheep,reproductionSheep];
    savedReproductionWolves = [savedReproductionWolves,reproductionWolves];
    
    %Plot the location of all sheep and wolves on figure 2. Plot only the
    %locations of second generation wolves and sheep on figure 1.
    
    if reproductionWolves == 0
        if reproductionSheep == 0
            figure(1)
            plot(newWolvesX,newWolvesY,'om',newSheepX,newSheepY,'*c');title('Location of Reproduced Sheep and Wolves')
            axis([-1.5 1.5 -1.5 1.5])
        else
            legend1 = 'Sheep';
            figure(1)
            plot(newWolvesX,newWolvesY,'om',newSheepX,newSheepY,'*c');legend(legend1);title('Location of Reproduced Sheep and Wolves')
            axis([-1.5 1.5 -1.5 1.5])
        end
    else
        legend1 = {'Wolves' , 'Sheep'};
        figure(1)
        plot(newWolvesX,newWolvesY,'om',newSheepX,newSheepY,'*c');legend(legend1);title('Location of Reproduced Sheep and Wolves')
        axis([-1.5 1.5 -1.5 1.5])
    end
    
    if isempty(xmaleSheep) == 1
        if isempty(xfemaleSheep) == 1
            legend2 = {'Male Wolves','Female Wolves'};
        else
            legend2 = {'Male Wolves','Female Wolves','Female Sheep'};          
        end
    else
        legend2 = {'Male Wolves','Female Wolves','Male Sheep','Female Sheep'};      
    end
    
    figure(2)
    plot(xmaleWolves2,ymaleWolves2,'or',xfemaleWolves2,yfemaleWolves2,'ok',xmaleSheep2,ymaleSheep2,'*g',xfemaleSheep2,yfemaleSheep2,'*b');
    legend('Male Wolves','Female Wolves', 'Male Sheep','Female Sheep','Location','northeastoutside');title('Location of Sheep and Wolves')
    axis([-1.5 1.5 -1.5 1.5]);pause(0.1)
    
end

%% Output

%Plot the total numbers of sheep and wolves remaining after each time step in
%a subplot.

figure(3)
subplot(2,1,1)
plot(herd);xlabel('Time Step');ylabel('Number of Remaining Sheep')
subplot(2,1,2)
plot(pack);xlabel('Time Step');ylabel('Number of Wolves')

%Plot the total number of sheep eaten after each time step.

figure(4)
plot(savedEatenSheep)
xlabel('Time Step')
ylabel('Total Number of Sheep Eaten')

%Plot the total number of reproduced sheep and wolves after each time step.

figure(5)
plot(0:istep,savedReproductionSheep,'r',0:istep,savedReproductionWolves,'k')
xlabel('Time Step')
ylabel('Total Reproductions')
legend('Sheep','Wolves')