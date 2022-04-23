function[A, b] = boarding_cons3(N_b, N_s, N_x, N_odPair, N_odPair2, H_p, M, hat_B, AllowedLoadTime)

%A = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, N_x);
%b = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, 1);
A = zeros(N_b*H_p+(N_s-1)*N_b*H_p, N_x);
b = zeros(N_b*H_p+(N_s-1)*N_b*H_p, 1);

Q_pre = N_b*H_p;
P_pre = Q_pre +  N_b*N_s*H_p;
B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1); % 
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;
startnew6 = 0;
%% \sum_{j}B_b,i,j(k) <= AllowedLoadTime
% for bus stop 1
for i=1:N_b
    for k=1:H_p
        A(startnew6+1+(k-1)*1+(i-1)*H_p, B_pre+1+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+N_s-1+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-1);
        b(startnew6+1+(k-1)*1+(i-1)*H_p, 1) = AllowedLoadTime;
    end
end

startnew7 = startnew6+N_b*H_p;
% for bus stop 2 to N_s
for i=1:N_b
    for k=1:H_p
        for j=1:N_s-1
            A(startnew7+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                B_pre+(N_s-1)+1+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+(N_s-1)+(N_s-j)+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-j);
            b(startnew7+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, 1) = AllowedLoadTime;
        end
    end
end
