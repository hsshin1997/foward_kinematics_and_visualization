function P = P_Joints(JK)
P_0 = JK{1}; P = P_0;
for i_link = 2:size(JK,2)
    P_1 = JK{i_link};
    link_length = norm(P_1 - P_0);
    if link_length ~=0
        P = [P, P_1];
    end
    P_0 = P_1;
end
end