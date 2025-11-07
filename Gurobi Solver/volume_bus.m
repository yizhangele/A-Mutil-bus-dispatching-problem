function [A, b] = volume_bus(N_b, N_s, N_x, H_p, N_odPair, N_odPair2)

A = sparse((N_s-1)*N_b*H_p+(N_s-1)*(N_s-1)*H_p*N_b, N_x);
b = zeros((N_s-1)*N_b*H_p+(N_s-1)*(N_s-1)*H_p*N_b, 1);

B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1);
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

%% V_b,i+1,j(k) = V_b,i,j(k) + B_b,i,j(k)
% for bus stop 1
for i=1:N_b
    for k=1:H_p
        for j=1:(N_s-1) % destination stops from stop 2 to stop N_s+1
            A(1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, B_pre+1+(j-1)*1+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = 1;
            A(1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, V_pre+2+(j-1)*1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = 1; 
            A(1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, V_pre+(N_s+1)+1+(j-1)*1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -1;
        end
    end
end

startnew = (N_s-1)*N_b*H_p;
% for bus stop 2 to N_s
for i=1:N_b
    for k=1:H_p
        for m=1:N_s-1 % stop 2 to stop N_s
            for j=1:N_s-m % destination stops: e.g., (stop m for V) stop m+1,...,stop N_s+1
                A(startnew+1+(j-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p, ...
                    B_pre+(N_s-1)+1+(j-1)*1+((m-1)*N_s-(m-1)*m/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = 1;
               % for V_b,i,j(k) 
               if m==1
                    A(startnew+1+(j-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p, ...
                    V_pre+(N_s+1)+2+(j-1)*1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = 1; 
               else
                    A(startnew+1+(j-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p, ...
                    V_pre+(N_s+1)+2+(j-1)*1+((m-1)*N_s-(m-2)*(m-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = 1;
               end
                % for V_b,i+1,j(k)
                A(startnew+1+(j-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1)+(i-1)*(N_s-1)*(N_s-1)*H_p, ...
                V_pre+(2*N_s+1)+1+(j-1)*1+((m-1)*N_s-m*(m-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -1;
               
            end
        end
    end
end