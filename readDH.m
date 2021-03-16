function [DHTABLE, DHINFO, Parent, ParentBranch, ItsParent] = readDH(textfile)
global LinkLengths
fileID=fopen(textfile);
datatype = '%s';
TEMP=textscan(fileID,'%s','CommentStyle','#','Delimiter','\t');
fclose(fileID);

BranchType = {'Global', 'Spine', 'Arm', 'Neck', 'Leg'};

nBranch = str2double(TEMP{1,1}(1));
nData = size(TEMP{1,1}(:),1);

% i is branch index; j is tracking index (to sort the data)
j = 2;

for i = 1:nBranch
    k = 0; % k indicates branch type
    while cellfun(@isempty, TEMP{1,1}(j))
        j = j + 1;
    end
    
    tmp = repmat(TEMP{1,1}(j),1,5);
    while k < 5
        % Global: k=1; Spine: k=2; Arm: k=3; Neck:k=4; Leg: k=5;
        k = k + 1;
        if endsWith(tmp{k}, BranchType{k})
            %cellfun(@(b) endsWith(b, BranchType{j}), tmp{j}, 'UniformOutput',false)
            break
        end
    end
    
    parent = str2double(TEMP{1,1}(j+1));
    nTrans = str2double(TEMP{1,1}(j+2));
    nChild = str2double(TEMP{1,1}(j+3));
    j = j + 4;
    if nChild ~= 0
        child = str2double(TEMP{1,1}(j:j+nChild-1));
    else
        child = [];
    end
    j = j+nChild;
    DHINFO{i}= [k, parent, nTrans, nChild, child'];
    
    while (cellfun(@isempty, TEMP{1,1}(j)) || str2double(TEMP{1,1}(j)) == -1)
        j = j + 1;
    end
    DHTABLET = [];
    for ii = 1:nTrans
        DHTable = [];
        for jj = 1:5
%             keyboard
            temp = cell2mat(TEMP{1,1}(j));
            if temp == '*'
                DHTable = [DHTable, 0];
            elseif jj ==3 || jj==4
                LinkNums = strsplit(temp,'&');
                nLinks = 0;
                for iii = 1:size(LinkNums,2)
                    linkNum = str2double(LinkNums{1,iii});
                    if linkNum < 0
                        nLinks = nLinks - LinkLengths(abs(linkNum));
                    elseif linkNum > 0
                        nLinks = nLinks + LinkLengths(linkNum);
                    end
                end
                DHTable = [DHTable, nLinks];
            else
                DHTable = [DHTable, str2double(temp)];
            end
            j = j+1;
        end
        if j <= nData
            check = TEMP{1,1}(j);
        else
            check = {'1'};
        end
        
        while cellfun(@isempty, check)
            j = j + 1; check = TEMP{1,1}(j);
        end
        
        DHTABLET = [DHTABLET; DHTable];
    end
    DHTABLE{i} = DHTABLET;
end

for i = 1:nBranch
    if DHINFO{i}(4) ~= 0
        Temp = DHINFO{i}(5:end)+1;
        Child = [];
        for j = 1:length(Temp)
            if DHINFO{Temp(j)}(4) == 0
                Child = [Child, Temp(j)];
            end
        end
        Parent{i} = [i, DHINFO{i}(2)+1, Child];
    end
    ItsParent(i) = DHINFO{i}(2)+1;
end
ParentBranch= [];
for i = 1:size(Parent,2)
    ParentBranch = [ParentBranch, Parent{i}(1)];
end
end
