function center=rgbTracking_BWH(image,center,w_halfsize,q_u,v_u,minDist,maxIterNum,incre)
% ********************************************************************
%       image               current frame
%       center              initial position of the target
%       w_halfsize          half size of the window         
%       q_u                 target model
%       v_u                 candiate model
%       minDist             convergence threshold
%       maxIterNum          maximal iteration number of mean shift
% return:
%       center          ¡¡  the finial position of the target
%

% **********************************************************************

sum_p=0; 
histo=zeros(16,16,16);      % initilize candiate model

iterations=0;               % 
center_old=center;

% position of candidate target window
rmin=center(1)-w_halfsize(1)-incre;
rmax=center(1)+w_halfsize(1)+incre;
cmin=center(2)-w_halfsize(2)-incre;
cmax=center(2)+w_halfsize(2)+incre;

height=size(image,1);
width=size(image,2);
    
while 1
    wmax=(rmin-center(1)).^2+(cmin-center(2)).^2+1;   
    for i=rmin:rmax     
        for j=cmin:cmax
            if (i>=1 & i<=height & j>=1 & j<=width)
                d=(i-center(1)).^2+(j-center(2)).^2;
                w=wmax-d; 
                R=floor(image(i,j,1)/16)+1;
                G=floor(image(i,j,2)/16)+1;
                B=floor(image(i,j,3)/16)+1;
                histo(R,G,B)=histo(R,G,B)+w;
            end
        end
    end

    for i=1:16
        for j=1:16
            for k=1:16
                index=(i-1)*256+(j-1)*16+k;
                % transform p_u by v_u (see Dr. Comaniciu paper "Kernel based object tracking", PAMI2003
                p_u(index)=histo(i,j,k)*v_u(index);
                sum_p=sum_p+p_u(index);
            end
        end
    end    
    p_u=p_u/sum_p; 
    n=1;
    for i=rmin:rmax  % compute w=sqrt(q_u(i)/p_u(i))
        for j=cmin:cmax
            if (i>=1 & i<=height & j>=1 & j<=width)  
                R=floor(image(i,j,1)/16)+1;
                G=floor(image(i,j,2)/16)+1;
                B=floor(image(i,j,3)/16)+1;
                u=(R-1)*256+(G-1)*16+B;
                x(1,n)=i;
                x(2,n)=j;                
                w_i(n)=sqrt(q_u(u)/p_u(u));                                                                
                n=n+1;
            end
        end
    end

    center_r=(x*w_i'/sum(w_i))';               % new centroid    
    MS=sqrt(sum((center_r-center_old).^2));    % norm of mean shift vector 
    iterations=iterations+1;                   % mean shift iteration number
    
    % is mean shift convergence?
    if (MS<minDist | iterations>=maxIterNum)
        break;
    end
    
    center_old=center_r;                       %   
    center=floor(center_r);                    % 

    % 
    rmin=center(1)-w_halfsize(1)-incre;        % 
    rmax=center(1)+w_halfsize(1)+incre;
    cmin=center(2)-w_halfsize(2)-incre;
    cmax=center(2)+w_halfsize(2)+incre;
    
    histo=zeros(16,16,16);                     % reinitilize candiate model
    sum_p=0;         
end