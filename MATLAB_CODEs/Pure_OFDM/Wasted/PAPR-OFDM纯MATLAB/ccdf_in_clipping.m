clear all;
clc;


fl=512;  % ����FFT����
Num=100;   
ca=256; %���ò��д�������ز�����
NN=1:.1:14; % CCDF������ֵ
ccdf0=zeros(1,131);
ccdf1=ccdf0;
ccdf2=ccdf0;
ccdf3=ccdf0;
ccdf4=ccdf0;

 for i=1:Num   
Signal((i*(i-1)/2)*ca*4+1:(i*(i-1)/2+i)*ca*4)=rand(1,ca*i*4)>0.5;%����0��1 ������У�������Ϊca*(1+Num)*Num*2
 end

 Ns=(1+Num)*Num;  %����һ��֡�ṹ��OFDM�źŵĸ���
 
for i=1:ca
    for j=1:Ns*2
        SigPara(i,j)=Signal(i*j);%�����任
    end
end
%QPSK���ƣ������ݷ�Ϊ����ͨ��
for j=1:Ns
    ich(:,j)=SigPara(:,2*j-1);
    qch(:,j)=SigPara(:,2*j);
end
kmod=1./sqrt(2);
ich1=ich.*kmod;
qch1=qch.*kmod;
x=ich1+qch1.*sqrt(-1); 

x1=zeros(4*ca,Ns);   %   ������ 
   for i=1:ca/2
   x1(i,:)=x(i,:);
   x1(i+7/2*ca,:)=x(i+ca/2,:);
   end
   
 y=ifft(x,[],2); %Ƶ�����ݱ�ʱ��
y1=(abs(y)).^2;  
power_average=mean(y1);
max_power=max(y1);
papr0=10*log10(max_power./power_average);  % ԭ�����ź�

% �޷�
le=0.5*10^-2;  %�޷���ƽģֵ  
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




% �޷�
le=0.8*10^-2;  %�޷���ƽģֵ 
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



% �޷�
le=1*10^-2;  %�޷���ƽģֵ 
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


 

% �޷�
le=1.5*10^-2;  %�޷���ƽģֵ  
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
title('CCDF����')
xlabel('papr(dB)'),ylabel('ccdf')
legend('ԭ��','le=0.5*10^-2','le=0.8*10^-2','le=1*10^-2')