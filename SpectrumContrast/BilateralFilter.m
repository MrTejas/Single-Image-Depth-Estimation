%%This inplementation of BLF is un-optimized,you can try
%other accelerated version .
function output=BilateralFilter(SparseData,OriginalImg)

SparseData=double(SparseData);

OriginalImgR=OriginalImg(:,:,1);
OriginalImgG=OriginalImg(:,:,2);
OriginalImgB=OriginalImg(:,:,3);
ImgEdgeR=edge(OriginalImgR,'canny',0.05);
ImgEdgeG=edge(OriginalImgG,'canny',0.05); 
ImgEdgeB=edge(OriginalImgB,'canny',0.05);
OriginalImg=double(rgb2gray(OriginalImg));


[M,N]=size(OriginalImg);  % M=600; N=800
ImgEdge=zeros(M,N);
for i=1:M
    for j=1:N
        if (ImgEdgeR(i,j)==1&&ImgEdgeG(i,j)==1)||(ImgEdgeR(i,j)==1&&ImgEdgeB(i,j)==1)||(ImgEdgeG(i,j)==1&&ImgEdgeB(i,j)==1)
            ImgEdge(i,j)=1;
        else 
            ImgEdge(i,j)=0;
        end
    end
end

sigmaSpatial=81;
LengthCenter=(sqrt(sigmaSpatial)+1)/2;
sigmaRange=0.1*max(max(OriginalImg));
EdgeGrayImg=zeros(M,N);
% ImgEdge=edge(OriginalImg,'canny',0.05);  
for j=1:M
    for i=1:N
        if ImgEdge(j,i)~=0
            EdgeGrayImg(j,i)=OriginalImg(j,i);
        else 
            EdgeGrayImg(j,i)=0;
        end
    end
end

for j=1:M
    for i=1:N
        if j>=LengthCenter&&j<=M-LengthCenter+1&&i>=LengthCenter&&i<=N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=j-LengthCenter+1:j+LengthCenter-1
                for l=i-LengthCenter+1:i+LengthCenter-1
                    if ImgEdge(k,l)~=0              
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
           
      %% Left-Top  
        else if j<=LengthCenter-1&&i<=LengthCenter-1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=1:2*LengthCenter-1
                for l=1:2*LengthCenter-1
                    if ImgEdge(k,l)~=0                
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);  
         %% 
        %% left-middle
         else if j>=LengthCenter&&j<=M-LengthCenter+1&&i<=LengthCenter-1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=j-LengthCenter+1:j+LengthCenter-1
                for l=1:2*LengthCenter-1
                    if ImgEdge(k,l)~=0                
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i); 
          %%  
          
          %% left-bottom
            else if j>M-LengthCenter+1&&i<=LengthCenter-1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=M-2*(LengthCenter-1):M
                for l=1:2*LengthCenter-1
                    if ImgEdge(k,l)~=0               
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i); 
           %% 
           
           %% middle-top
            else if j<=LengthCenter-1&&i>=LengthCenter&&i<=N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=1:2*LengthCenter-1
                for l=i-LengthCenter+1:i+LengthCenter-1
                    if ImgEdge(k,l)~=0               
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
           %% 
           %% middle-bottom
             else if j>M-LengthCenter+1&&i>=LengthCenter&&i<=N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=M-2*(LengthCenter-1):M
                for l=i-LengthCenter+1:i+LengthCenter-1
                    if ImgEdge(k,l)~=0              
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
           %% 
           %% right-top
                 else if j<=LengthCenter-1&&i>N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=1:2*LengthCenter-1
                for l=N-2*(LengthCenter-1):N
                    if ImgEdge(k,l)~=0               
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
          %% 
          
          %% right-middle
            else if j>=LengthCenter&&j<=M-LengthCenter+1&&i>N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=j-LengthCenter+1:j+LengthCenter-1
                for l=N-2*(LengthCenter-1):N
                    if ImgEdge(k,l)~=0                
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
           %% 
           %% right-bottom
            else if j>M-LengthCenter+1&&j<=M-LengthCenter+1&&i>N-LengthCenter+1&&ImgEdge(j,i)~=0
            W(j,i)=0;
            ssum(j,i)=0;
            for k=M-2*(LengthCenter-1):M
                for l=N-2*(LengthCenter-1):N
                    if ImgEdge(k,l)~=0                
                        wsum=(sqrt((k-j).^2+(l-i).^2)./(2*pi*sigmaSpatial.^2)) .* exp(-((k-j).^2+(l-i).^2)./(2*sigmaSpatial))+(sqrt((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*pi*sigmaRange.^2)) .* exp(-((EdgeGrayImg(k,l)-EdgeGrayImg(j,i)).^2)./(2*sigmaRange)); 
                        sum=wsum.*SparseData(k,l);
                        W(j,i)=wsum+W(j,i);
                        ssum(j,i)=sum+ssum(j,i);
                    else
                        continue;
                    end
                end
            end
            SparseData(j,i)=ssum(j,i)./W(j,i);
                         %% 
                             end
                             
                         end

                     end
                      
             end
                  
           end
        end
              
             end
                        
       end

           
        end
     
        
    end
end

output=SparseData;
