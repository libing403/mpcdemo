clc;
clear;
close("all")
T_f = 'gpsData.mat';
gpsData = load(T_f);
Idx0=60;
T = gpsData.T(Idx0+1:Idx0+30,:);
%队列定义
buff_num=3;%图像采集的buffer大小
tran_num=10;%传输队列的大小
img_num=30;%程序中测试数据总图像大小
%获取图像buffer的集合V
imSetV.num=0;% video buffer
imSetV.idx=zeros(imSetV.num,1);
% transmit传输队列的集合T
imSetT.num=1;%初始一张图像
imSetT.idx=zeros(imSetV.num,1);%存放图像的下标
imSetT.idx(1)=1;
%传输到地面站的图像子集S
imSetS.num=0;%初始0张图像
imSetS.idx(1)=0;
trans_idx=0;
AMs=1;%已选择的图像子集S的马赛克面积
UMs_AMs=1;
UMs_sumQ=0;
AMs_max=0;%临时存储最大的马赛克面积
%初始化参数
s=1;%H矩阵的缩放参数，eq2
alpha=1;%新增图片的马赛克贡献值,eq4，
gama=0.9;%eq44的参数，重叠面积对马赛克面积的影响，认为是高估的
degradation=1;%eq5参数图像熵降低%1
delta=1.2;      %eq5参数，带宽对图像质量的影响
lamda=0.8;    %eq6,子集数量对组合效用值的贡献
belta=1;      %eq6,图像质量对组合效用值的贡献
J=1; %qq6,参数
sumAMs=1;%已选择的图像子集S的综合效用值   
sumQ=0;UMs=0;UMs_max=0;%公式6变量初始化
poly=0;
fig1=subplot(2, 3, 1);
fig2=subplot(2, 3, 2);
fig3=subplot(2, 3, 3);
fig4=subplot(2, 3, 4); hold on;axis equal;
fig5=subplot(2, 3, 5);hold on;axis equal;
fig6=subplot(2, 3, 6);hold on;axis equal;
Ns=0;
ft_i=0;%从buffer中取出的序号
Vnum=1;%累计已加入buffer的图片数量
flyH=0;
idxt=0;
idxs=0;
az=0;
%计算gps轨迹
for i=1:img_num
    lat = T.lat(i); % latitude of point 2
    lon = T.lon(i); % longitude of point 2
    alt = T.alt(i);
    [x(i),y(i),z(i)]=calc_cordinate(lat,lon,alt);
end 
c41=plot(fig4,x,y,'-b.');%gps轨迹
plot(fig5,x,y,'-b.');%gps轨迹
plot(fig5,x(1),y(1),'-rs');%传输队列初始状态有一张图片
plot(fig6,x,y,'-b.');%gps轨迹
plot(fig6,x(1),y(1),'-ro');%第一张图片向地面站发送

%预测压缩
while(Vnum<img_num )
    %put image to buffer
    if(imSetV.num<buff_num)
        n=buff_num-imSetV.num;
        idx1=Vnum+1;%放在传输队列里
        idx2=Vnum+n;
        if(idx2>img_num)%最后加入的图像超过了给定的数量
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
        overlap=area/B_area;%重叠面积归一化
        %计算增加ft+1后的马赛克面积，根据公式4
        AMs_tmp=calc_mosaics_area(AMs,Aft,overlap,alpha,gama);
        %jpeg compression
        compr_file=calc_jpeg_compression(A,1);
        compr_img=imread(compr_file);
        Pt=calc_psnr(A,compr_img);
%         %计算图像的熵
%         Dt=calc_image_entropy(B);
%         %计算图像熵降级后的PSNR,
%         Pt=calc_degradation_psnr(degradation);
%         %计算网络带宽
        Bt=calc_bandwidth(gray_imgB);
        %计算效用值，eq(5)
        Qt=Pt-delta*Bt;
        %计算累计综合效用值,eq(6)    
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
        %向地面传输一张图像
        imSetS.num=imSetS.num+1;
        imSetS.idx(imSetS.num)=send_idx;
        fprintf("send image to ground station,idx=%d\n",send_idx)
        fprintf("--------------------------------------\n")
        copyfile(['imageFile/',T.img{send_idx}],['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+img_num),'/',T.img{send_idx}])
        %向传输队列加入一张图片
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
%图像获取结束，传输队列的图片都传输到地面
fprintf("Finally send image to ground station idx= ");
for i=2:imSetT.num
    imSetS.num=imSetS.num+1;
    send_idx=imSetT.idx(i);
    imSetS.idx(imSetS.num)=send_idx;
    fprintf("%d ",imSetT.idx(i));
    copyfile(['imageFile/',T.img{imSetT.idx(i)}],['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+30),'/',T.img{imSetT.idx(i)}])
end
fprintf("\n");
%把传输的图片ID写入txt文件
fp=fopen(['img_trans_',num2str(Idx0+1),'_',num2str(Idx0+30),'/img_idx.txt'],'wt');
for i=1:imSetS.num
    fprintf(fp,"%d, ",imSetS.idx(i)+Idx0);
end
fclose(fp);


