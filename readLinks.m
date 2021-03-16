function LinkLengths = readLinks(textfile)
fileID=fopen(textfile);
DATA = textscan(fileID, '%s %f','Delimiter','\t','CommentStyle','#');
fclose(fileID);

LinkNumbers1 = DATA{1,1}(2:end);
Temp = DATA{1,2}(2:end);
nLinks = length(LinkNumbers1);
LinkNumbers = zeros(1,nLinks);
LinkLengths = zeros(1,nLinks);

for i = 1:length(LinkNumbers1)
    LinkNumbers1(i) = erase(LinkNumbers1(i), 'L');
    LinkNumbers(i) = str2num(cell2mat(LinkNumbers1(i)));
end
LinkNumbers = transpose(LinkNumbers);

[LinkNumbers, I] = sort(LinkNumbers);

for i = I
    LinkLengths = Temp(i);
end
end