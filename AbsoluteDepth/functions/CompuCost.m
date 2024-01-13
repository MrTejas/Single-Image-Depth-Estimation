function [err_x err_y] = CompuCost(img,filtsX,filtsY,ws)
% Compute data cost using our approach
% img - blurred color image
% filtsX, filtsY - 1D band pass filter set, m*level
% ws - window size
% err_x, err_y - output data cost, imgsz(1)*imgsz(2)*level
%
% Copyright (C) 2013-2014 Jinyu Lin, linjy02@hotmail.com
%

imgsz = size(img);
[nblur level] = size(filtsX);

%% differential images
img_dx1 = [zeros(imgsz(1),1) diff(img(:,:,1),1,2)];
img_dx2 = [zeros(imgsz(1),1) diff(img(:,:,2),1,2)];
img_dx3 = [zeros(imgsz(1),1) diff(img(:,:,3),1,2)];
img_dy1 = [zeros(1,imgsz(2));diff(img(:,:,1),1,1)];
img_dy2 = [zeros(1,imgsz(2));diff(img(:,:,2),1,1)];
img_dy3 = [zeros(1,imgsz(2));diff(img(:,:,3),1,1)];

%% compute errors
err_x = ones(imgsz(1),imgsz(2),level); 
err_y = ones(imgsz(1),imgsz(2),level);
n = nblur; smfilt = ones(n,1)/n/1;
n = ws; smfilt2D = ones(1,n)/n;
fprintf('level=%.2d', 1)
for i=1:level
    fprintf('\b\b%.2d', i)
    fx = filtsX(:,i);
    ax1 = conv2(img_dx1,fx','same');
    ax1 = ax1.*ax1;
    ax2 = conv2(img_dx2,fx','same');
    ax2 = ax2.*ax2;
    ax3 = conv2(img_dx3,fx','same');
    ax3 = ax3.*ax3;
%     ax = max(max(ax1,ax2),ax3);
    ax = ax1+ax2+ax3;
    ax = conv2(ax,smfilt','same'); 
    ax = conv2(ax,smfilt2D','same'); 
    err_x(:,:,i)=ax;
%     err_x(:,:,i)=min(ax,maxerr);
    
	fy = filtsY(:,i);
    ay1 = conv2(img_dy1,fy,'same');
    ay1 = ay1.*ay1;
    ay2 = conv2(img_dy2,fy,'same');
    ay2 = ay2.*ay2;
    ay3 = conv2(img_dy3,fy,'same');
    ay3 = ay3.*ay3;
%     ay = max(max(ay1,ay2),ay3);
    ay = ay1+ay2+ay3;
    ay = conv2(ay,smfilt,'same'); 
    ay = conv2(ay,smfilt2D,'same'); 
    err_y(:,:,i)=ay; 
%     err_y(:,:,i)=min(ay,maxerr);
end
