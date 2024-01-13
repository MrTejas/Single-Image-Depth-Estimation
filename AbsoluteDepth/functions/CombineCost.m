function err = CombineCost(err_x,err_y,maxerr,minerr,minerr2)
% Combine and adjust data cost.
% err_x, err_y - data cost, imgsz(1)*imgsz(2)*level
% maxerr - for dense sharp texture detection
% minerr - for background detection
% minerr2 - for blurred texture detection (Nshape)
%
% Copyright (C) 2013-2014 Jinyu Lin, linjy02@hotmail.com
%

level = size(err_x,3);

%% weak texture checker
err_maxx = max(err_x,[],3);
err_maxy = max(err_y,[],3);
mask_xsm = err_maxx<minerr; % small error (no texture)
mask_ysm = err_maxy<minerr;
mask_xweak = err_maxx<minerr2; % small error (weak texture)
mask_yweak = err_maxy<minerr2;

%% dense texture checker
[err_minx depthmapx] = min(err_x,[],3);
[err_miny depthmapy] = min(err_y,[],3);
d1 = floor(level/6); d2 = level-d1;
% mask_xlg = err_minx>maxerr & depthmapx>3; % large error
% mask_ylg = err_miny>maxerr & depthmapy>3;
mask_lg = (err_minx>maxerr&depthmapx>d1) | (err_miny>maxerr&depthmapy>d1);

% code bar type
mask_lg = mask_lg | (depthmapx>=d2 & err_maxx-err_minx>maxerr);
mask_lg = mask_lg | (depthmapy>=d2 & err_maxy-err_miny>maxerr);

% % debug
% figure(10);imagesc(mask_lg); title('maks lg')
% figure(11);image(depthmapx); colormap(jet(level)); title('depth-x')
% figure(12);image(depthmapy); colormap(jet(level)); title('depth-y')

%% N shape checker
d1 = floor(level/4); d2 = floor(level/2); d3 = level-d1;

[val idx] = max(err_x(:,:,1:d1+1),[],3);
a = idx<d1; 
lcmaxix = idx.*a; % local max index
lcmaxvx = val.*a; % local max value
[val idx] = max(err_x(:,:,1:d2+1),[],3);
a = idx<d2 & lcmaxix==0;
lcmaxix = lcmaxix + idx.*a;
lcmaxvx = lcmaxvx + val.*a;
[val idx] = max(err_x(:,:,1:d3+1),[],3);
a = idx<d3 & lcmaxix==0;
lcmaxix = lcmaxix + idx.*a;
lcmaxvx = lcmaxvx + val.*a;

[val idx] = max(err_y(:,:,1:d1+1),[],3);
a = idx<d1; 
lcmaxiy = idx.*a; % local max index
lcmaxvy = val.*a; % local max value
[val idx] = max(err_y(:,:,1:d2+1),[],3);
a = idx<d2 & lcmaxiy==0;
lcmaxiy = lcmaxiy + idx.*a;
lcmaxvy = lcmaxvy + val.*a;
[val idx] = max(err_y(:,:,1:d3+1),[],3);
a = idx<d3 & lcmaxiy==0;
lcmaxiy = lcmaxiy + idx.*a;
lcmaxvy = lcmaxvy + val.*a;

% N shape flag
mask_xNshape = mask_xweak & lcmaxix>0;
mask_yNshape = mask_yweak & lcmaxiy>0;

%% modify errors
% N shape: if i<lcmaxi, err = lcmaxv
for i=1:level
    a = i<lcmaxix & mask_xNshape;
    err_x(:,:,i) = err_x(:,:,i).*~a + lcmaxvx.*a;

    a = i<lcmaxiy & mask_yNshape;
    err_y(:,:,i) = err_y(:,:,i).*~a + lcmaxvy.*a;
end

% [err_minx depthmapx] = min(err_x,[],3);
% [err_miny depthmapy] = min(err_y,[],3);
% % debug
% figure(13);image(depthmapx); colormap(jet(level)); title('depth-x-adjust')
% figure(14);image(depthmapy); colormap(jet(level)); title('depth-y-adjust')

%%====== combine error ======%%
% err_x = (err_x+err_y)/2;
% d1 = level; d2 = level - floor(level/5);
% mask1 = depthmapx<d1 & depthmapy>d2;   % x dominant
% mask2 = depthmapx==d1 & depthmapy<=d2; % y dominant
mask1 = ~mask_xsm & mask_ysm; % x dominant
mask2 = mask_xsm & ~mask_ysm; % y dominant
mask3 = (~mask1 & ~mask2)/2;
mask1 = mask1 + mask3;
mask2 = mask2 + mask3;
for i=1:level
    a = err_x(:,:,i).*mask1 + err_y(:,:,i).*mask2;
%     a = a + (err_x(:,:,i)+err_y(:,:,i)).*mask3;
    err_x(:,:,i) = a;
end

%% N shape checker after error combination
[err_minx depthmapx] = min(err_x,[],3);
err_maxx = max(err_x,[],3);
d1 = floor(level/4); d2 = floor(level/2); d3 = level-d1;

[val idx] = max(err_x(:,:,1:d1+1),[],3);
a = idx<d1; 
lcmaxix = idx.*a; % local max index
lcmaxvx = val.*a; % local max value
[val idx] = max(err_x(:,:,1:d2+1),[],3);
a = idx<d2 & lcmaxix==0;
lcmaxix = lcmaxix + idx.*a;
lcmaxvx = lcmaxvx + val.*a;
[val idx] = max(err_x(:,:,1:d3+1),[],3);
a = idx<d3 & lcmaxix==0;
lcmaxix = lcmaxix + idx.*a;
lcmaxvx = lcmaxvx + val.*a;

% N shape flag
mask_xweak = err_maxx<minerr2; 
mask_xNshape = mask_xweak & lcmaxix>0;

%% noisy region checker after error combination
% mask_sm = err_maxx<minerr;    % small error (no texture)

%% modify errors after error combination
d2 = level - 2;
mask1 = (mask_lg)*maxerr/level/8;
mask2 = (err_maxx<minerr | depthmapx>d2)*minerr/level/8;
% mask2 = (err_maxx<minerr)*minerr/level/8;
mask3 = ~mask1&~mask2;
for i=1:level
    a = i<lcmaxix & mask_xNshape;
%     err_x(:,:,i) = (i-1)*mask1 + (level-i)*mask2 + ...
%         err_x(:,:,i).*(~a&mask3) + lcmaxvx.*(a&mask3);
    
    err_x(:,:,i) = mask1 + (level-i)*mask2 + ... % ignore mask_lg
        err_x(:,:,i).*(~a&mask3) + lcmaxvx.*(a&mask3);
end
err = err_x;
