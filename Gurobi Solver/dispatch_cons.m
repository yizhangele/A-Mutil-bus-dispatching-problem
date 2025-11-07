function[A, b] = dispatch_cons(N_b, N_s, N_x, N_odPair, N_odPair2, H_p, M, returnHorizon)

A = sparse(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+H_p*N_b+H_p, N_x);
b = zeros(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+H_p*N_b+H_p, 1);

Q_pre = N_b*H_p;
B_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1);
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

%% x_b(k)=0 --> Q_b,i(k)=0
% for j=1:N_s
%     A(1+(j-1)*N_b*H_p:j*N_b*H_p, 1:N_b*H_p) = -M*eye(N_b*H_p);
%     A(1+(j-1)*N_b*H_p:j*N_b*H_p, Q_pre+(j-1)*N_b*H_p+1:Q_pre+(j-1)*N_b*H_p+N_b*H_p) = eye(N_b*H_p);
% end
%% x_b(k)=0 --> B_b,i,j(k)=0
for i=1:N_b
    for k=1:H_p
        A(N_s*N_b*H_p+(k-1)*N_odPair+(i-1)*N_odPair*H_p+1:N_s*N_b*H_p+(k-1)*N_odPair+(i-1)*N_odPair*H_p+N_odPair, ...
            1+(k-1)*1+(i-1)*H_p)= -M*ones(N_odPair,1);
        A(N_s*N_b*H_p+(k-1)*N_odPair+(i-1)*N_odPair*H_p+1:N_s*N_b*H_p+(k-1)*N_odPair+(i-1)*N_odPair*H_p+N_odPair, ...
            B_pre+1+(k-1)*N_odPair+(i-1)*N_odPair*H_p:B_pre+N_odPair+(k-1)*N_odPair+(i-1)*N_odPair*H_p)= eye(N_odPair);
    end
end
%% x_b(k)=0 --> V_b,i,j(k)=0
for i=1:N_b
    for k=1:H_p
        A(N_s*N_b*H_p+N_odPair*H_p*N_b+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+1:N_s*N_b*H_p+N_odPair*H_p*N_b+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+N_odPair2, ...
            1+(k-1)*1+(i-1)*H_p)= -M*ones(N_odPair2,1);
        A(N_s*N_b*H_p+N_odPair*H_p*N_b+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+1:N_s*N_b*H_p+N_odPair*H_p*N_b+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p+N_odPair2, ...
            V_pre+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_odPair2+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p)= eye(N_odPair2);
    end
end
% %% x_b(k)=0 --> A_b,i(k)=0
% for i=1:N_b
%     for k=1:H_p
%         A(N_s*N_b*H_p+2*N_odPair*H_p*N_b+(k-1)*N_s+(i-1)*N_s*H_p+1:N_s*N_b*H_p+2*N_odPair*H_p*N_b+(k-1)*N_s+(i-1)*N_s*H_p+N_s, ...
%             1+(k-1)*1+(i-1)*H_p)= -M*ones(1,N_s);
%         A(N_s*N_b*H_p+2*N_odPair*H_p*N_b+(k-1)*N_s+(i-1)*N_s*H_p+1:N_s*N_b*H_p+2*N_odPair*H_p*N_b+(k-1)*N_s+(i-1)*N_s*H_p+N_s, ...
%             A_pre+1+(k-1)*N_s+(i-1)*N_s*H_p:A_pre+N_odPair+(k-1)*N_s+(i-1)*N_s*H_p)= eye(N_s);
%     end
% end
%% x_b(k)=1 --> \sum_{i=1}^{N_s-1} x_b(k+i)=0
for i=1:N_b
    for k=1:(H_p-1)
        A(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+(k-1)*1+(i-1)*H_p+1, 1+(k-1)*1+(i-1)*H_p)= M;
        if k<=(H_p-returnHorizon+1)
            A(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+(k-1)*1+(i-1)*H_p+1, 2+(k-1)*1+(i-1)*H_p:returnHorizon+(k-1)*1+(i-1)*H_p)= ones(1,returnHorizon-1);
        else 
            A(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+(k-1)*1+(i-1)*H_p+1, 2+(k-1)*1+(i-1)*H_p:H_p+(i-1)*H_p)= ones(1,H_p-k);  
        end
        b(N_s*N_b*H_p+N_odPair*H_p*N_b+N_odPair2*H_p*N_b+(k-1)*1+(i-1)*H_p+1, 1)=M;
    end
end

%% for non-platoon case
% busline = [1 zeros(1, H_p-1)];
% segment = zeros(1,(N_b-1)*H_p+1);
% for i=1:(N_b-1)
%     segment(1,1+(i-1)*H_p:i*H_p)=busline;
% end
% 
% segment(1,(N_b-1)*H_p+1)=1;
% 
% start = N_odPair+(N_s+2)*H_p*N_b;
% for k=1:H_p
%     if k==1
%         A(start+k, 1:N_b*H_p)= [segment zeros(1,H_p-1)];
%     else
%         A(start+k, 1:N_b*H_p) = [zeros(1,k-1) segment zeros(1,H_p-k)];
%     end
%     b(start+k, 1)=1;
% end
end