function[A, b] = volume_inital(N_b, N_s, N_x, H_p, currentVolume, N_odPair, N_odPair2)

A = sparse(N_odPair+(N_s+2)*H_p*N_b, N_x);
b = zeros(N_odPair+(N_s+2)*H_p*N_b, 1);

P_pre = N_b*H_p + N_b*N_s*H_p;
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

%% for stop demands when k=1
A(1:N_odPair, P_pre+1:P_pre+N_odPair) = eye(N_odPair);
b(1:N_odPair, 1) = currentVolume;

%% for bus demand at stop 1 (just dispatched buses)
for i=1:N_b
    for k=1:H_p
        A(N_odPair+(k-1)*(N_s+2)+(i-1)*(N_s+2)*H_p+1:N_odPair+(k-1)*(N_s+2)+(i-1)*(N_s+2)*H_p+N_s+1, ...
            V_pre+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+1:V_pre+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+N_s+1) = eye(N_s+1);
        A(N_odPair+(k-1)*(N_s+2)+(i-1)*(N_s+2)*H_p+N_s+2,V_pre+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+2*N_s+1) = 1;
    end
end

