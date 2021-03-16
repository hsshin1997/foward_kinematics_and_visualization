function Ang = getAng(linkIdx, R, Time)

if nargin == 3
    nJoints = length(R{1}{linkIdx});
    Ang = zeros(length(Time), nJoints*4+1);
    Ang(:,1) = Time;
    for i = 1:length(Time)
        Ang(i,2:end) = cell2array(R{i}{linkIdx});
    end
    
elseif nargin == 2
    Ang = cell2array(R{linkIdx});
end

end


%%
function array = cell2array(R)

nJoints = length(R);
array = zeros(1,nJoints*4);

k = 1;
for j = 1:nJoints
    array(k:k+3) =  rotm2quat(R{j});
    k = k+4;
end

end