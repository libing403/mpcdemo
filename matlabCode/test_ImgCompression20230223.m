clc;
clear;
close("all")
T_f = 'gpsData.mat';
gpsData = load(T_f);
T = gpsData.T;

%���ж���
buff_num=5;%ͼ��ɼ���buffer��С
tran_num=5;%������еĴ�С
img_num=30;%�����в���������ͼ���С
%��ȡͼ��buffer�ļ���V
imSetV.num=buff_num;% video buffer
imSetV.idx=zeros(imSetV.num,1);
% transmit������еļ���T
imSetT.num=1;%��ʼһ��ͼ��
imSetT.idx=zeros(imSetV.num,1);%���ͼ����±�
imSetT.idx(1)=1;
%���䵽����վ��ͼ���Ӽ�S
imSetS.num=0;%��ʼ0��ͼ��
imSetS.idx(1)=0;
AMs=1;%��ѡ���ͼ���Ӽ�S�����������
AMs_max=1;%��ʱ�洢�������������
%��ʼ������
s=1;%H��������Ų���
alpha=1;gama=1;%��ʽ4�Ĳ���
degradation=1;%ͼ���ؽ���%1
delta=1;      %��ʽ5����
belta=1; lamda=0.1;J=1; %��ʽ6����
sumAMs=1;%��ѡ���ͼ���Ӽ�S���ۺ�Ч��ֵ   
sumQ=0;UMs=1;UMs_max=1;%��ʽ6������ʼ��
poly=0;

fig1=subplot(1, 3, 1); axis equal
fig2=subplot(1, 3, 2); axis equal
fig3=subplot(1, 3, 3); axis equal

for idx=2:imSetV.num:img_num-imSetV.num-1
    
    %buffer�д洢buff_num��ͼ��
    for k=1:imSetV.num
        imSetV.idx(k)=idx+k-1;
    end
    %�Ӵ������ѡ����Сŷ�������fst
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
        %����H����
        t=calc_displacement(imSetT.az, imSetT.mindist,(flyH1+flyH2)/2);
        % homography transformation matrix
        H=calc_hom_transform(az,t,s);  
        %�����ص����
        A = imread(['imageFile/',T.img{idxs}]);
        B = imread(['imageFile/',T.img{idxt}]);  
        gray_imgB = rgb2gray(B);
        B_area = size(gray_imgB, 1) * size(gray_imgB, 2);
        Aft=1;%ÿ��ͼƬ��������ͬ����һ���������1
        [polyout,area]=overlap_area(A,B,H);
        overlap=area/B_area;%�ص������һ��
        %��������ft+1�����������������ݹ�ʽ4
        AMs_tmp=calc_mosaics_area(AMs,Aft,overlap,alpha,gama);
        %����ͼ�����
        Dt=calc_image_entropy(B);
        %����ͼ���ؽ������PSNR,
        Pt=calc_degradation_psnr(degradation);
        %�����������
        Bt=calc_bandwidth(gray_imgB,degradation);
        %����Ч��ֵ��eq(5)
%         Qt=Pt-delta*Bt;
        Qt=0;
        %�����ۼ��ۺ�Ч��ֵ,eq(6)    
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
        %��ʾͼ��
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
    %���²���
    fprintf("�ҵ�mosaic��� ft,idx=%d,ft+1,idx=%d\n",imSetT.minidx,trans_idx)
%     pause(0.5)
    UMs=UMs_max;
    Ams=UMs_AMs;
    sumQ=UMs_sumQ;
    %��������������һ��ͼƬ,
    if(imSetT.num<tran_num)
        imSetT.num=imSetT.num+1;
        imSetT.idx(imSetT.num)=trans_idx;
        fprintf("������м���ft+1^*,idx=%d\n",trans_idx)
        fprintf("--------------------------------------\n")
    else
        send_idx=imSetT.idx(1);
        imSetT.idx(1:end-1)=imSetT.idx(2:end);
        imSetT.idx(end)=trans_idx;        
        fprintf("������м���ft+1^*,idx=%d\n",trans_idx)
        %����洫��һ��ͼ��
        imSetS.num= imSetS.num+1;
        imSetS.idx(imSetS.num)=send_idx;
        fprintf("�����վ����,idx=%d\n",send_idx)
        fprintf("--------------------------------------\n")
       copyfile(['imageFile/',T.img{send_idx}],['img_trans/',T.img{send_idx}])
    end
end
%ͼ���ȡ������������е�ͼƬ�����䵽����
imSetS.idx(imSetS.num+1:imSetS.num+tran_num)=imSetT.idx;
fprintf("��������վ����idx= ");
for i=1:imSetT.num
    fprintf("%d ",imSetT.idx(i));
    copyfile(['imageFile/',T.img{imSetT.idx(i)}],['img_trans/',T.img{imSetT.idx(i)}])
end
fprintf("\n");


