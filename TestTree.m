%clear all the memory and console output
clc;
close all;

clear;

% start string is: '6k1/5ppp/pb2p3/1p2P3/1P1BbPnP/P6r/6QP/R4R1K b - - 3 2'

iDepth = 4; % build to this depth

t1 = Tree('6k1/5ppp/pb2p3/1p2P3/1P1BbPnP/P6r/6QP/R4R1K b - - 3 2');

fprintf('Building Tree.. to depth %d at %s\n', iDepth, datestr(now));
pause(0.5);
t1.expandChildren(t1.Root, iDepth);

fprintf('Tree Build Completed @ %s\n======\n', datestr(now));

t1.printFirstLayer();
