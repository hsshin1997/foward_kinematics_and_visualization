function P_com = CenterOfMass(CK)
global MASSDATA
MP = 0; mass = 0;
for i = 1:size(CK,2)
    TEMP = CK{i}; MASS = MASSDATA{i};
    for j = 1:size(TEMP,2)
        m = MASS(j,2);
        mass = mass + m;
        MP = MP + m*TEMP{j}; 
    end
end
P_com = MP/mass;
end