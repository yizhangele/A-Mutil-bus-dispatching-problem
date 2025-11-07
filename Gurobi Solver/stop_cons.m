function[A, b] = stop_cons(N_b, N_s, N_x, H_p, N_odPair, N_odPair2, epsilon, M)

A = sparse(3*N_b*(N_s-1)*H_p+2*N_b*H_p+2*N_s*N_b*N_b*H_p, N_x);
b = zeros(3*N_b*(N_s-1)*H_p+2*N_b*H_p+2*N_s*N_b*N_b*H_p, 1);

Q_pre = N_b*H_p;
%B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1);
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;
delta_pre = V_pre + N_odPair2*N_b*H_p;

%% \sum_{i} V_b,i,j(k) != 0 --> Q_b,j(k) =1
stopcre = [1 zeros(1,N_b*H_p-1)];
cell = repmat({stopcre},1,N_s-2);
Seg = blkdiag(cell{:});
Seg_new = [Seg zeros(N_s-2,1);zeros(1,N_b*H_p*(N_s-2)) 1];
%% \sum_{i} V_b,i,j(k) != 0 <--> delta_b,j(k) = 1
for i=1:N_b
    for k=1:H_p
        for j=1:(N_s-1)
            if j==1
                A(1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:...
                V_pre+(N_s+1)+(N_s-j)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = [zeros(j-1,N_s-j);eye(N_s-j)];
            else
            A(1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+1+((j-1)*(N_s)-(j-1)*(j-2)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:...
                V_pre+(N_s+1)+(N_s-j)+((j-1)*(N_s)-(j-1)*(j-2)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = [zeros(j-1,N_s-j);eye(N_s-j)];
            end
            %%%start from stop 2, so add (N_s+1), stop 1 and stop N_s+1 (sink stop, namely stop 1) have no need to be determined, they must stop there
        end
        A(1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p,...
            delta_pre+ N_b*H_p+1+(k-1)*1+(i-1)*H_p:delta_pre+ N_b*H_p+(N_s-2)*N_b*H_p+1+(k-1)*1+(i-1)*H_p) = ...
            A(1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p,...
            delta_pre+ N_b*H_p+1+(k-1)*1+(i-1)*H_p:delta_pre+ N_b*H_p+(N_s-2)*N_b*H_p+1+(k-1)*1+(i-1)*H_p)-M*Seg_new;
        %%%start from stop 2, so add (N_b*H_p)
    end
end

for i=1:N_b
    for k=1:H_p
        for j=1:(N_s-1)
            if j==1
                A(N_b*(N_s-1)*H_p+1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:N_b*(N_s-1)*H_p+(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:...
                V_pre+(N_s+1)+(N_s-j)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -[zeros(j-1,N_s-j);eye(N_s-j)];
            else
            A(N_b*(N_s-1)*H_p+1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:N_b*(N_s-1)*H_p+(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p, ...
                V_pre+(N_s+1)+1+((j-1)*(N_s)-(j-1)*(j-2)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:...
                V_pre+(N_s+1)+(N_s-j)+((j-1)*(N_s)-(j-1)*(j-2)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -[zeros(j-1,N_s-j);eye(N_s-j)];
            end
            %%%start from stop 2, so add (N_s+1), stop 1 and stop N_s+1 (sink stop, namely stop 1) have no need to be determined, they must stop there
        end
        A(N_b*(N_s-1)*H_p+1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:N_b*(N_s-1)*H_p+(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p,...
            delta_pre+ N_b*H_p+1+(k-1)*1+(i-1)*H_p:delta_pre+ N_b*H_p+(N_s-2)*N_b*H_p+1+(k-1)*1+(i-1)*H_p) = ...
            A(N_b*(N_s-1)*H_p+1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:N_b*(N_s-1)*H_p+(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p,...
            delta_pre+ N_b*H_p+1+(k-1)*1+(i-1)*H_p:delta_pre+ N_b*H_p+(N_s-2)*N_b*H_p+1+(k-1)*1+(i-1)*H_p) + M*Seg_new;
        %%%%start from stop 2, so add (N_b*H_p)
        b(N_b*(N_s-1)*H_p+1+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p:N_b*(N_s-1)*H_p+(N_s-1)+(k-1)*(N_s-1)+(i-1)*(N_s-1)*H_p,1)=...
            -epsilon+M;
    end
end


% delta_b,j(k) = 1 --> Q_b,j(k) =1
A(2*N_b*(N_s-1)*H_p+1:2*N_b*(N_s-1)*H_p+N_b*(N_s-1)*H_p,Q_pre+N_b*H_p+1:Q_pre+N_b*H_p*N_s) = -eye(N_b*(N_s-1)*H_p);
A(2*N_b*(N_s-1)*H_p+1:2*N_b*(N_s-1)*H_p+N_b*(N_s-1)*H_p,delta_pre+N_b*H_p+1:delta_pre+N_b*H_p*N_s) = M*eye(N_b*(N_s-1)*H_p);
b(2*N_b*(N_s-1)*H_p+1:2*N_b*(N_s-1)*H_p+N_b*(N_s-1)*H_p,1) = (M-1)*ones(N_b*(N_s-1)*H_p,1);

%% x_b(k)=1 --> Q_b,1(k)=1
A(3*N_b*(N_s-1)*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p, Q_pre+1:Q_pre+N_b*H_p) = -eye(N_b*H_p);
A(3*N_b*(N_s-1)*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p, 1:N_b*H_p) = M*eye(N_b*H_p);
b(3*N_b*(N_s-1)*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p, 1) = (M-1)*ones(N_b*H_p,1);

A(3*N_b*(N_s-1)*H_p+N_b*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p+N_b*H_p, Q_pre+1:Q_pre+N_b*H_p) = eye(N_b*H_p);
A(3*N_b*(N_s-1)*H_p+N_b*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p+N_b*H_p, 1:N_b*H_p) = M*eye(N_b*H_p);
b(3*N_b*(N_s-1)*H_p+N_b*H_p+1:3*N_b*(N_s-1)*H_p+N_b*H_p+N_b*H_p, 1) = (M+1)*ones(N_b*H_p,1);
% 
start = 3*N_b*(N_s-1)*H_p+2*N_b*H_p;
%% x_b'(k)=1 and Q_b,i(k)=1 --> Q_b',i(k)=1
for k=1:H_p % trips
    for i=1:N_b  % any bus b
        for j=1:N_b % other buses b' dispatched in the same trip
            for m=1:(N_s) % stops
%                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     1+(i-1)*H_p+(k-1)*1) = M; % x_b(k)
                A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    Q_pre+1+(m-1)*N_b*H_p+(i-1)*H_p+(k-1)*1)=M; % Q_b,i(k)
                A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    1+(j-1)*H_p+(k-1)*1) = M; % x_b'(k)
                A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    Q_pre+1+(m-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = -1; % Q_b'(k)
                b(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,1) = 2*M-1;
            end
        end
    end
end

start2 = 3*N_b*(N_s-1)*H_p+2*N_b*H_p+N_s*N_b*N_b*H_p;

for k=1:H_p % trips
    for i=1:N_b  % any bus b
        for j=1:N_b % other buses b' dispatched in the same trip
            for m=1:(N_s) % stops
%                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     1+(i-1)*H_p+(k-1)*1) = M; % x_b(k)
                A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    1+(j-1)*H_p+(k-1)*1) = M; % x_b'(k)
                A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    Q_pre+1+(m-1)*N_b*H_p+(i-1)*H_p+(k-1)*1)= M; % Q_b,i(k)
                A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
                    Q_pre+1+(m-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = 1; % Q_b'(k)
                b(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,1) = 2*M+1;
            end
        end
    end
end

% for k=1:H_p % trips
%     for i=1:N_b  % front bus
%         for j=i+1:N_b % buses behind
%             for m=1:(N_s) % stops
% %                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
% %                     1+(i-1)*H_p+(k-1)*1) = M; % x_b(k)
%                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     Q_pre+1+(m-1)*N_b*H_p+(i-1)*H_p+(k-1)*1)=M; % Q_b,i(k)
%                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     1+(j-1)*H_p+(k-1)*1) = M; % x_b'(k)
%                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     Q_pre+1+(m-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = -1; % Q_b'(k)
%                 b(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,1) = 2*M-1;
%             end
%         end
%     end
% end
% 
% start2 = 3*N_b*(N_s-1)*H_p+2*N_b*H_p+N_s*N_b*N_b*H_p;
% 
% for k=1:H_p % trips
%     for i=1:N_b  % front bus
%         for j=i+1:N_b % buses behind
%             for m=1:(N_s) % stops
% %                 A(start+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
% %                     1+(i-1)*H_p+(k-1)*1) = M; % x_b(k)
%                 A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     1+(j-1)*H_p+(k-1)*1) = M; % x_b'(k)
%                 A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     Q_pre+1+(m-1)*N_b*H_p+(i-1)*H_p+(k-1)*1)= M; % Q_b,i(k)
%                 A(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,...
%                     Q_pre+1+(m-1)*N_b*H_p+(j-1)*H_p+(k-1)*1) = 1; % Q_b'(k)
%                 b(start2+1+(m-1)*1+(j-1)*N_s+(i-1)*N_s*N_b+(k-1)*N_s*N_b*N_b,1) = 2*M+1;
%             end
%         end
%     end
% end