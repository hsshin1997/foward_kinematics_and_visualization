function MASSDATA = readMass(textfile)
fileID=fopen(textfile);
DATA=textscan(fileID,'%f%f%f%f%f%f%f%f%f%f%f','Delimiter','\t','CommentStyle','#');
fclose(fileID);


tIdx = 0; bIdx =1;
for i = 1:size(DATA{1,1},1)
    trigger = DATA{1,1}(i);
    if trigger-tIdx ==1
        tIdx = tIdx + 1;
    else
        tIdx = 1; bIdx = bIdx + 1;
    end
    for j = 1:size(DATA,2)
        MASSDATA{bIdx}(tIdx,j) = DATA{1,j}(i);
    end
end
end