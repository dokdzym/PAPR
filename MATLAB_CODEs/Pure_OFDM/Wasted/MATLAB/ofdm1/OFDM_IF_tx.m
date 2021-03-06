binary  = InputPort1.Sequence; %将Optisystem输入数据1的序列赋值到binary变量
RF_signal_sin = InputPort2.Sampled.Signal; %将Optisystem输入数据2采样序列赋值到RF_signal_sin变量
RF_length=length(RF_signal_sin);%求出RF_signal_sin变量的长度

global pilot_signal; 
global data_after; 
OutputPort1=InputPort1;
Bitrate =Parameter0;%2.5GHz
Q =Parameter1;% 采样比特=64 
G=1/4       
Tu=length(binary)/Bitrate;
fc=Bitrate;
Rs=Q*Bitrate;
t=1/Rs:1/Rs:Tu;

data_in=QAM_code4(binary);%4QAM  1.25GHz
data_tt = data_in(1:256);
data_after =data_in(257:512);
pilot_signal = data_tt(1:8:256);%取出32个导频信号
size_fft=256;     % 进行FFT/IFFT的长度=64
carriers  = ifft(data_tt,size_fft)*size_fft;%IFFT，完成OFDM调制
data_xx = [carriers(193:256),carriers ,zeros(1,192)];%添加循环前缀和保护间隔
uu=interp(data_xx,2*Q);%进行线性插值，达到65536，与optisystem匹配
fff=exp(1i*2*pi*fc.*t);
uu_info=real(uu.*fff);%进行中频调制
OutputPort1 = InputPort2;
for i=1:RF_length
    OutputPort1.Sampled.Signal(i)  =uu_info(i);%输出结果到optisystem
end
