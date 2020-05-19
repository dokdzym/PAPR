function y2=B_OFDM()
clc;
clear all;
close all;
N=input('Enter the number of transmitted symbols(Power of 2)=');
r=ceil(4*rand(1,N));        %Generation of random data to be transmitted
for p=1:N                   %loop for qpsk baseband genaration
bcos(p)=cos((2*r(1,p)-1)*pi/4);
bsin(p)=sin((2*r(1,p)-1)*pi/4);
bexp(1,p)=bcos(p)+bsin(p)*i;                                            
end;
nz=input('Enter the number of zeros to be padded in middle= ');
bexp1=[bexp(1:N/2) zeros(1,nz) bexp(N/2+1:N)];                            %zero padding
ibexp=ifft(bexp1);                                                                   
z=fft(ibexp);
q=fftshift(z);
mag=abs(q);
pow=mag.^2;                                                                              %for power
figure,plot(pow),title('OFDM'),xlabel('Fft samples'),ylabel('power');                %linear plot
figure,plot(10*log(pow)),title('OFDM'),xlabel('Fft samples'),ylabel('power in db');  %dB plot