clc;
clear;
close("all")
T_f = 'gpsData.mat';
gpsData = load(T_f);
T = gpsData.T;

%队列定义
buff_num=5;%图像采集的buffer大小
tran_num=5;%传输队列的大小
img_num=30;%程序中测试数据总图像大小
%获取图像buffer的集合V
imSetV.num=buff_num;% video buffer
imSetV.idx=zeros(imSetV.num,1);
% transmit传输队列的集合T
imSetT.num=1;%初始一张图像
imSetT.idx=zeros(imSetV.num,1);%存放图像的下标
imSetT.idx(1)=1;
%传输到地面站的图像子集S
imSetS.num=0;%初始0张图像
imSetS.idx(1)=0;
AMs=1;%已选择的图像子集S的马赛克面积
AMs_max=1;%临时存储最大的马赛克面积
%初始化参数
s=1;%H矩阵的缩放参数
alpha=1;gama=1;%公式4的参数
degradation=1;%图像熵降低%1
delta=1;      %公式5参数
belta=1; lamda=0.1;J=1; %公式6参数
sumAMs=1;%已选择的图像子集S的综合效用值   
sumQ=0;UMs=1;UMs_max=1;%公式6变量初始化
poly=0;

fig1=subplot(1, 3, 1); axis equal
fig2=subplot(1, 3, 2); axis equal
fig3=subplot(1, 3, 3); axis equal

for idx=2:imSetV.num:img_num-imSetV.num-1
    
    %buffer中存储buff_num张图像
    for k=1:imSetV.num
        imSetV.idx(k)=idx+k-1;
    end
    %从传输队列选出最小欧拉距离的fst
    AMs_max=0;
    for idx_V=1:imSetV.num
         kt=imSetV.idx(idx_V);
         imSetT.mindist=1.0e5;
         imSetT.minidx=-1;
         imSetV.mindist=1.0e5;
         imSetV.minidx=-1;
        for idx_T=1:imSetT.num
            ks=imSetT.idx(idx_T);
            lat1 = T.lat(ks); % latitude of point 1
            lon1 = T.lon(ks); % longitude of point 1
            lat2 = T.lat(kt); % latitude of point 2
            lon2 = T.lon(kt); % longitude of point 2
            alt1=T.alt(ks);
            flyH1=T.flyH(ks);
            alt2=T.alt(kt);
            flyH2=T.flyH(kt);
            [az,dist]=calc_euclidean_distance(lat1,lon1,lat2,lon2,alt1,alt2);
            if(dist<imSetT.mindist)
                imSetV.mindist=dist;
                imSetV.minidx=kt;
                imSetT.mindist=dist;
                imSetT.minidx=ks;
                imSetT.az=az;
            end 
        end
        idxt=imSetV.minidx;
        idxs=imSetT.minidx;
        %计算H矩阵
        t=calc_displacement(imSetT.az, imSetT.mindist,(flyH1+flyH2)/2);
        % homography transformation matrix
        H=calc_hom_transform(az,t,s);  
        %计算重叠面积
        A = imread(['imageFile/',T.img{idxs}]);
        B = imread(['imageFile/',T.img{idxt}]);  
        gray_imgB = rgb2gray(B);
        B_area = size(gray_imgB, 1) * size(gray_imgB, 2);
        Aft=1;%每个图片的像素相同，归一化面积都是1
        [polyout,area]=overlap_area(A,B,H);
        overlap=area/B_area;%重叠面积归一化
        %计算增加ft+1后的马赛克面积，根据公式4
        AMs_tmp=calc_mosaics_area(AMs,Aft,overlap,alpha,gama);
        %计算图像的熵
        Dt=calc_image_entropy(B);
        %计算图像熵降级后的PSNR,
        Pt=calc_degradation_psnr(degradation);
        %计算网络带宽
        Bt=calc_bandwidth(gray_imgB,degradation);
        %计算效用值，eq(5)
%         Qt=Pt-delta*Bt;
        Qt=0;
        %计算累计综合效用值,eq(6)    
        sumAMs_tmp=sumAMs+AMs;
        sumQ_tmp=sumQ+Qt;
        Ns=imSetS.num+1;
        UMs_tmp=sumAMs+lamda*Ns+belta/J*sumQ;  
        if(AMs_tmp>AMs_max)
            AMs_max=AMs_tmp;
            UMs_max=UMs_tmp;
            UMs_AMs=AMs_tmp;
            UMs_sumQ=sumQ_tmp;
            trans_idx=kt;
            poly=polyout;
        end
        %显示图像
        pause(0.001)
        cla(fig1);
        cla(fig2);
        fig1=subplot(1, 3, 1);
        imshow(A);
        title('ft');
        axis equal

        fig2=subplot(1, 3, 2);
        imshow(B);
        hold on
        plot(polyout,"LineStyle","-","FaceColor","g");
        title('ft+1');
        axis equal
    end
    
    B = imread(['imageFile/',T.img{trans_idx}]);  
    cla(fig3)
    fig3=subplot(1, 3, 3);
    imshow(B);
    hold on
    plot(poly,"LineStyle","-","FaceColor","g");
    title('ft+1^*');
    axis equal
    %更新参数
    fprintf("找到mosaic最大 ft,idx=%d,ft+1,idx=%d\n",imSetT.minidx,trans_idx)
%     pause(0.5)
    UMs=UMs_max;
    Ams=UMs_AMs;
    sumQ=UMs_sumQ;
    %往传输队列里添加一张图片,
    if(imSetT.num<tran_num)
        imSetT.num=imSetT.num+1;
        imSetT.idx(imSetT.num)=trans_idx;
        fprintf("传输队列加入ft+1^*,idx=%d\n",trans_idx)
        fprintf("--------------------------------------\n")
    else
        send_idx=imSetT.idx(1);
        imSetT.idx(1:end-1)=imSetT.idx(2:end);
        imSetT.idx(end)=trans_idx;        
        fprintf("传输队列加入ft+1^*,idx=%d\n",trans_idx)
        %向地面传输一张图像
        imSetS.num= imSetS.num+1;
        imSetS.idx(imSetS.num)=send_idx;
        fprintf("向地面站传输,idx=%d\n",send_idx)
        fprintf("--------------------------------------\n")
       copyfile(['imageFile/',T.img{send_idx}],['img_trans/',T.img{send_idx}])
    end
end
%图像获取结束，传输队列的图片都传输到地面
imSetS.idx(imSetS.num+1:imSetS.num+tran_num)=imSetT.idx;
fprintf("最后向地面站传输idx= ");
for i=1:imSetT.num
    fprintf("%d ",imSetT.idx(i));
    copyfile(['imageFile/',T.img{imSetT.idx(i)}],['img_trans/',T.img{imSetT.idx(i)}])
end
fprintf("\n");


