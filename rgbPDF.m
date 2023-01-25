function q_u=rgbPDF(image,center,w_halfsize)

sum_q=0;
histo=zeros(16,16,16);

rmin=center(1)-w_halfsize(1);
rmax=center(1)+w_halfsize(1);
cmin=center(2)-w_halfsize(2);
cmax=center(2)+w_halfsize(2);

wmax=(rmin-center(1)).^2+(cmin-center(2)).^2+1;
for i=rmin:rmax  
    for j=cmin:cmax
        d=(i-center(1)).^2+(j-center(2)).^2;
        w=wmax-d;  
        R=floor(image(i,j,1)/16)+1;
        G=floor(image(i,j,2)/16)+1;
        B=floor(image(i,j,3)/16)+1;
        histo(R,G,B)=histo(R,G,B)+w;        
    end
end

for i=1:16
    for j=1:16
        for k=1:16
            index=(i-1)*256+(j-1)*16+k;            
            q_u(index)=histo(i,j,k);
            sum_q=sum_q+q_u(index);
        end
    end
end

q_u=q_u/sum_q; % normalize