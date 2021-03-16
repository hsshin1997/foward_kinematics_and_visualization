function Pos = getPos(linkIdx, JK, Time)

if nargin == 3
    nJoints = length(JK{1}{linkIdx});
    Pos = zeros(length(Time), nJoints*3+1);
    Pos(:,1) = Time;
    for i = 1:length(Time)
        Pos(i,2:end) = cell2array(JK{i}{linkIdx});
    end
    
elseif nargin == 2
    Pos = cell2array(JK{linkIdx});
end

end


%%
function array = cell2array(JK)

nJoints = length(JK);
array = zeros(1,nJoints*3);

k = 1;
for j = 1:nJoints
    array(k:k+2) =  JK{j};
    k = k+3;
end

end