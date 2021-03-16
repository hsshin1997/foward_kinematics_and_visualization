% MAIN.m -- Forward kinematics and visualization
%
% This script calculates and visualizes forward kinematics. For further
% detail, reference the 'forward kinematics and visualization' word
% document in the folder.
%
%

clc; clear; close all;
addpath ../../

global MASSDATA LinkLengths DHINFO Parent ItsParent ParentBranch

%%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                          Input textfile name                            %
%                              User Change                                %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
masstxt = 'LINK_MASS_DATA.txt';
linktxt = 'LINK_LENGTH.txt';
dhtxt = 'DHPARAMETERS.txt';

% joint variable is optional -- comment it out if not used
% jvtxt = 'JOINT_VARIABLES_MAX_SS_steppable2_IG_4.xlsx';
jvtxt = 'JOINT_VARIABLES_MIN_3dof.xlsx';


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Read and Sort Data                           %
%                              Do not change                              % 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
MASSDATA = readMass(masstxt);
LinkLengths = readLinks(linktxt);
[DHTABLE, DHINFO, Parent, ParentBranch, ItsParent] ...
    = readDH(dhtxt);
if exist('jvtxt','var')
    [JV, Time] ...
        = readJV(jvtxt, ParentBranch, ItsParent);
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Forward Kinematics                           %
%                              Do not change                              %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

if exist('Time','var')
    for i = 1:length(Time)
        [JK{i}, CK{i}, R{i}] = ForwardKinematics(DHTABLE,JV{i});
        P_com{i} = CenterOfMass(CK{i});
    end
else
    [JK, CK, R] = ForwardKinematics(DHTABLE);
    P_com = CenterOfMass(CK)
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                              Visualization                              %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% User change options
Param.fictitiousOn = true; 
Param.fictitiousLine = '--k';
Param.is2D = true;
Param.height = 0.6; % Used to expand 2D to 3D. If 3D DH model is used can ignore
Param.CoMOn = true;
% DON'T CHANGE BELOW THREE
Param.isStatic = ~exist('Time','var'); 
Param.dhinfo = DHINFO;
Param.parent = Parent;
Param.xaxis_limit = [-0.25 0.25];
Param.yaxis_limit = [-0.05, 0.45];
Param.zaxis_limit = [-0.25 0.25];
Param.camAng = [0 90];

[x,xc,t,pack] = packFK(JK,CK,Param,Time);
Anim.speed = 0.25;
Anim.plotFunc = @(t,x,xc)(drawRobot(x,xc,pack));
Anim.verbose = true;
animateStickFig(t,x,xc,Anim)

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                            Data Extraction                              %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

Pos = getPos(2, JK, Time)
Orien = getAng(2, R, Time)

