clc;
clear all;
close all;
N=128;
x= randi([0,1],1,512);
M=16;
k=log2(M);
r=reshape(x,length(x)/k,k);
v=bi2de(r,'left-msb');
m=qammod(v,M);
y_if=ifft(m,N);
x=transpose(y_if);
x_abs=abs(x);
subplot(3,1,1);
stem(x_abs)
title('original sequece');
papr=10*log(max(x_abs.^2)/mean(x_abs.^2));
disp('PAPR of original signal in dB');
disp(papr);
t=0.2;
for i=1:1:N
if x_abs(i)>t
  
    x1(i)=x_abs(i)-t;
else
    x1(i)=0;
end
end
x3=abs(x1);
x4=x_abs-x3;

papr1=10*log(max(x4.^2)/mean(x4.^2));
disp('PAPR of cliiped seq in dB');
disp(papr1);
subplot(3,1,2);
stem(x1)
title('Peak Sequence');
subplot(3,1,3);

stem(x4)
title('Clipped signal');

error=(abs(x_abs-x4)).^2;
MMSE=(sum(error))/N;
figure;
plot(x_abs-x1)
title('Error signal');
disp('MMSE=');
disp(MMSE);

%===========sample o/p=================
% PAPR of original signal in dB
%    20.6920
% 
% PAPR of cliiped seq in dB
%     5.6330
% 
% MMSE=
%     0.0070