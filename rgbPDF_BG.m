function [o_u,v_u]=rgbPDF_BG(image,center,w_halfsize,w_halfsize_bg)

sum_o=0;
histo=zeros(16,16,16);

% position of target window
rmin=center(1)-w_halfsize(1);
rmax=center(1)+w_halfsize(1);
cmin=center(2)-w_halfsize(2);
cmax=center(2)+w_halfsize(2);

% position of background window
rmin_bg=center(1)-w_halfsize_bg(1);   %
rmax_bg=center(1)+w_halfsize_bg(1);   %
cmin_bg=center(2)-w_halfsize_bg(2);   %
cmax_bg=center(2)+w_halfsize_bg(2);   %

% 
if rmin_bg<1                          % 
    rmin_bg=1;
end

if rmax_bg>size(image,1)              % 
    rmax_bg=size(image,1);
end

if cmin_bg<1                          % 
    cmin_bg=1;
end

if cmax_bg>size(image,2)              % 
    cmax_bg=size(image,2);
end

% calculate the backgournd histogram
for i=rmin_bg:rmax_bg                 % 
    for j=cmin_bg:cmax_bg             %        
        if ~(i>=rmin & i<=rmax & j>=cmin & j<=cmax)
            R=floor(image(i,j,1)/16)+1;
            G=floor(image(i,j,2)/16)+1;
            B=floor(image(i,j,3)/16)+1;
            histo(R,G,B)=histo(R,G,B)+1;
        end
    end
end

for i=1:16
    for j=1:16
        for k=1:16
            index=(i-1)*256+(j-1)*16+k;            
            o_u(index)=histo(i,j,k);
            sum_o=sum_o+o_u(index);
        end
    end
end

% transfomr o_u into v_u by Dr. Comaniciu etal's PAMI2003 paper 
o_u=o_u/sum(sum(o_u(:)));     % normalize
T=find(o_u~=0);               % 
o_s=min(o_u(T));              % minimal no zero entry

for i=1:4096       
    if o_u(i)~=0
        v_u(i)=o_s/o_u(i);
    else          
        v_u(i)=1;
    end
end