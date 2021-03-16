function [JK, CK, R] = ForwardKinematics(DHTABLE, JV)
% JK is joint kinematics and CK is COM kinematics of each links
switch nargin
    case 2 % JV exists
        [JK, CK, R] = ForwardKinematics_M(DHTABLE, JV);
    case 1 % JV does not exists
        [JK, CK, R] = ForwardKinematics_M(DHTABLE);
end
end
%% Forward Kinematics of multiple branch
function [JK, CK, R] = ForwardKinematics_M(DHTABLE, JV)
global Parent
DH_temp = eye(4);
switch nargin
    case 2
        JV = JV;
    case 1
        for i = 1:size(DHTABLE,2)
            a = DHTABLE{i};
            JV{i} = zeros(1,size(a,1));
        end
end
for i = 1:size(Parent,2)
   bIdx = Parent{i}(1);
   grandparent = Parent{i}(2);
   if grandparent ~= 0
       DH_temp = DH_End{grandparent};
   end
   TEMP = DHTABLE{1,bIdx};
   % Forward Kinematics of Parent Branch
   [DH_End{bIdx}, JK{bIdx}, CK{bIdx}, R{bIdx}] = ...
       ForwardKinematics_S(TEMP,DH_temp,JV{bIdx},bIdx);
   % Forward Kinemeatics of Child Branches
   DH_temp = DH_End{bIdx};
   for j = Parent{i}(3:end)
       TEMP = DHTABLE{1,j};
       [DH_End{j}, JK{j}, CK{j}, R{j}] = ...
           ForwardKinematics_S(TEMP,DH_temp,JV{j},j);
   end
end
end
%% Forward Kinematics of single branch
function [DH_temp, P, P_COM, R_temp] = ...
    ForwardKinematics_S(DH_Matrix,DH_Previous,JV,bIdx)

global MASSDATA
COMIdx = 3:5; DHIdx = 2:5; One2Three = 1:3;
for j = 1:size(DH_Matrix,1)
    DHParameter = DH_Matrix(j, DHIdx);
    if DH_Matrix(j,1) == 0
        DHParameter(1) = DHParameter(1) + JV(j);
    else
        DHParameter(2) = DHParameter(2) + JV(j);
    end
    % DH Transformation Matrix
    ct = cos(DHParameter(1)); ca = cos(DHParameter(4));
    st = sin(DHParameter(1)); sa = sin(DHParameter(4));
    T=[ct,-st*ca,st*sa,DHParameter(3)*ct;
        st,ct*ca,-ct*sa,DHParameter(3)*st;
        0,sa,ca,DHParameter(2);
        0,0,0,1];
    % Joint kinematics w.r.t. global frame
    DH_Previous = DH_Previous*T;
    R_temp{j} = DH_Previous(One2Three,One2Three);
    P{j} = FilterData(DH_Previous(One2Three,4));
    % Link COM kinemeatics w.r.t. global frame
    TEMP = DH_Previous * [MASSDATA{1,bIdx}(j,COMIdx)'; 1];
    P_COM{j} = FilterData(TEMP(One2Three));
end
DH_temp = DH_Previous;
end

%% Filter Data
function Filtered = FilterData(Unfiltered)
    FilterIdx = abs(Unfiltered) <= 1e-10;
    Filtered = Unfiltered;
    Filtered(FilterIdx) = 0;
end