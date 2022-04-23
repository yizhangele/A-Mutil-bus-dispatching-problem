 %30-Jan-2019
% Bus scheduling for a ring route  with receding horizon
% gurobi
% returnHorizon is smaller than each prediction horizon Hp (otherwise, )
% Total simulation time = multiple times * Hp 
%%
clear all;
clc;
warning off;

N_b = 5; % buses number 10
N_s = 25;  % stops number 6 
H_p = 12;  % prediction horizon 12
returnHorizon = 15; % 7

N_odPair = (N_s-1)*N_s/2+N_s-1; 
currentVolume = zeros(N_odPair, 1);
flowIn = zeros(N_odPair*H_p, 1);

%% for initiation

currentVolume = csvread('Instance_matlab.csv');
flowIn = csvread('FlowIn_matlab.csv');

% for i=1:N_odPair
%     currentVolume(i,1) = Instance(i,1); 
%     %currentVolume(i,1) = 10; 
% end
% 
% for i=1:N_odPair*H_p
%     flowIn(i,1) = 10; 
% end


disp('**************START initiation***********************')
	t = 0
	
disp('**************END initiation***********************')

%for t = 1:12

	disp('**************START New***********************')
	disp('**************START New***********************')
	disp('**************START New***********************')
	% ********** CALL THE EXTERNAL CONTROLLER ********* %
         
[telapsed, passdelay, busspace, tripdispatch, tripstop] = Bus_Scheduling(N_b, N_s, H_p, returnHorizon, currentVolume, flowIn)
disp('**************START pre_stages***********************')

result = [telapsed, passdelay, busspace];
csvwrite('result.csv', result);

csvwrite('result_dispatch.csv',tripdispatch);
%csvwrite('result_stop.csv',tripstop);
