%%  Init
clc
clear all 
close all

addpath('measurementData');
data = load('msrData.mat');
%%
data = data.Data
%%
T = data.Time