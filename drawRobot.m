function drawRobot(x,xc,p)
%
% This function draws the robot with given state in cartesian space
%
% INPUTS:
%
% OUTPUTS:
%
%
%
%

if p.isStatic
    order = p.Order;
else
    order = p.Order{1};
end
nBranch = length(order);

hold off;

plot3([0,0],[0,0],[0,0]);

% view(0,90);
% xlim([-0.25, 0.25]); 
% ylim([-0.05,0.45]);
% zlim([-0.25, 0.25]);

% view(90,0);
% xlim([-1, 1]); 
% ylim([-0.1,1.9]);
% zlim([-0.6, 1.4]);

view(p.camAng(1),p.camAng(2));
xlim(p.xaxis_limit); 
ylim(p.yaxis_limit);
zlim(p.zaxis_limit);

set(gca,'visible','off')

hold on;

for i = 1:nBranch
    for j = 2:length(order{i})
        if i == 1
            plot3([x(1,order{i}(j-1)),x(1,order{i}(j))], ...
            [x(2,order{i}(j-1)),x(2,order{i}(j))], ...
            [x(3,order{i}(j-1)),x(3,order{i}(j))],...
            p.fictitiousLine ,'LineWidth',2)
        else
            plot3([x(1,order{i}(j-1)),x(1,order{i}(j))], ...
            [x(2,order{i}(j-1)),x(2,order{i}(j))], ...
            [x(3,order{i}(j-1)),x(3,order{i}(j))],...
            '-k','LineWidth',2)
        end
        
    end
end

hold on;

for k = 1:size(xc,2)
    scatter3(x(1,k),x(2,k),x(3,k), 'o','k','filled');
    if p.CoMOn
        scatter3(xc(1,k),xc(2,k),xc(3,k),'o','r','filled');
    end
end

end