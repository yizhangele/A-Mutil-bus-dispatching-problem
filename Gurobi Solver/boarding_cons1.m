function[A, b] = boarding_cons1(N_b, N_s, N_x, N_odPair, N_odPair2, H_p, M, hat_B)

%A = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, N_x);
%b = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, 1);
A = zeros(N_b*H_p+(N_s-1)*N_b*H_p, N_x);
b = zeros(N_b*H_p+(N_s-1)*N_b*H_p, 1);

Q_pre = N_b*H_p;
P_pre = Q_pre +  N_b*N_s*H_p;
B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1); % 
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

%% B_b,i,j(k) <= Q_b.i(k)M
% B_pre start from stop 2
%   for i=1:N_b
%       for k=1:H_p
%           for j=1:(N_s-1) % stop 2 to stop N_s (i in B_b,i,j(k))
%             A(1+(j-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p:(N_s-j)+(j-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p,...
%                 B_pre+(N_s-1)+1+((j-1)*(N_s)-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p:...
%                 B_pre+(N_s-1 )+N_s-j+((j-1)*(N_s)-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = eye(N_s-j);
%             A(1+(j-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p:(N_s-j)+(j-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p,...
%                 Q_pre+N_b*H_p+1+(j-1)*N_b*H_p+(k-1)*1+(i-1)*H_p) = -M*ones(N_s-j,1);
%           end
%     end
%   end
%start = (N_s-1)*(N_s-1)*H_p*N_b;
start=0;
%% \sum_{j}B_b,i,j(k) <= C_b - \sum_{j}V_b,i,j(k)
% for bus stop 1
for i=1:N_b
    for k=1:H_p
        A(start+1+(k-1)*1+(i-1)*H_p, B_pre+1+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+N_s-1+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-1);
        A(start+1+(k-1)*1+(i-1)*H_p, V_pre+2+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_s+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-1);
        b(start+1+(k-1)*1+(i-1)*H_p, 1) = hat_B;
    end
end

startnew = start+N_b*H_p;
% for bus stop 2 to N_s
for i=1:N_b
    for k=1:H_p
        for j=1:N_s-1
            A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                B_pre+(N_s-1)+1+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+(N_s-1)+(N_s-j)+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-j);
           if j==1
                A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+2+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+(N_s+1)+(N_s-j+1)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-j);
           else
            A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+2+((j-1)*N_s-(j-2)*(j-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+(N_s+1)+(N_s-j+1)+((j-1)*N_s-(j-2)*(j-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-j);
           end
            b(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, 1) = hat_B;
        end
    end
end

