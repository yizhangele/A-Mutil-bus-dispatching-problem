function[A, b] = boarding_cons2(N_b, N_s, N_x, N_odPair, N_odPair2, H_p, M, hat_B, AllowedLoadTime)

%A = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, N_x);
%b = zeros((N_s-1)*(N_s-1)*H_p*N_b+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p+(N_s-1)*(N_s-1)*H_p*N_b+ (N_s-1)*H_p*N_b+(N_s-1)*(N_s-1)*N_b*H_p+N_b*H_p+(N_s-1)*H_p*N_b, 1);
A = zeros((N_s)*(N_s-1)*H_p*N_b/2+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p, N_x);
b = zeros((N_s)*(N_s-1)*H_p*N_b/2+N_b*H_p+(N_s-1)*N_b*H_p+ (N_s-1)*H_p, 1);

Q_pre = N_b*H_p;
P_pre = Q_pre +  N_b*N_s*H_p;
B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1); % 
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

%% B_b,i,j(k) <= Q_b.i(k)M
% % B_pre start from stop 2
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
% start = (N_s-1)*(N_s-1)*H_p*N_b;
%% \sum_{j}B_b,i,j(k) <= C_b - \sum_{j}V_b,i,j(k)
% % for bus stop 1
% for i=1:N_b
%     for k=1:H_p
%         A(start+1+(k-1)*1+(i-1)*H_p, B_pre+1+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+N_s-1+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-1);
%         A(start+1+(k-1)*1+(i-1)*H_p, V_pre+2+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_s+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-1);
%         b(start+1+(k-1)*1+(i-1)*H_p, 1) = hat_B;
%     end
% end
% 
% startnew = start+N_b*H_p;
% % for bus stop 2 to N_s
% for i=1:N_b
%     for k=1:H_p
%         for j=1:N_s-1
%             A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
%                 B_pre+(N_s-1)+1+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+(N_s-1)+(N_s-j)+((j-1)*N_s-j*(j-1)/2)+(k-1)*N_odPair+(i-1)*N_odPair*H_p) = ones(1, N_s-j);
%            if j==1
%                 A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
%                 V_pre+(N_s+1)+2+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+(N_s+1)+(N_s-j+1)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-j);
%            else
%             A(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
%                 V_pre+(N_s+1)+2+((j-1)*N_s-(j-2)*(j-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+(N_s+1)+(N_s-j+1)+((j-1)*N_s-(j-2)*(j-1)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = ones(1, N_s-j);
%            end
%             b(startnew+1+(j-1)*1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, 1) = hat_B;
%         end
%     end
% end
% 
% startnew2 = startnew + (N_s-1)*N_b*H_p;
startnew2 = 0;
%% \sum_{b}B_b,i,j(k) <= P_i,j(k)
% for stop 1
for k=1:H_p
    for i=1:(N_s-1) % stop 1 to other stops
        for j=1:N_b % buses
            A(startnew2+1+(i-1)*1+(k-1)*(N_s-1), B_pre+1+(j-1)*N_odPair*H_p+(i-1)*1+(k-1)*N_odPair) = 1;
        end
            A(startnew2+1+(i-1)*1+(k-1)*(N_s-1), P_pre+1+(i-1)*1+(k-1)*N_odPair) = -1;
    end
end

startnew3 = startnew2 + (N_s-1)*H_p;
% for stop 2 to N_s
for k=1:H_p
    for m=1:(N_s-1) % stop 2 to stop N_s (i in B_b,i,j(k))
        for i=1:(N_s-m) % stop m to other stops (j in B_b,i,j(k))
            for j=1:N_b % buses
                A(startnew3+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), B_pre+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(j-1)*N_odPair*H_p+(k-1)*N_odPair) = 1;
            end
                A(startnew3+1+(i-1)*1+(m-1)*(N_s-1)+(k-1)*(N_s-1)*(N_s-1), P_pre+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(k-1)*N_odPair) = -1;
        end
    end
end

startnew4 = startnew3+ (N_s)*(N_s-1)*H_p*N_b/2;
%% B_b,m,j(k) <= Q_b,j(k)M with (m<j)
% % for stop 1 ?m=1?, j is from 2 to N_s
% for k=1:H_p
%     for j=1:N_b % buses
%         for i=1:(N_s-1) % stop 1 to other stops
%             A(startnew4+1+(i-1)*1+(j-1)*(N_s-1)+(k-1)*(N_s-1)*N_b, B_pre+1+(j-1)*N_odPair*H_p+(i-1)*1+(k-1)*N_odPair) = 1;
%             A(startnew4+1+(i-1)*1+(j-1)*(N_s-1)+(k-1)*(N_s-1)*N_b, Q_pre+N_b*H_p+1+(i-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = -M;
%         end
%     end
% end
% 
   %startnew5 = startnew4 + (N_s-1)*H_p*N_b;
   startnew5 = startnew4;
% % for stop 2 to N_s-1 ((1)m from 2 to N_s-1), where (2) j is from 3 to N_s,
% % (1)since when m == N_s, B_b,m,j = B_b,N_s,N_s+1, the reason is in (2)
% % (2) since N_s+1 is just stop 1, it definitely requires to go back the terminal,
% % so this constraint has no need to be applied to N_s+1 for j in B_b,m,j(k)
% for k=1:H_p
%     for m=1:(N_s-2) % stop 2 to stop N_s-1 (i in B_b,i,j(k))
%         for i=1:(N_s-m-1) % stop m to other stops (j in B_b,i,j(k))
%             for j=1:N_b % buses
%                 A(startnew5+1+(j-1)*1+(i-1)*N_b+(m-1)*(N_s-1)*N_b+(k-1)*(N_s-1)*(N_s-1)*N_b, B_pre+(N_s-1)+1+(i-1)*1+((m-1)*N_s-(m-1)*m/2)+(j-1)*N_odPair*H_p+(k-1)*N_odPair) = 1;
%                 A(startnew5+1+(j-1)*1+(i-1)*N_b+(m-1)*(N_s-1)*N_b+(k-1)*(N_s-1)*(N_s-1)*N_b, Q_pre+(m+1)*N_b*H_p+1+(i-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = -M;
%             end
%         end
%     end
% end

  %startnew6 = startnew5 + (N_s-1)*(N_s-1)*N_b*H_p;
   startnew6 = startnew5;
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


