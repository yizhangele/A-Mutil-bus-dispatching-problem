function [xtype] = setVarType(N_b, N_s, N_x, N_odPair, N_odPair2, H_p)
%% variables declaration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bus Dispatch Indicator
 x_b = char(66*ones(N_b*H_p, 1));

% Bus Stop Indicator
 Q_b = char(66*ones(N_b*N_s*H_p, 1)); 

% Passenger Volume at each stop 
 P_ij = char(73*ones(N_odPair*(H_p+1), 1));

% Boarding Passengers
 B_bij = char(73*ones(N_odPair*N_b*H_p, 1));
 
% Passenger Volume on each bus
 V_bij = char(73*ones(N_odPair2*N_b*H_p, 1));   

% Auxilary variables
 delta_b = char(66*ones(N_b*N_s*H_p, 1)); 
 
% Alighting Passengers
% A_bi = char(73*ones(N_b*N_s*H_p, 1));   
 
xtype = [x_b; Q_b; P_ij; B_bij; V_bij; delta_b];
end