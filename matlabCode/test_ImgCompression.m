clc;
clear;
close("all")
T_f = 'gpsData.mat';
gpsData = load(T_f);
Idx0=60;
T = gpsData.T(Idx0+1:Idx0+30,:);
%���ж���
buff_num=3;%ͼ��ɼ���buffer��С
tran_num=10;%������еĴ�С
img_num=30;%�����в���������ͼ���С
%��ȡͼ��buffer�ļ���V
imSetV.num=0;% video buffer
imSetV.idx=zeros(imSetV.num,1);
% transmit������еļ���T
imSetT.num=1;%��ʼһ��ͼ��
imSetT.idx=zeros(imSetV.num,1);%���ͼ����±�
imSetT.idx(1)=1;
%���䵽����վ��ͼ���Ӽ�S
imSetS.num=0;%��ʼ0��ͼ��
imSetS.idx(1)=0;
trans_idx=0;
AMs=1;%��ѡ���ͼ���Ӽ�S�����������
UMs_AMs=1;
UMs_sumQ=0;
AMs_max=0;%��ʱ�洢�������������
%��ʼ������
s=1;%H��������Ų�����eq2
alpha=1;%����ͼƬ�������˹���ֵ,eq4��
gama=0.9;%eq44�Ĳ������ص�����������������Ӱ�죬��Ϊ�Ǹ߹���
degradation=1;%eq5����ͼ���ؽ���%1
delta=1.2;      %eq5�����������ͼ��������Ӱ��
lamda=0.8;    %eq6,�Ӽ����������Ч��ֵ�Ĺ���
belta=1;      %eq6,ͼ�����������Ч��ֵ�Ĺ���
J=1; %qq6,����
sumAMs=1;%��ѡ���ͼ���Ӽ�S���ۺ�Ч��ֵ   
sumQ=0;UMs=0;UMs_max=0;%��ʽ6������ʼ��
poly=0;
fig1=subplot(2, 3, 1);
fig2=subplot(2, 3, 2);
fig3=subplot(2, 3, 3);
fig4=subplot(2, 3, 4); hold on;axis equal;
fig5=subplot(2, 3, 5);hold on;axis equal;
fig6=subplot(2, 3, 6);hold on;axis equal;
Ns=0;
ft_i=0;%��buffer��ȡ�������
Vnum=1;%�ۼ��Ѽ���buffer��ͼƬ����
flyH=0;
idxt=0;
idxs=0;
az=0;
%����gps�켣
for i=1:img_num
    lat = T.lat(i); % latitude of point 2
    lon = T.lon(i); % longitude of point 2
    alt = T.alt(i);
    [x(i),y(i),z(i)]=calc_cordinate(lat,lon,alt);
end 
c41=plot(fig4,x,y,'-b.');%gps�켣
plot(fig5,x,y,'-b.');%gps�켣
plot(fig5,x(1),y(1),'-rs');%������г�ʼ״̬��һ��ͼƬ
plot(fig6,x,y,'-b.');%gps�켣
plot(fig6,x(1),y(1),'-ro');%��һ��ͼƬ�����վ����

%Ԥ��ѹ��
while(Vnum<img_num )
    %put image to buffer
    if(imSetV.num<buff_num)
        n=buff_num-imSetV.num;
        idx1=Vnum+1;%���ڴ��������
        idx2=Vnum+n;
        if(idx2>img_num)%�������ͼ�񳬹��˸���������
            idx2=img_num;
            n=idx2-idx1+1;
        end
       imSetV.idx(imSetV.num+1:imSetV.num+n)=(idx1:idx2)';
       Vnum=Vnum+n;
       imSetV.num =imSetV.num+n; 
    end 
    UMs_max=0;
    for i=1:imSetV.num     
        %find fst ,minest distance to ft in transmit queue 
         kt=imSetV.idx(i);
         mindist=1.0e5;
         minaz=0; 
        for j=1:imSetT.num
            ks=imSetT.idx(j);
            lat1 = T.lat(ks); % latitude of point 1
            lon1 = T.lon(ks); % longitude of point 1
            alt1=T.alt(ks);
            flyH1=T.flyH(ks);
             lat2 = T.lat(kt); % latitude of point 2
             lon2 = T.lon(kt); % longitude of point 2
             alt2 = T.alt(kt);
            flyH2=T.flyH(kt);
            [az,dist]=calc_euclidean_distance(lat1,lon1,lat2,lon2,alt1,alt2);
            if(dist<mindist)
                idxt=kt;
                idxs=ks;
                mindist=dist;
                minaz=az;
                flyH=(flyH1+flyH2)/2;
            end 
        end
        %compute homography transformation matrix
        t=calc_displacement(az, mindist,flyH);
        H=calc_hom_transform(az,t,s);  
        %compute overlap
        A = imread(['imageFile/',T.img{idxs}]);
        B = imread(['imageFile/',T.img{idxt}]);  
        gray_imgB = rgb2gray(B);
        B_area = size(gray_imgB, 1) * size(gray_imgB, 2);
        Aft=1;%pix area of each image is the same,set the area as 1.
        [polyout,area]=overlap_area(A,B,H);
        overlap=area/B_area;%�ص������һ��
        %��������ft+1�����������������ݹ�ʽ4
        AMs_tmp=calc_mosaics_area(AMs,Aft,overlap,alpha,gama);
        %jpeg compression
        compr_file=calc_jpeg_compression(A,1);
        compr_img=imread(compr_file);
        Pt=calc_psnr(A,compr_img);
%         %����ͼ�����
%         Dt=calc_image_entropy(B);
%         %����ͼ���ؽ������PSNR,
%         Pt=calc_degradation_psnr(degradation);
%         %�����������
        Bt=calc_bandwidth(gray_imgB);
        %����Ч��ֵ��eq(5)
        Qt=Pt-delta*Bt;
        %�����ۼ��ۺ�Ч��ֵ,eq(6)    
        sumAMs_tmp=AMs_tmp;
        sumQ_tmp=sumQ+Qt;
        UMs_tmp=sumAMs_tmp+lamda*Ns+belta/J*sumQ; 
        if(UMs_tmp>UMs_max)
            UMs_max=UMs_tmp;
            UMs_AMs=AMs_tmp;
            UMs_sumQ=sumQ_tmp;
            trans_idx=kt;
            poly=polyout;
            ft_i=i;
        end 
        %show pridictive compression workflow
        pause(0.001)
        fig1=subplot(2, 3, 1);
        cla(fig1);
        imshow(A);
        title('fst');
        axis equal
        fig2=subplot(2, 3, 2);
        cla(fig2);
        imshow(B);
        hold on
        plot(polyout,"LineStyle","-","FaceColor","g");
        title('overlap of ft+1 and fst');
        axis equal  
        fig5=subplot(2, 3, 5);
        cla(fig5);
        plot(fig5,x,y,'-b.');
        xq=x(imSetT.idx(:));yq=y(imSetT.idx(:));%transmit queue
        c51=plot(fig5,xq,yq,'rs'); 
        xt=x(imSetV.idx(:));yt=y(imSetV.idx(:));%video buffer
        c52=plot(fig5,xt,yt,'k^'); 
        c53=plot(fig5,x(idxs),y(idxs),'r*'); 
        c54=plot(fig5,x(idxt),y(idxt),'g*');%ft+1
%         legend([c51 c52 c53 c54],'Tansmit queue','Video buffer','fst','ft+1');
        axis equal
    end
    %udate param
    UMs=UMs_max;
    AMs=UMs_AMs;
    sumQ=UMs_sumQ;
    Ns=Ns+1;
    B = imread(['imageFile/',T.img{trans_idx}]);  
    fig3=subplot(2, 3, 3);
    cla(fig3)
    imshow(B);
    hold on
    plot(poly,"LineStyle","-","FaceColor","g");
    title('ft+1^*');
    axis equal
    fig6=subplot(2, 3, 6);
    plot(fig6,x(trans_idx),y(trans_idx),'-ro');
    axis equal
    fprintf("find ft+1^*,fst,idx=%d,ft+1^*,idx=%d\n",idxs,trans_idx)
    %add ft+1^* to transmit queue
    if(imSetT.num<tran_num)
        imSetT.num=imSetT.num+1;
        imSetT.idx(imSetT.num)=trans_idx;
        fprintf("add ft+1^* to transmit queue,idx=%d\n",trans_idx)
        fprintf("--------------------------------------\n")
    else
        send_idx=imSetT.idx(1);
        %����洫��һ��ͼ��
        imSetS.num=imSetS.num+1;
        imSetS.idx(imSetS.num)=send_idx;
        fprintf("send image to ground station,idx=%d\n",send_idx)
        fprintf("--------------------------------------\n")
        copyfile(['imageFile/',T.img{send_idx}],['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+img_num),'/',T.img{send_idx}])
        %������м���һ��ͼƬ
        imSetT.idx(1:end-1)=imSetT.idx(2:end);
        imSetT.idx(end)=trans_idx;        
        fprintf("add ft+1^* to transmit queue,idx=%d\n",trans_idx)

    end
    % move ft+1* and befor image out of buffer
    for k=1:imSetV.num
        if(ft_i+k>imSetV.num)
            imSetV.idx(k)=0;
        else
            imSetV.idx(k)=imSetV.idx(ft_i+k);
        end
    end
    imSetV.num=buff_num-ft_i;
end
%ͼ���ȡ������������е�ͼƬ�����䵽����
fprintf("Finally send image to ground station idx= ");
for i=2:imSetT.num
    imSetS.num=imSetS.num+1;
    send_idx=imSetT.idx(i);
    imSetS.idx(imSetS.num)=send_idx;
    fprintf("%d ",imSetT.idx(i));
    copyfile(['imageFile/',T.img{imSetT.idx(i)}],['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+30),'/',T.img{imSetT.idx(i)}])
end
fprintf("\n");
%�Ѵ����ͼƬIDд��txt�ļ�
fp=fopen(['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+30),'/img_idx.txt'],'wt');
for i=1:imSetS.num
    fprintf(fp,"%d, ",imSetS.idx(i)+Idx0);
end
fclose(fp);


