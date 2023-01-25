%Code for ModifiedCBWH Algo

clc;
close all
clear

[file,path] = uigetfile('*.avi');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end
M = VideoReader(fullfile(path,file));

numberofframes = M.NumFrames;
% Frames={M.cdata};                        % Frames, video data     

% ================= set some parameters ============================
trackingAlgorithm=3;      % 1. original mean shift 
%                           2. BWH based mean shift 
%                           3. proposed ModifiedCBWH 

startFrm=1;               % start frame
endFrm=numberofframes;    % end frame

minDist=0.1;              % convergence threshold of mean shift              
maxIterNum=15;            % maximal iteration number
incre=7;                  % increase size of candidate window

redBins=16;               % default color quant sheme (fixed in this demo)
greenBins=16;
blueBins=16;

resultType=1;             % save tracing result 0. not save, 1. save in avi and bmp format
% ============================ set parameters =================================

% frame00=Frames{startFrm};                  % define the target in startFrm;
frame00 = read(M, startFrm);                  % define the target in startFrm;

if resultType==1                           % save tracking result
    bmpFileHead='.\tracking result\image';                 % bmp format  
    aviFileName = strcat('tracked_',file);    % avi format  
    aviFileName = strcat('.\tracking result\',aviFileName);    % avi format  

    mov = VideoWriter(aviFileName);             % creae a avi handle    
end
open(mov);

% define the target window
[cmin, cmax, rmin, rmax] = select(frame00);

center(1,1)=floor((rmin+rmax+1)/2);         % center of target window
center(1,2)=floor((cmin+cmax+1)/2);         %                   

w_halfsize(1) = round(abs(rmax - rmin)/2);  % half window 
w_halfsize(2) = round(abs(cmax - cmin)/2);  % 

w_halfsize_bg=2*w_halfsize;                 % size of background winodw

% target model(histogram)
q_u=rgbPDF(double(frame00),center,w_halfsize);   
if trackingAlgorithm>1                      % BWH or CBWH based mean shift
    [o_u,v_u]=rgbPDF_BG(double(frame00),center,w_halfsize,w_halfsize_bg);       % background model
    q_u=q_u.*v_u/(q_u*v_u');                % transform target model q_u with background model v_u 
end

set(gcf,'DoubleBuffer','on');               % set double buffer 

% height=size(frame00,1);                     % height of each frame
% width=size(frame00,2);                      % width of each frame
height = M.Height;
width = M.Width;

figure(1);hold on;

% start tracking
for i = startFrm:endFrm                     % numberofframes        
    if i==startFrm                          % draw initial target region in first frame
        framei=frame00;
    elseif i>1  % 
%         framei=Frames{i};
          framei = read(M, i);
        if trackingAlgorithm==1 || trackingAlgorithm==3           % standard mean shift or CBWH based mean shift
            % tracking target with mean shift
            % note: q_u for standard meam shift and the proposed CBWH based mean shift is different (please see the our paper in detail)
            center=rgbTracking(double(framei),center,w_halfsize,q_u,minDist,maxIterNum,incre);
        elseif trackingAlgorithm==2                               % BWH based mean shift
            center=rgbTracking_BWH(double(framei),center,w_halfsize,q_u,v_u, minDist,maxIterNum,incre);      
        end
    end  
            
    rmin=center(1)-w_halfsize(1);   
    rmax=center(1)+w_halfsize(1);   
    cmin=center(2)-w_halfsize(2);
    cmax=center(2)+w_halfsize(2);
    
    if rmin<2
        rmin=2;
    end   
    
    if rmax>height-1;
        rmax=height-1;
    end    
    
    if cmin<2
        cmin=2;
    end    
    
    if cmax>width-1
        cmax=width-1
    end

    % draw tracking result
    trackim=framei;                 
    for r= rmin:rmax
        trackim(r, cmin-1:cmin,:) = 0;      
        trackim(r, cmin-1:cmin,3) = 255;    
        trackim(r, cmax:cmax+1,:) = 0;        
        trackim(r, cmax:cmax+1,3) = 255;
    end
    for c= cmin:cmax
        trackim(rmin-1:rmin, c,:) = 0;
        trackim(rmin-1:rmin, c,3) = 255;
        trackim(rmax:rmax+1, c,:) = 0;        
        trackim(rmax:rmax+1, c,3) = 255;
    end   
    
    if i==startFrm           
        for r=center(1)-w_halfsize_bg(1):center(1)+w_halfsize_bg(1);        
            trackim(r, center(2)-w_halfsize_bg(2)-1:center(2)-w_halfsize_bg(2), :)=0;                   
            trackim(r, center(2)-w_halfsize_bg(2)-1:center(2)-w_halfsize_bg(2), 1)=255;             
            trackim(r, center(2)+w_halfsize_bg(2):center(2)+w_halfsize_bg(2)+1, :)=0;                          
            trackim(r, center(2)+w_halfsize_bg(2):center(2)+w_halfsize_bg(2)+1, 1)=255;                 
        end
        
        for c=center(2)-w_halfsize_bg(2):center(2)+w_halfsize_bg(2)
            trackim(center(1)-w_halfsize_bg(1)-1:center(1)-w_halfsize_bg(1),c,:)=0;               
            trackim(center(1)-w_halfsize_bg(1)-1:center(1)-w_halfsize_bg(1),c,1)=255;                
            trackim(center(1)+w_halfsize_bg(1):center(1)+w_halfsize_bg(1)+1,c,:)=0;                       
            trackim(center(1)+w_halfsize_bg(1):center(1)+w_halfsize_bg(1)+1,c,1)=255;                   
        end      
    end

%     if resultType==1                        % save tracking result as bmp file
%         if i<10
%             bmpFileNum=['00',num2str(i)];
%         elseif i>9 & i<100
%             bmpFileNum=['0',num2str(i)];
%         else
%             bmpFileNum=num2str(i);
%         end
%         bmpFileName=[bmpFileHead,bmpFileNum,'.bmp'];
%         
%         imwrite(trackim,bmpFileName);
    if resultType==1                    % save tracking result as avi file
        F=im2frame(trackim);         
%         mov = addframe(mov,F);
          writeVideo(mov, F);
    end
        
    % display tracking result
    image(trackim);title([num2str(i),'/',num2str(numberofframes)]);drawnow;
end

if resultType==1                 
    mov = close();                       % close avi file
end