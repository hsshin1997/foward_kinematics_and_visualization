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
    P.fictitiousOn = false;
end
if ~isfield(P,'is2d')
    P.is2d = true;
end

pack = P; 

% unpack dhinfo to usable form
[BranchType, NumJoints] = unpackDHINFO(P.dhinfo);
nSeg = length(t);

% add width to the 2d data
if P.is2d
%     if P.isStatic
        [JK,CK] = render2D(JK,CK,P,BranchType);
%     else
%         for i = 1:nSeg
%             [JK{i},CK{i}] = render2D(JK{i},CK{i},P,BranchType);
%         end
%     end
end
% determine size of x and xc
x = zeros(3,sum(NumJoints),nSeg);
xc = x;

% pack kinematics data
if P.isStatic
    [x, xc, Order] = packKinematics(JK,CK,P,x,xc);
else
    Order = cell(1,nSeg);
    for i = 1:nSeg
        [x(:,:,i), xc(:,:,i), Order{i}] = ...
            packKinematics(JK{i},CK{i},P,x(:,:,i),xc(:,:,i));
    end
end

% pack other
pack.BranchType = BranchType;
pack.NumJoints = NumJoints;
pack.Order = Order;
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
% divide width by 2 since symmetric
uppW = 0.259 * height / 2; % Upper body
lowW = 0.191 * height / 2; % Lower body
% footW = 0.055 * height;
% footL = 0.152 * height;

if isStatic
    [newJK, newCK] = addWidth(JK,CK,uppW,lowW,BranchType);
else
    newJK = JK; newCK = CK;
    nSeg = length(JK);
    for i = 1:nSeg
        [newJK{i}, newCK{i}] = ...
            addWidth(JK{i},CK{i},uppW,lowW,BranchType);
    end
end

end

function [x, xc, Order] = packKinematics(JK,CK,P,x,xc)
%
%

Parent = P.parent;
dhinfo = P.dhinfo;

nParent = size(Parent, 2);

% flags
count = 1;
rightArm = true;
rightLeg = true;

countO = 1; % index for "Order" array
Order = cell(1,length(dhinfo)+2); % add 2 to connect each shoulders and hips

for i = 1:nParent
    
    bIdx = Parent{i}(1); % Branch index
    ItsChild = Parent{i}(3:end);
    
    for j = [bIdx, ItsChild]
        branchType = dhinfo{j}(1);
        switch branchType
            case 1  % fictitious
                if P.fictitiousOn
                    [xTemp, xcTemp, order, countN] ...
                        = divKinematics(JK{j},CK{j},count);
%                     P0 = xTemp(:,end);
                else
                    nJoints = length(JK{j});
                    countN = count + nJoints;
                    order = count:nJoints;
                    P0 = JK{j}{nJoints};
                    xTemp = repmat(P0,1,nJoints);
                    xcTemp = NaN(3,nJoints);
                end
                pIdx = countN-1;
            case 2  % spine
                [xTemp, xcTemp, orderN, countN] ...
                    = divKinematics(JK{j},CK{j},count);
                order = [pIdx, orderN];
                pIdx = orderN(end);
                
            case 3  % arm
                if rightArm
                    [xTemp, xcTemp, order, countN] ...
                        = divKinematics(JK{j},CK{j},count); 
                    raIdx = order(1);
                    rightArm = false;
                else
                    [xTemp, xcTemp, order, countN] ...
                        = divKinematics(JK{j},CK{j},count);
                    laIdx = order(1);
                end
            case 4  % neck
                [xTemp, xcTemp, orderN, countN] ...
                    = divKinematics(JK{j},CK{j},count);
                order = [pIdx, orderN];
            case 5  % leg
                if rightLeg
                    [xTemp, xcTemp, order, countN] ...
                        = divKinematics(JK{j},CK{j},count); 
                    rlIdx = order(1);
                    rightLeg = false;
                else
                    [xTemp, xcTemp, order, countN] ...
                        = divKinematics(JK{j},CK{j},count);
                    llIdx = order(1);
                end
            otherwise
                
        end
        
        x(:,count:countN-1) = xTemp;
        xc(:,count:countN-1) = xcTemp;
        count = countN;
        
        Order{countO} = order;
        countO = countO + 1;
        
    end
    
end

if exist('rlIdx', 'var')
    Order{countO} = [rlIdx, llIdx];
    Order{countO+1} = [raIdx, laIdx];
end

end

function [x, xc, order, count] = divKinematics(JK,CK,count)
%
%

nJoints = length(JK);
order = zeros(1,nJoints);
x = zeros(3,nJoints);
xc = x;

for i = 1:nJoints
    x(:,i) = JK{i};
    xc(:,i) = CK{i};
    order(i) = count;
    count = count + 1;
end

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

rightArm = true;
rightLeg = true;

for i = 1:length(JK)
    switch BranchType(i)
        case 3 % Arm
            if rightArm
                newJK{i} = addCell(JK{i},PArm);
                newCK{i} = addCell(CK{i},PArm);
                rightArm = false;
            else
                newJK{i} = addCell(JK{i},-PArm);
                newCK{i} = addCell(CK{i},-PArm);
            end
        case 5 % Leg
            if rightLeg
                newJK{i} = addCell(JK{i},PLeg);
                newCK{i} = addCell(CK{i},PLeg);
                rightLeg = false;
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
for i = 1:length(Cell)
    newCell{i} = Cell{i}+vector;
end

end
