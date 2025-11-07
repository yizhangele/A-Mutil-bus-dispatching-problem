function f = linear_objective(N_x, N_s, H_p, N_b,  N_odPair, N_odPair2, hat_B)

f = sparse(1, N_x);

P_pre = N_b*H_p +  N_b*N_s*H_p;
V_pre = N_b*H_p + N_b*N_s*H_p + N_odPair*(H_p+1) + N_odPair*N_b*H_p;

% do not include H_p+1
f(1, P_pre+1:P_pre+N_odPair*H_p) = ones(1, N_odPair*H_p);
% do not include ij when i = N_s+1
for i=1:N_b
    for k =1:H_p
        for j=1:N_s
            if j==1
                f(1, V_pre+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_s+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -ones(1,N_s);
            elseif j==2
                f(1, V_pre+N_s+1+1+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_s+1+N_s+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -ones(1,N_s);
            else
                f(1, V_pre+N_s+1+1+((j-2)*N_s-(j-2)*(j-3)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p:V_pre+N_s+1+N_s-j+2+((j-2)*N_s-(j-2)*(j-3)/2)+(k-1)*N_odPair2+(i-1)*N_odPair2*H_p) = -ones(1,N_s-j+2);
            end
        end
    end
end
% 
% for i=1:N_b
%     for k=1:H_p
%         for i=1:N_s
%             for j=1:(N_s-i+2)
%                 f(1, )
%             end
%         end
%     end
% end