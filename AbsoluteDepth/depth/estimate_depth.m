% Generate depth
addpath '..\functions'
addpath '..\bin'

%% image
imagename = 'books'; % time 15.568746
% imagename = 'cloth2'; % time 14.470829
% imagename = 'cloth3'; % time 14.336662
% imagename = 'dolls'; % time 15.670734
% imagename = 'midd'; % Time: 15.593194
% imagename = 'rocks1'; % Time: 14.885000
% imagename = 'rocks2'; % Time: 14.447385
% imagename = 'wood1'; % Time: 15.536597
% imagename = 'wood2'; % Time: 14.335984

fn = sprintf('.\\images\\img_Lin_%s.png',imagename);
img = imread(fn);
img = double(img)/255;
figure(1); image(img); title('captured image')
drawnow

%% PSFs and aperture shape filters
load PSFs
level = 16;
PSF_Lin = PSF_Lin(:,:,1:level);

load ApFilters3ch
hx = hx(:,1:level,1);
hy = hy(:,1:level,1);

%% compute error
maxerr = 2e-2;
minerr = 2e-5;
minerr2 = 2e-2;
ws = 9;

tic;  % start counter

[err_x err_y] = CompuCost(img,hx,hy,ws);
newerr = CombineCost(err_x,err_y,maxerr,minerr,minerr2);

tElapsed = toc;
fprintf('\nRunning Time: %f\n', tElapsed)

% [err_min depthmap_Lin] = min(newerr,[],3);
% figure(3);image(depthmap_Lin); colormap(jet(level));

%% record error
blursz = [64 64];
a = newerr(blursz(1)+1:end-blursz(1),blursz(2)+1:end-blursz(2),:);
sz = size(a);
a = reshape(a,sz(1)*sz(2),level);
save err.txt a -ascii

%% regularizing
inicmd = sprintf('copy VisionBP_%s.ini VisionBP.ini >nul',imagename);
system(inicmd);
system('..\bin\VisionBP');

%% show results
fn = sprintf('.\\images\\depthmap_%s',imagename);
load(fn,'truedepth_noedge');
figure(2);image(truedepth_noedge); colormap(jet(level)); title('true')

depthmap_Lin = importdata('depthmap.txt')'+1;
figure(3);image(depthmap_Lin); colormap(jet(level)); title('lin')
fn = sprintf('results\\depth_Lin_%s.png',imagename);
imwrite(depthmap_Lin,colormap(jet(level)),fn,'png')


