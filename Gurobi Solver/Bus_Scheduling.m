%% Bus Scheduling
function [telapsed, Sum_delay, Sum_busspace, x_b, Q_b] = Bus_Scheduling(N_b, N_s, H_p, returnHorizon, currentVolume, incomPed)
                                                                    
% N_b = 10;                                      % the number of buses 
% N_s = 9;                                       % the number of stops
% H_p = 20;                                       % prediction horizon

N_odPair = (N_s-1)*N_s/2+N_s-1; 
N_odPair2 = (N_s+2)*(N_s+1)/2; 
N_x = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p + N_odPair2*N_b*H_p +N_b*N_s*H_p;

%% Decision Variables

% Bus Dispatch Indicator
% x_b(k)        N_b*H_p

% Bus Stop Indicator
% Q_b,i(k)      N_b*N_s*H_p

% Passenger Volume at each stop 
% P_i,j(k)      N_odPair*(H_p+1)

% Boarding Passengers
% B_b,i,j(k)    N_odPair*N_b*H_p

% Passenger Volume on each bus
% V_b,i,j(k)    N_odPair2*N_b*H_p

% Auxiliary Variables
% delta_b,j(k)  N_b*N_s*H_p

%///////////////no need////////%
% Alighting Passengers
% A_b,i(k)      N_b*N_s*H_p
%///////////////no need////////%

%% parameter setting
%m = 0.01;
M = 7000;
epsilon = 0.0001;
hat_B = 100;
triangle = 10; % trip interval is 10min
DoorOpenTime = 2;
BoardUnitTime = 2;
DwellTime = 180; %3min
AllowedLoadTime = (DwellTime - DoorOpenTime)/BoardUnitTime;
%% constraints formulation
%% inequality constraints
% *********************** %
% bus dipatching rules %  % include non-platoon setting % include re-schedule constraints
% *********************** %
[A1, b1] = dispatch_cons(N_b, N_s, N_x, N_odPair, N_odPair2, H_p, M, returnHorizon);   
% 
% *********************%
% bus stop criterion %
% ******************** %
%[A2, b2] = stop_cons(N_b, N_s, N_x, H_p, N_odPair, N_odPair2, epsilon, M); 
%
% ********************************%
% Boarding passengers constraints %
% ******************************* %
%[A3, b3] = boarding_cons(N_b, N_s,N_x, N_odPair, N_odPair2, H_p, M, hat_B,
%AllowedLoadTime); % matrix zeros()has limit size, so for large scale
%problems, need to be partitioned as two shown below
[A31, b31] = boarding_cons1(N_b, N_s,N_x, N_odPair, N_odPair2, H_p, M, hat_B); 
[A32, b32] = boarding_cons2(N_b, N_s,N_x, N_odPair, N_odPair2, H_p, M, hat_B, AllowedLoadTime);
%
% **************************************** %
% Alighting passengers constriants %
% **************************************** %
% [A4, b4] = alighting_cons(N_b, N_s, H_p, M);

%% equality constriants
% ***************** %
% volume inital %
% ***************** % 
[Aeq1, beq1] = volume_inital(N_b, N_s, N_x, H_p, currentVolume, N_odPair, N_odPair2);
% ********************************** %
% Passenger volume dynamic at stops %
% ********************************** %
[Aeq2, beq2] = volume_stop(N_b, N_s, N_x, H_p, incomPed, N_odPair);
%
% ********************************** %
% Passenger volume dynamic on buses %
% ********************************** %
[Aeq3, beq3] = volume_bus(N_b, N_s, N_x, H_p, N_odPair, N_odPair2);
% 
%% other constraints
% ////////////////////// %
% lower and upper bounds %
% ////////////////////// %
%% lb and ub
lb = zeros(N_x,1);
ub = M*ones(N_x,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% set variable types
[ xtype ] = setVarType(N_b, N_s, N_x, N_odPair, N_odPair2, H_p);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% objective function
f = linear_objective(N_x, N_s, H_p, N_b,  N_odPair, N_odPair2, hat_B); 

%% syntax
% Create OPTI Object
% Opt = opti('f',f,'ineq',A,b,'eq',Aeq,beq,'bounds',lb,ub,'xtype',xtype,'sense',-1)
% opts = optiset('display', 'iter', 'solver', 'CBC')
% % Solve the MILP problem
% [x,fval,exitflag,info] = solve(Opt)
%int = pedestrian_variable_decla(H_p, N_s);                                                                                   % equation (15)

% [x,fval,exitflag,info] = opti_mintprog(f,A,b,Aeq,beq,lb,ub,int)
%[x,fval,exitflag,output]  = cplexmilp(f,A,b,Aeq,beq,[],[],[],lb,ub,[])
%options = cplexoptimset ('MaxTime',);

% with CPLEX
% [x,fval,exitflag,output]  = cplexmiqp(H,f,A,b,Aeq,beq,[],[],[],lb,ub,xtype');
% disp('***************************************************START INNER DISP*******************')
% exitflag
% disp('***************************************************END INNER DISP*******************')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% solver gurobi
disp('**************Solutions from Gurobi***********************')
clear model;
model.obj = full(f);
model.lb = lb;
model.ub = ub;

model.A=[ A1;
		  %A2;
			%A3;
            A31;
            A32;
            Aeq1;
            Aeq2;
            Aeq3;
		];
model.rhs=[ b1;
			%b2;
			  %b3;
              b31;
              b32;
 			beq1;
              beq2;
              beq3;
		];
model.sense=[
			repmat('<',size(A1,1),1);
			%repmat('<',size(A2,1),1);
			%repmat('<',size(A3,1),1);
            repmat('<',size(A31,1),1);
            repmat('<',size(A32,1),1);
			repmat('=',size(Aeq1,1),1);
 			repmat('=',size(Aeq2,1),1);
 			repmat('=',size(Aeq3,1),1);
 			];

gurobi_write(model, 'milp.lp');
model.vtype = xtype;
tstart = tic;
result = gurobi(model);
telapsed = toc(tstart)
out_x = result.objval;
%% vehicle
% % stage_out4 = result.x(N_theta+1:N_theta+4*N_s*H_p)
%  VehFlow = result.x(((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+1:((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+12*N_s*H_p)
%  VehVolume = result.x(1:((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1));
% %% pedestrian
%  stage_out4 = result.x(N_theta+1:N_theta+4*N_s*H_p)
%  N_Volume =((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1);
%  PedFlow = result.x(((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+12*N_s*H_p*4+4*N_s*(H_p+1)+1:((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+12*N_s*H_p*4+4*N_s*(H_p+1)+8*N_s*H_p)
%  PedVolume = result.x(((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+12*N_s*H_p*4+1:((n_v+1)*n_h*2+(n_h+1)*n_v*2)*(H_p+1)+12*N_s*H_p*4+4*N_s*(H_p+1))
% cap_h = result.x(N_Volume+12*N_s*H_p*4+4*N_s*(H_p+1)+8*N_s*H_p+1:N_Volume+12*N_s*H_p*4+4*N_s*(H_p+1)+9*N_s*H_p);
% cap_v = result.x(N_Volume+12*N_s*H_p*4+4*N_s*(H_p+1)+9*N_s*H_p+1:N_Volume+12*N_s*H_p*4+4*N_s*(H_p+1)+10*N_s*H_p);
% 
% cap_h
% cap_v
% % with gurobi
% clear model;
% %model.Q = 0.5*sparse(H);
% model.obj = full(f);
% model.lb = lb;
% model.ub = ub;
% model.A=[Aeq;A];
% model.rhs=[beq;b];
% model.sense=[repmat('=',size(Aeq,1),1);repmat('<',size(A,1),1);];
% gurobi_write(model, 'milp.lp');
% model.vtype = xtype;
% result = gurobi(model);
 x = result.x;

% total = cell(1,40);
% for i =1:40
%       total{i}=zeros(n_v,n_h);
% end
% 
Sum_delay=0;
Sum_busspace = 0;
PassVolume = 0;

  x_b = transpose(reshape(x(1:N_b*H_p, 1), H_p, N_b));  
  Q_b = transpose(reshape(x(1+N_b*H_p:N_b*H_p+N_b*H_p*N_s, 1), H_p, N_b*N_s));
  
  Passenger = x(N_b*H_p+N_b*H_p*N_s+1:N_b*H_p+N_b*H_p*N_s+N_odPair*H_p);
  for i=1:N_odPair*H_p
    Sum_delay = Sum_delay+Passenger(i);
  end
  
  Boarding = x(N_b*H_p+N_b*H_p*N_s+N_odPair*(H_p+1)+1:N_b*H_p+N_b*H_p*N_s+N_odPair*(H_p+1)+N_odPair*H_p*N_b);
  
  BusSpace = x(N_b*H_p+N_b*H_p*N_s+N_odPair*(H_p+1)+N_odPair*H_p*N_b+1:N_b*H_p+N_b*H_p*N_s+N_odPair*(H_p+1)+N_odPair*H_p*N_b+N_odPair2*H_p*N_b); 
  for i=1:N_b
    for k=1:H_p
        for j=1:N_s
            for m=1:(N_s+2-j)
                if j==1
                    PassVolume = PassVolume + BusSpace(m+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p);
                elseif j==2
                    PassVolume = PassVolume + BusSpace(m+N_s+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p);
                else
                    PassVolume = PassVolume + BusSpace(m+N_s+1+((j-2)*N_s-(j-2)*(j-3)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p);
                end
            end
            Sum_busspace = Sum_busspace + hat_B - PassVolume;
            PassVolume = 0;
        end
    end
  end
%  n_current = x(2*N_s*(H_p+1)+1 : 2*N_s*(H_p+1)+ 4*N_s*H_p,1);
% theta_j_current = x(2*N_s*(H_p+1)+4*N_s*H_p+n_v*n_h+1:2*N_s*(H_p+1)+4*N_s*H_p+n_v*n_h+n_v*n_h*H_p,1);  
% capacity_level = x(2*N_s*(H_p+1)+4*N_s*H_p+N_s*(H_p+1)+8*N_s*H_p+1:2*N_s*(H_p+1)+4*N_s*H_p+N_s*(H_p+1)+12*N_s*H_p)
% % delta_current = x(2*N_s*(H_p+1)+5*N_s*H_p+1:2*N_s*(H_p+1)+5*N_s*H_p+3*n_v*n_h*H_p);
% FIN = result.objval;


disp('***************************************************START INNER DISP*******************')
x_b
Q_b
Sum_delay 
Sum_busspace
Boarding 
BusSpace
disp('***************************************************END INNER DISP*******************')
