%%Defocus matting step, we use Levin's code, you can refer to 
% Anat Levin, Dani Lischinski, and Yair Weiss. A Closed-Form Solution to Natural Image Matting.
% IEEE TRANSACTIONS ON PATTERN ANALYSIS AND MACHINE INTELLIGENCE, VOL. 30,
% NO. 2, FEBRUARY 2008.
if (~exist('thr_alpha','var'))
  thr_alpha=[];
end
if (~exist('epsilon','var'))
  epsilon=[];
end
if (~exist('win_size','var'))
  win_size=[];
end

if (~exist('levels_num','var'))
  levels_num=1;
end  
if (~exist('active_levels_num','var'))
  active_levels_num=1;
end  

I=double(OriginalColorImage)/255;
mI=double(Scrible)/255;
consts_map=sum(abs(I-mI),3)>0.001;
if (size(I,3)==3)
  consts_vals=rgb2gray(mI).*consts_map;
end
if (size(I,3)==1)
  consts_vals=mI.*consts_map;
end



alpha=solveAlphaC2F(I,consts_map,consts_vals,levels_num, ...
                    active_levels_num,thr_alpha,epsilon,win_size);

% figure, imshow(alpha);

imwrite(alpha, 'DefocusMap.png');

% drawnow;     %
% [F,B]=solveFB(I,alpha);
% 
% figure, imshow([F.*repmat(alpha,[1,1,3]),B.*repmat(1-alpha,[1,1,3])])