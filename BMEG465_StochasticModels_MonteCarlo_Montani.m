%% Estimating Areas
%Written by John Montani 10/14/2018

clear 
clc
close all

%Part A
%Select a sample size
n=1000000;

%Give each sample and x,y,and z dimension
x=rand(1,n);
y=rand(1,n);
z=rand(1,n);

%determine the squared radius for these samples
r2=x.^2+y.^2+z.^2;

%The area is the total number of points that have a radius squared less
%than one times 8 (8 octants) divided by the total samples.
A=8*sum(r2<1)/n;

%Part B
%Determine the size of the sample
n2=1000000;

%Give each sample six dimensional values
x2=rand(1,n2);
y2=rand(1,n2);
z2=rand(1,n2);
q=rand(1,n2);
p=rand(1,n2);
m=rand(1,n2);

%Determine the squared radius for each point
r2_2=x2.^2+y2.^2+z2.^2+q.^2+p.^2+m.^2;

%The area is the total number of points that have a radius squared less
%than one times 64 (64 sections) divided by the total samples.
A2=64*sum(r2_2<1)/n2;

%Part C
%The approzimations will become more accurate as the sample size increases.
%This is due to the standard deviation decreasing in the system as the
%values localize more into the desired region.


