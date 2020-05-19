clear all;
clc;
SampleRateDefault=92e9;
%% parameter definition for QPSK modulation
BaudRateDefault1=2e9; %baud rate
M1 = 4; % size of signal constellation
BitsPerSymbol1=log2(M1);% number of bits per symbol
BitRateDefault1=BaudRateDefault1*BitsPerSymbol1;
TimeWindow1=BitsPerSymbol1*512/BitRateDefault1;% 2^9=512 symbols
SamplePerSymbol1=SampleRateDefault/BaudRateDefault1; % sample points per QAM symbol
% NumOfBits=BitRateDefault*TimeWindow; %number of bits before oversampling
% NumOfBits=length(inputI.band.E); % length before oversampling
samplePerBit1=SampleRateDefault/BitRateDefault1;% sample points per bit

%% parameter definition for 16QAM modulation
BaudRateDefault2=2e9; %baud rate
M2 = 16; % size of signal constellation
BitsPerSymbol2=log2(M2);% number of bits per symbol
BitRateDefault2=BaudRateDefault2*BitsPerSymbol2;
TimeWindow2=BitsPerSymbol2*512/BitRateDefault2;% 2^9=512 symbols
SamplePerSymbol2=SampleRateDefault/BaudRateDefault2; % sample points per QAM symbol
% NumOfBits=BitRateDefault*TimeWindow; %number of bits before oversampling
% NumOfBits=length(inputI.band.E); % length before oversampling
samplePerBit2=SampleRateDefault/BitRateDefault2;% sample points per bit

%% signal source for QPSK modulation
n1=BitRateDefault1*TimeWindow1;% number of bits to process
x1 = randint(n1,1,2);
% save D:\VPIfudan\data\x.dat x  -ascii;
figure(1);
stem (x1, 'filled');
title ('Random binary sequence for QPSK');
xlabel('bit index');ylabel('binary value');
%% signal source for 16QAM modulation
n2=BitRateDefault2*TimeWindow2;% number of bits to process
x2 = randint(n2,1,2);
% save D:\VPIfudan\data\x.dat x  -ascii;
figure(2);
stem (x2, 'filled');
title ('Random binary sequence for 16QAM');
xlabel('bit index');ylabel('binary value');

%% bit-to-symbol mapping for QPSK modulation and 16QAM modulation, respectively
xsym1=bi2de(reshape(x1,BitsPerSymbol1,length(x1)/BitsPerSymbol1).','left-msb');
xsym2=bi2de(reshape(x2,BitsPerSymbol2,length(x2)/BitsPerSymbol2).','left-msb');
% save D:\VPIfudan\data\xsym.dat xsym  -ascii;

figure(3);
stem (xsym1, 'filled');
title ('Random symbols for QPSK');
xlabel('symbol index');ylabel('integer value');

figure(4);
stem (xsym2, 'filled');
title ('Random symbols for 16QAM');
xlabel('symbol index');ylabel('integer value');

%% QPSK modulation and 16QAM modulation, respectively

y1=modulate(modem.qammod(M1),xsym1);
y2=modulate(modem.qammod(M2),xsym2);
figure(5);
plot(y1,'r.','MarkerSize',30);
maxAxis=max(abs(y1)).*1.2;
axis([-maxAxis maxAxis -maxAxis maxAxis]);
title('QPSK constellation');
set(gca,'FontSize',23,'FontWeight','b');
grid on;

figure(6);
plot(y2,'r.','MarkerSize',30);
maxAxis=max(abs(y2)).*1.2;
axis([-maxAxis maxAxis -maxAxis maxAxis]);
title('16QAM constellation');
set(gca,'FontSize',23,'FontWeight','b');
grid on;




%% oversample for QPSK modulation and 16QAM constellation

output1=zeros(512*SamplePerSymbol1,1); %10倍的过采样
for i=1:1:512
    output1(i*SamplePerSymbol1-[0:SamplePerSymbol1-1])=y1(i); 
end

output2=zeros(512*SamplePerSymbol2,1); %10倍的过采样
for i=1:1:512
    output2(i*SamplePerSymbol2-[0:SamplePerSymbol2-1])=y2(i); 
end

figure(7);
SymbolNum1 = length(output1);
specx1=20*log10(abs(fftshift(fft(output1))));
x1=(-SymbolNum1/2:1:SymbolNum1/2-1)*(SampleRateDefault/1e9)/(SymbolNum1);
plot(x1,specx1);
xlabel('Frequency (GHz)');
ylabel('Power (dBm)');
title('power spectrum before LPF for QPSK');

figure(8);
SymbolNum2 = length(output2);
specx2=20*log10(abs(fftshift(fft(output2))));
x2=(-SymbolNum2/2:1:SymbolNum2/2-1)*(SampleRateDefault/1e9)/(SymbolNum2);
plot(x2,specx2);
xlabel('Frequency (GHz)');
ylabel('Power (dBm)');
title('power spectrum before LPF for 16QAM');

%% LPF for QPSK and 16QAM
FrequencySpace1=SampleRateDefault/SymbolNum1;
% TimeSpace=1/SampleRateDefault;
% TimeVector=(0:TimeSpace:TimeSpace*(SymbolNum-1));
FrequencyVector1 = -SampleRateDefault/2 : FrequencySpace1 : ...
    SampleRateDefault/2-FrequencySpace1;  % Single side band Frequency vector in Hz
stopband1=1;
Filterband1=2*pi*BaudRateDefault1*stopband1;

[b1,a1]=besself(5,Filterband1);
h1=freqs(b1,a1,2*pi*FrequencyVector1);
specdata1=fft(output1);
specpr1=fftshift(specdata1);
specpr1=(specpr1.').*h1;
output1=ifft(fftshift(specpr1));

FrequencySpace2=SampleRateDefault/SymbolNum2;
% TimeSpace=1/SampleRateDefault;
% TimeVector=(0:TimeSpace:TimeSpace*(SymbolNum-1));
FrequencyVector2 = -SampleRateDefault/2 : FrequencySpace2 : ...
    SampleRateDefault/2-FrequencySpace2;  % Single side band Frequency vector in Hz
stopband2=1;
Filterband2=2*pi*BaudRateDefault2*stopband2;
[b2,a2]=besself(5,Filterband2);
h2=freqs(b2,a2,2*pi*FrequencyVector2);
specdata2=fft(output2);
specpr2=fftshift(specdata2);
specpr2=(specpr2.').*h2;
output2=ifft(fftshift(specpr2));

% specx=20*log10(abs(fftshift(fft(output1))));
% x=(-SymbolNum/2:1:SymbolNum/2-1)*(SampleRateDefault/1e9)/(SymbolNum);
% figure(6);plot(x,specx);
% xlabel('Frequency (GHz)');
% ylabel('Power (dBm)');
% % title('power spectrum after LPF');

%% upconversion process 
%for QPSK 
TimeSpace1=1/SampleRateDefault;
TimeVector1=(0:TimeSpace1:TimeSpace1*(SymbolNum1-1));
IF1=40e9;
IFphase1=2*pi*IF1*TimeVector1;
% output=output.';
outputE1=output1.*exp(j*IFphase1);

%for 16QAM 
TimeSpace2=1/SampleRateDefault;
TimeVector2=(0:TimeSpace2:TimeSpace2*(SymbolNum2-1));
IF2=38e9;
IFphase2=-2*pi*IF2*TimeVector2;
% output=output.';
outputE2=output2.*exp(j*IFphase2);

figure(9);
x=(-SymbolNum1/2:1:SymbolNum1/2-1)*(SampleRateDefault/1e9)/(SymbolNum1);
specx=20*log10(abs(fftshift(fft(outputE1))));
plot(x,specx);
axis([-46 46 -150 100]);
xlabel('Frequency (GHz)','fontsize',20,'fontweight','b');
ylabel('Power (dBm)','fontsize',20,'fontweight','b');
set(gca,'FontSize',23,'FontWeight','b');
title('power spectrum for QPSK SSB');

figure(10);
x=(-SymbolNum2/2:1:SymbolNum2/2-1)*(SampleRateDefault/1e9)/(SymbolNum2);
specx=20*log10(abs(fftshift(fft(outputE2))));
plot(x,specx);
axis([-46 46 -150 100]);
xlabel('Frequency (GHz)','fontsize',20,'fontweight','b');
ylabel('Power (dBm)','fontsize',20,'fontweight','b');
set(gca,'FontSize',23,'FontWeight','b');
title('power spectrum for 16QAM SSB');


output_real=real(outputE1)+real(outputE2);
output_imag=imag(outputE1)+imag(outputE2);
specx=20*log10(abs(fftshift(fft(output_real))));
figure(11);
x=(-SymbolNum1/2:1:SymbolNum1/2-1)*(SampleRateDefault/1e9)/(SymbolNum1);
plot(x,specx);
axis([-46 46 -150 100]);
xlabel('Frequency (GHz)','fontsize',20,'fontweight','b');
ylabel('Power (dBm)','fontsize',20,'fontweight','b');
set(gca,'FontSize',23,'FontWeight','b');
title('power spectrum for dual SSB');


%% produce RF electrical drive for MZM
% a=real(outputnew2);
% % driveReal=a/max(abs(a));
% b=imag(outputnew2);
% % driveImag=b/max(abs(b));
[aI bI]=mapminmax(output_real,-128,127);
fidI = fopen('Icomponent_2GBd_40GHz_QPSK_2Gbaud_38GHz_16QAM_92GSa.txt', 'w');
fprintf(fidI, '%6.0f\n', aI);
fclose(fidI);
[cI dI]=mapminmax(output_imag,-128,127);
fidI = fopen('Qcomponent_2GBd_40GHz_QPSK_2Gbaud_38GHz_16QAM_92GSa.txt', 'w');
fprintf(fidI, '%6.0f\n', cI);
fclose(fidI);







