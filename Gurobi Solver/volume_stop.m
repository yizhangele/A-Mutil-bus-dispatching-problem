function [A, b] = volume_stop(N_b, N_s, N_x, H_p, incomPed, N_odPair)

A = sparse((N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p, N_x);
b = zeros((N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p, 1);

Q_pre = N_b*H_p;
P_pre = Q_pre +  N_b*N_s*H_p;
B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1);

%% P_i,j(k+1) = P_i,j(k) + f_i,j(k) - \sum_{b} B_b,i,j(k) 
% for stop 1
for k=1:H_p
    for i=1:(N_s-1) % from stop 2 to stop N_s
        for j=1:N_b % buses
            A(1+(i-1)*1+(k-1)*(N_s-1), B_pre+1+(j-1)*N_odPair*H_p+(i-1)*1+(k-1)*N_odPair) = 1;
        end
            A(1+(i-1)*1+(k-1)*(N_s-1), P_pre+1+(i-1)*1+(k-1)*N_odPair) = -1;
            A(1+(i-1)*1+(k-1)*(N_s-1), P_pre+N_odPair+1+(i-1)*1+(k-1)*N_odPair) = 1;
            b(1+(i-1)*1+(k-1)*(N_s-1), 1) = incomPed(i+(k-1)*N_odPair);
    end
end

startnew = (N_s-1)*H_p;
% for stop 2 to N_s
for k=1:H_p
    for m=1:(N_s-1) % stop 2 to stop N_s
        for i=1:(N_s-m) % stop m to other stops
            for j=1:N_b % buses
                A(startnew+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), B_pre+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(j-1)*N_odPair*H_p+(k-1)*N_odPair) = 1;
            end
                A(startnew+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), P_pre+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(k-1)*N_odPair) = -1;
                A(startnew+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), P_pre+N_odPair+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(k-1)*N_odPair) = 1;
                b(startnew+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), 1) = incomPed(N_s-1+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(k-1)*N_odPair,1);
        end
    end
end


