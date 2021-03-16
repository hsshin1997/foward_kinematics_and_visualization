function [JV,Time] = readJV(textfile, ParentBranch, ItsParent)
global DHINFO
fileID=textfile;
TEMP=xlsread(fileID);

Time = TEMP(:,1);

for ii = 1:size(TEMP,1)
    JVT = []; k = 2;
    for i = 1:size(DHINFO,2)
        nTrans = DHINFO{i}(3); Temp = [];
        isParent = any(ParentBranch == i);
        
        if isParent
            for j = 1:nTrans
                Temp = [Temp, TEMP(ii,k)];
                k = k+1;
            end
            Temp1(i) = TEMP(ii,k);
        else
            Temp = [Temp1(ItsParent(i)), Temp];
            for j = 1:nTrans-1
                k = k + 1;
                Temp = [Temp, TEMP(ii,k)];
            end
        end
        JVT{i} = Temp;
    end
    JV{ii} = JVT;
end
end