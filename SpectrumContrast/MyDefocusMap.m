
function MyDefocusMap(OriginalImgName)
%% Read image
OriginalColorImage=imread(OriginalImgName);
%%Gaussian for removing high-frequency noise and suppressing the blur
%%texture (e.g., soft shadows or blur patterns).
inImg=im2double(rgb2gray(imfilter(OriginalColorImage, fspecial('gaussian', 3, 3), 'symmetric', 'conv')));  %%
% RGB to gray
GrayImage=rgb2gray(OriginalColorImage);   
[M,N]=size(GrayImage);


%% Global Spectrum contrast 
%(Here, we use a simpler global spectrum
%contrast instead of local  spectrum contrast for the simplicity of computation cost, and good results can be also obtained.)
%%FFT
ImageFFT = fft2(inImg);
%%Log processing
LogAmplitude = log(abs(ImageFFT));
%%FFT phase
FFTPhase = angle(ImageFFT);
%%Spectrum contrast
Spectralcontrast= LogAmplitude - imfilter(LogAmplitude, fspecial('average', 3), 'replicate');
SparseDepth = abs(ifft2(exp(Spectralcontrast + i*FFTPhase))).^2;

SparseContrast = mat2gray(imfilter(SparseDepth, fspecial('gaussian', [10, 10], 2.5)));
imwrite(mat2gray(Spectralcontrast), "SpectralContrast.png")
imwrite(mat2gray(SparseDepth), "SparseDepth.png")
imwrite(mat2gray(SparseContrast), "SparseContrast.png")

%% Supress color Abbreation
%% Supress color Abbreation 
OriginalEdge=zeros(M,N);
OriginalColorImageR=OriginalColorImage(:,:,1);
OriginalColorImageG=OriginalColorImage(:,:,2);
OriginalColorImageB=OriginalColorImage(:,:,3);
OriginalEdgeR=edge(OriginalColorImageR,'canny',0.05);
OriginalEdgeG=edge(OriginalColorImageG,'canny',0.05); 
OriginalEdgeB=edge(OriginalColorImageB,'canny',0.05);
for i1=1:M
    for j1=1:N
            if (OriginalEdgeR(i1,j1)==1&&OriginalEdgeG(i1,j1)==1)||(OriginalEdgeR(i1,j1)==1&&OriginalEdgeB(i1,j1)==1)||(OriginalEdgeG(i1,j1)==1&&OriginalEdgeB(i1,j1)==1)
            OriginalEdge(i1,j1)=1;
        else
            OriginalEdge(i1,j1)=0;
        end
    end
end
imwrite(mat2gray(OriginalEdgeR), "original_r.png")
imwrite(mat2gray(OriginalEdge), "original_edge.png")
%%For the IP ISSUE, details of function "GetSparseDfocusFromcontrastData()"
%%is protected.(-_-)
D=GetSparseDfocusFromcontrastData(M,N,SparseContrast,OriginalEdge);
D

imwrite(D, "D.png")

 %%Bilater filter
Sparsecontrast=BilateralFilter(D,OriginalColorImage);
imwrite((Sparsecontrast), "afterBilateral.png")

%%
Rbird=OriginalColorImage(:,:,1); 
Gbird=OriginalColorImage(:,:,2);
Bbird=OriginalColorImage(:,:,3);

Sparsecontrast=im2uint8(Sparsecontrast);  %
RSparsebird=Sparsecontrast;
GSparsebird=Sparsecontrast;
BSparsebird=Sparsecontrast;

[m n]=size(Rbird);
for j=1:m
    for k=1:n
        if RSparsebird(j,k)~=0
            Rbird(j,k)=RSparsebird(j,k);
            Gbird(j,k)=GSparsebird(j,k);
            Bbird(j,k)=BSparsebird(j,k);
        end          
    end
end
Scrible(:,:,1)=Rbird;
Scrible(:,:,2)=Gbird;
Scrible(:,:,3)=Bbird;


%%  defocus propagation(matting) 
levels_num=1;   
active_levels_num=1;   
sig=0.1^6;
runMatting
end


