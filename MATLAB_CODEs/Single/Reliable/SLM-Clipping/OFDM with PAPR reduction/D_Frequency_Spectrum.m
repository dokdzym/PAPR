function y4=D_Frequency_Spectrum()
clear all;
clc;
close all;
fsMhz=input('Enter total frequency range(in MHz)= ');
fcut=input('Enter Cutoff frequency(in MHz)= ');
N=512;             %total fequency range
T=32;              %frequency range of one signal     
noofcarriers=floor(N/T);

for n=1:T
    for k=1:noofcarriers
        g(k,n)=exp(i*2*pi*k*n/noofcarriers);
    end;
end;

f=(-N/2:N/2-1)/N*fsMhz;
for k=1:noofcarriers
    X(k,:)=abs(fft(g(k,:),N));
    X(k,:)=fftshift(X(k,:));
      plot(f,X(k,:));
    hold all;
    end;

    title('Frequency spetrum of original OFDM'),xlabel('Frequency in MHz'),ylabel('FFT');
    figure;
for k=1:noofcarriers
for p=1:N
   pp=abs(p-N/2);
   if(pp/N*fsMhz>fcut/2)
       X(k,p)=0;
end;    
end;
    plot(f,X(k,:));
    hold all;

end;

title('Frequency spetrum of band limited OFDM'),xlabel('Frequency in MHz'),ylabel('FFT');

disp('Total of carriers= ');
disp(noofcarriers);