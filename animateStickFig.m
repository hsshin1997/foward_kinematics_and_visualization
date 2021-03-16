function animateStickFig(t,p,pc,param)
% animateStickFig(t,x,P)
%
% FUNCTION:
%   animateStickFig is used to animate a stick figure system with the state
%   x at the times in t.
%
% INPUTS:
%   t = [1xM] vectors of times. Must be monotonic: t(k) < t(k+1)
%   x = [NxM] matrix of states, corresponding to times in t
%   P = animation parameter struct, with fields:
%       .plotFunc = @(t,x) = function handle to create a plot
%           t = a scalar time
%           x = [Nx1] state vector
%       .speed = scalar multiple of time, for playback speed
%       .figNum = (optional) figure number for plotting. Default = 1000.
%       .verbose = set to false to prevent printing details. Default =
%       true;
%
% OUTPUTS:
%   Animation based on data in t and x
%
% NOTES:

if ~isfield(param,'figNum')
    param.figNum = 1000;
end
if ~isfield(param,'verbose')
    param.verbose = true;
end
if ~isfield(param,'frameRate')
    param.frameRate = 10;
end

% Animation call-back variables:
IS_PAUSED = false;
VERBOSE = param.verbose;
SPEED = param.speed;
QUIT = false;
START_TIME = t(1);
SIM_TIME = START_TIME;

% Set up the figure,
fig = figure(param.figNum); clf(fig);
set(fig,'KeyPressFcn',@keyDownListener)
view(180,-90);
tic;
timeBuffer(1:3) = toc;

x = reshape(p(1,:,:),[size(p,2),size(p,3)]);
y = reshape(p(2,:,:),[size(p,2),size(p,3)]);
z = reshape(p(3,:,:),[size(p,2),size(p,3)]);
xc = reshape(pc(1,:,:),[size(pc,2),size(pc,3)]);
yc = reshape(pc(2,:,:),[size(pc,2),size(pc,3)]);
zc = reshape(pc(3,:,:),[size(pc,2),size(pc,3)]);

myVideo = VideoWriter('myVideoFile'); %open video file
myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
open(myVideo)

for i = 1:length(t)
    xNow = x(:,i); yNow = y(:,i); zNow = z(:,i);
    xcNow = xc(:,i); ycNow = yc(:,i); zcNow = zc(:,i);
    feval(param.plotFunc,t(i),[xNow';yNow';zNow'],[xcNow';ycNow';zcNow']);
    drawnow;
    pause(0.1);  
    frame = getframe(gcf); %get frame
    writeVideo(myVideo, frame);
end
close(myVideo)

% while SIM_TIME < t(end)
%     xNow = interp1(t',x',SIM_TIME,'linear','extrap');
%     xcNow = interp1(t',xc',SIM_TIME,'linear','extrap');
%     yNow = interp1(t',y',SIM_TIME,'linear','extrap');
%     ycNow = interp1(t',yc',SIM_TIME,'linear','extrap');
%     zNow = interp1(t',z',SIM_TIME,'linear','extrap');
%     zcNow = interp1(t',zc',SIM_TIME,'linear','extrap');
%     keyboard; 
%     %Call the plot command
%     feval(param.plotFunc,SIM_TIME,[xNow;yNow;zNow],[xcNow;ycNow;zcNow]);
%     drawnow;
%     pause(0.005);  
%     
%     %Set up targets for timing
%     dtReal = 0.5*(timeBuffer(1) - timeBuffer(3));
%     if IS_PAUSED
%         dtSim = 0;
%     else
%         dtSim = SPEED*dtReal;
%     end
%     SIM_TIME = SIM_TIME + dtSim;
%     
%     %Record the frame rate:
%     timeBuffer(3) = timeBuffer(2);
%     timeBuffer(2) = timeBuffer(1);
%     timeBuffer(1) = toc;
%     
%     % Check exit conditions:
%     if QUIT
%         break
%     end
%     
% end
% %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% %                   Graphics call-back functions                          %
% %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% 
% 
%     function keyDownListener(~,event)
%         switch event.Key
%             case 'space'
%                 IS_PAUSED = ~IS_PAUSED;
%                 if VERBOSE
%                     if IS_PAUSED
%                         fprintf('--> animation paused...');
%                     else
%                         fprintf(' resumed! \n');
%                     end
%                 end
%             case 'r'
%                 SIM_TIME = START_TIME;
%                 if VERBOSE
%                     disp('--> restarting animation');
%                 end
%             case 'uparrow'
%                 SPEED = 2*SPEED;
%                 if VERBOSE
%                     fprintf('--> speed set to %3.3f x real time\n',SPEED);
%                 end
%             case 'downarrow'
%                 SPEED = SPEED/2;
%                 if VERBOSE
%                     fprintf('--> speed set to %3.3f x real time\n',SPEED);
%                 end
%             case 'rightarrow'
%                 timeSkip = 5*SPEED*dtReal;
%                 SIM_TIME = SIM_TIME + timeSkip;
%                 if VERBOSE
%                     fprintf('--> skipping forward by %3.3f seconds\n',timeSkip);
%                 end
%             case 'leftarrow'
%                 timeSkip = 5*SPEED*dtReal;
%                 SIM_TIME = SIM_TIME - timeSkip;
%                 if VERBOSE
%                     fprintf('--> skipping backward by %3.3f seconds\n',timeSkip);
%                 end
%             case 'escape'
%                 QUIT = true;
%                 if VERBOSE
%                     disp('--> animation aborted');
%                 end
%             otherwise
%         end
%     end



end