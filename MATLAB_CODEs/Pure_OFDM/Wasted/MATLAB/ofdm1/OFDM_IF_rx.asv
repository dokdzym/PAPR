RF_signal = InputPort1.Sampled.Signal; %将Optisystem输入数据采样序列赋值到RF_signal变量
RF_length=length(RF_signal_sin);
OutputPort1=InputPort1;
Bitrate =Parameter0;%2.5GHz
Q =Parameter1;% 采样比特=64 

global pilot_signal;
global data_after;
Tu=length(binary)/Bitrate;
fc=Bitrate;
Rs=Q*Bitrate;
t=1/Rs:1/Rs:Tu;
size_fft=256;   % 进行FFT/IFFT的长度=64

r_tilde=exp(-1i*2*pi*fc.*t).*RF_signal; %将序列乘以一个频率为fc的信号
[B,AA] = butter(13,3/4);
r_info=2*filter(B,AA,r_tilde); %通过带通滤波器，进行中频解调
data_r = r_info(1:2*Q:length(r_info));%进行间隔为2*Q的抽样， 与调制匹配
data_r1 = data_r(65:320);%去循环前缀保护间隔
data_r2 =fft(data_r1,size_fft)/size_fft;%FFT调制，进行OFDM解调
f_data =data_r2(1:8:256);%取出传输后的导频信号
H = f_data./pilot_signal;%求出信道
H_1 = ifft(H,32);
H_r =fft([H_1(1:16),zeros(1,224),H_1(17:32)],size_fft);%将信道变成信号的长度
data_r3 =data_r2./H_r;%进行信道估计，相位均衡
figure(1)
plot(real(data_r2),imag(data_r2),'r*');%输出均衡前的QAM输出
figure(2)
plot(real(data_r3),imag(data_r3),'k.');%输出均衡后的QAM输出
data_out1 = [data_r3,data_after];
 data_out=de_QAM_code4(data_out1);%4QAM  1.25GHz

for i=1:length(data_out)
     binary_out((Q*(i-1)+1):Q*i)=data_out(i);%将数字比特变成模拟信号
end
OutputPort1 = InputPort1;
for i=1:RF_length
    OutputPort1.Sampled.Signal(i)  =binary_out(i);%输出到optisystem
end


