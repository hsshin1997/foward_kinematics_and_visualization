function [x,xc,t,pack] = packFK(JK,CK,P,Time)
%
% This function collapse all joint kinematics in different branch into a
% single vector, which will be used for animation
%
% INPUTS:
%   JK = {1,i}{1,N} cell of joint kinematics in cartesian space
%   CK = {1,i}{1,N} cell of com kinematics in cartesian space
%   P = robot paramters
%       .dhinfo = {1,N} [branch type, parents branch, # of transformation,
%       its child index]
%       .parent = {1,M} [parent idx, its parent idx, its child idx who do
%       not become parents]
%       .fictitousOn = set to true to include fictitious branch in the
%       animation. Default = False.
%       .is2d = logical value. Default = True
%       .height = scalar value.
%       .isStatic = logical value; true if static motion.
%   Time = [1,N] vector of times; must be monotonic: t(k) < t(k+1).
%
%   N = number of branch
%   M = number of parent
%   i = number of segments
%
% OUTPUTS:
%   x =
%   xc =
%   t =
%   pack =

% Input check:
if nargin < 3
    % Must have JK, CK, P in order to generate animation points
    error("Number of inputs must be greater than 3!")
elseif nargin == 3
    % Time is not necessary. Sometimes, the code is used to check home
    % configuration or different configuration with different joint angle
    % inputs
    t = 0;
else
    t = Time;
end

% struct default setting
if ~isfield(P,'fictitiousOn')
    P.fictitiousOn = False;
end
if ~isfield(P,'is2d')
    P.is2d = True;
end

% unpack dhinfo to usable form
[BranchType, NumJoints] = unpackDHINFO(P.dhinfo);
nSeg = length(t);

% add width to the 2d data
if P.is2d
    [JK,CK] = render2D(JK,CK,P,BranchType);
end

% determine size of x and xc
x = zeros(3,sum(NumJoints),nSeg);
xc = x;

% pack kinematics data
if P.isStatic
    [x, xc] = packKinematics(JK,CK,P,x,xc);
else
    for i = 1:nSeg
        [x(:,:,i), xc(:,:,i)] = ...
            packKinematics(JK{i},CK{i},P,x(:,:,i),xc(:,:,i));
    end
end
    
% pack other
pack.BranchType = BranchType;
pack.NumJoints = NumJoints;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                             SUB FUNCTIONS                               %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [BranchType, NumJoints] = unpackDHINFO(dhinfo)
%
% This function is to pack dhinfo into usable form

nBranch = length(dhinfo);
BranchType = zeros(1,nBranch);
NumJoints = zeros(1,nBranch); % number of joints in each branch

for i = 1:nBranch
    BranchType(i) = dhinfo{i}(1);
    NumJoints(i) = dhinfo{i}(3);
end

end

function [newJK, newCK] = render2D(JK,CK,P,BranchType)
%
% This function is to render 2D data into 3D for animation purpose.

height = P.height;
isStatic = P.isStatic;

% W = width; L = Length;
uppW = 0.259 * height; % Upper body
lowW = 0.191 * height; % Lower body
% footW = 0.055 * height;
% footL = 0.152 * height;

if isStatic
    [newJK, newCK] = addWidth(JK,CK,uppW,lowW,BranchType);
else
    newJK = JK; newCK = CK;
    nSeg = length(JK);
    for i = 1:nSeg
        % divide width by 2 since symmetric
        [newJK{i}, newCK{i}] = ...
            addWidth(JK{i},CK{i},uppW/2,lowW/2,BranchType);
    end
end

end

function [x, xc] = packKinematics(JK,CK,P,x,xc)
%
%

Parent = P.parent;
dhinfo = P.dhinfo;

nParent = size(Parent, 2);

% flags
count = 1;
flagArm = True;
flagLeg = True;

P0 = [0;0;0];

for i = 1:nParent
    
    bIdx = Parent{i}(1); % Branch index
    ItsChild = Parent{i}(3:end);
    
    for j = [bIdx, ItsChild]
        
        branchType = dhinfo{j}(1);
        switch branchType
            case 1  % fictitious 
                if P.fictitiousOn
                    x(:,count) = JK{j}
                else
                    
                end
            case 2  % spine
                
            case 3  % arm
                if flagArm
                    
                else
                    
                end
            case 4  % neck
                
            case 5  % leg
                
        end
        count = count + 1;
    end
    
end

end

function [x, xc, order, count] = divKinematics(JK,CK,count)
%
%

for length(

end
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                             HELP FUNCTIONS                              %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [newJK, newCK] = addWidth(JK,CK,uppW,lowW,BranchType)
%
% This function adds with to 2D system that does not have any width

newJK = JK;
newCK = CK;

PArm = [0;0;uppW];
PLeg = [0;0;lowW];

rightArm = True;
rightLeg = True;

for i = 1:length(JK)
    switch BranchType
        case 3 % Arm
            if rightArm
                newJK{i} = addCell(JK{i},PArm);
                newCK{i} = addCell(CK{i},PArm);
                rightArm = False;
            else
                newJK{i} = addCell(JK{i},-PArm);
                newCK{i} = addCell(CK{i},-PArm);
            end
        case 5 % Leg
            if rightLeg
                newJK{i} = addCell(JK{i},PLeg);
                newCK{i} = addCell(CK{i},PLeg);
                rightLeg = False;
            else
                newJK{i} = addCell(JK{i},-PLeg);
                newCK{i} = addCell(CK{i},-PLeg);
            end
    end
end
end

function newCell = addCell(Cell, vector)
%
% This function is to add vector to cell

newCell = Cell;
for i = length(Cell)
    newCell{i} = Cell{i}+vector;
end

end
