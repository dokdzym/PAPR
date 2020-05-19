clear all;
clc;


fl=512;  % 设置FFT长度
Num=100;   
ca=256; %设置并行传输的子载波个数
NN=1:.1:14; % CCDF的门限值
ccdf0=zeros(1,131);
ccdf1=ccdf0;
ccdf2=ccdf0;
ccdf3=ccdf0;
ccdf4=ccdf0;

 for i=1:Num   
Signal((i*(i-1)/2)*ca*4+1:(i*(i-1)/2+i)*ca*4)=rand(1,ca*i*4)>0.5;%产生0，1 随机序列，符号数为ca*(1+Num)*Num*2
 end

 Ns=(1+Num)*Num;  %设置一个帧结构中OFDM信号的个数
 
for i=1:ca
    for j=1:Ns*2
        SigPara(i,j)=Signal(i*j);%串并变换
    end
end
%QPSK调制，将数据分为两个通道
for j=1:Ns
    ich(:,j)=SigPara(:,2*j-1);
    qch(:,j)=SigPara(:,2*j);
end
kmod=1./sqrt(2);
ich1=ich.*kmod;
qch1=qch.*kmod;
x=ich1+qch1.*sqrt(-1); 

x1=zeros(4*ca,Ns);   %   过采样 
   for i=1:ca/2
   x1(i,:)=x(i,:);
   x1(i+7/2*ca,:)=x(i+ca/2,:);
   end
   
 y=ifft(x,[],2); %频域数据变时域
y1=(abs(y)).^2;  
power_average=mean(y1);
max_power=max(y1);
papr0=10*log10(max_power./power_average);  % 原来的信号

% 限幅
le=0.5*10^-2;  %限幅电平模值  
y2=y;
ccdf1=ccdf0;
for i=1:ca
    for j=1:Ns
        if abs(y(i,j))>le;
            y2(i,j)=le.*exp(angle(y(i,j))*sqrt(-1)); 
        end      
    end
end 
y3=(abs(y2)).^2;
power_average_le=mean(y3);
max_power_le=max(y3);
papr1=10*log10(max_power_le./power_average_le);




% 限幅
le=0.8*10^-2;  %限幅电平模值 
y3=y;
ccdf1=ccdf0;
for i=1:ca
    for j=1:Ns
        if abs(y(i,j))>le;
            y3(i,j)=le.*exp(angle(y(i,j))*sqrt(-1)); 
        end      
    end
end 
y4=(abs(y3)).^2;
power_average_le=mean(y4);
max_power_le=max(y4);
papr2=10*log10(max_power_le./power_average_le);



% 限幅
le=1*10^-2;  %限幅电平模值 
y5=y;
ccdf1=ccdf0;
for i=1:ca
    for j=1:Ns
        if abs(y(i,j))>le;
            y5(i,j)=le.*exp(angle(y(i,j))*sqrt(-1)); 
        end      
    end
end 
y6=(abs(y5)).^2;
power_average_le=mean(y6);
max_power_le=max(y6);
papr3=10*log10(max_power_le./power_average_le);


 

% 限幅
le=1.5*10^-2;  %限幅电平模值  
y7=y;
ccdf1=ccdf0;
for i=1:ca
    for j=1:Ns
        if abs(y(i,j))>le;
            y7(i,j)=le.*exp(angle(y(i,j))*sqrt(-1)); 
        end      
    end
end 
y8=(abs(y7)).^2;
power_average_le=mean(y8);
max_power_le=max(y8);
papr4=10*log10(max_power_le./power_average_le);









for l=1:131  % CCDF
for j=1:Ns
  if papr0(j)>NN(l);
    ccdf0(l)=ccdf0(l)+1;
    end
   if papr1(j)>NN(l);
    ccdf1(l)=ccdf1(l)+1;
   end
    if papr2(j)>NN(l);
    ccdf2(l)=ccdf2(l)+1;
    end
    if papr3(j)>NN(l);
    ccdf3(l)=ccdf3(l)+1;
    end
    
end    
end
ccdf0=ccdf0./Ns;
ccdf1=ccdf1./Ns;
ccdf2=ccdf2./Ns;
ccdf3=ccdf3./Ns;

NN=1:.1:14;
figure(1);
semilogy(NN,ccdf0,'r -',NN,ccdf1,'vb -',NN,ccdf2,'^g -',NN,ccdf3,'ok -')
title('CCDF曲线')
xlabel('papr(dB)'),ylabel('ccdf')
legend('原来','le=0.5*10^-2','le=0.8*10^-2','le=1*10^-2')