binary  = InputPort1.Sequence; %��Optisystem��������1�����и�ֵ��binary����
RF_signal_sin = InputPort2.Sampled.Signal; %��Optisystem��������2�������и�ֵ��RF_signal_sin����
RF_length=length(RF_signal_sin);%���RF_signal_sin�����ĳ���

global pilot_signal; 
global data_after; 
OutputPort1=InputPort1;
Bitrate =Parameter0;%2.5GHz
Q =Parameter1;% ��������=64 
G=1/4       
Tu=length(binary)/Bitrate;
fc=Bitrate;
Rs=Q*Bitrate;
t=1/Rs:1/Rs:Tu;

data_in=QAM_code4(binary);%4QAM  1.25GHz
data_tt = data_in(1:256);
data_after =data_in(257:512);
pilot_signal = data_tt(1:8:256);%ȡ��32����Ƶ�ź�
size_fft=256;     % ����FFT/IFFT�ĳ���=64
carriers  = ifft(data_tt,size_fft)*size_fft;%IFFT�����OFDM����
data_xx = [carriers(193:256),carriers ,zeros(1,192)];%����ѭ��ǰ׺�ͱ������
uu=interp(data_xx,2*Q);%�������Բ�ֵ���ﵽ65536����optisystemƥ��
fff=exp(1i*2*pi*fc.*t);
uu_info=real(uu.*fff);%������Ƶ����
OutputPort1 = InputPort2;
for i=1:RF_length
    OutputPort1.Sampled.Signal(i)  =uu_info(i);%��������optisystem
end