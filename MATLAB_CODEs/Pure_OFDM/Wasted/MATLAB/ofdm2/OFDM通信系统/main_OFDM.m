%main_OFDM.m
%这是一个相对完整的OFDM通信系统的仿真设计，包括编码，调制，IFFT，
%上下变频，高斯信道建模，FFT，PAPR抑制，各种同步，解调和解码等模
%块，并统括系统性能的仿真验证了系统设计的可靠性。

clear all
close all
clc

%++++++++++++++++++++++++++全局变量++++++++++++++++++++++++++++++
% seq_num              表示当前帧是第几帧
% count_dds_up         上变频处的控制字的累加
% count_dds_down       下变频处的控制字的累加（整整）
% count_dds_down_tmp   下变频处的控制字的累加（小数）
% dingshi              定时同步的定位
% m_syn                记录定时同步中的自相关平台
global seq_num
global count_dds_up
global count_dds_down
global count_dds_down_tmp
global dingshi  
global m_syn
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% SNR_Pre              设定用于仿真的信噪比的初值
% interval_SNR         设定用于仿真的信噪比间隔
% frame_num            每一个信噪比下仿真的数据帧数
% err_int_final        用于计算每帧出现的误比特数
% fwc_down             设定的接收机初始载波频率控制字
% fre_offset           设定接收机初始载波频率偏移调整量（单位为Hz）
% k0                   每次进入卷积编码器的信息比特数
% G                    卷积编码的生成矩阵
SNR_Pre=-5;
interval_SNR=1;

for SNR_System=SNR_Pre:interval_SNR:5
    
frame_num=152;
dingshi=250;
err_int_final=0;
fwc_down=16.050;
fre_offset=0;
k0=1;
G=[1 0 1 1 0 1 1;1 1 1 1 0 0 1 ];

disp('--------------start-------------------');

for seq_num=1:frame_num, %frame_num 帧数
    
%+++++++++++++++++++++++以下为输入数据部分+++++++++++++++++++++++
datain=randint(1,90);     
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++以下为信道卷积编码部分+++++++++++++++++++++
encodeDATA=cnv_encd(G,k0,datain);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++信道交织编码+++++++++++++++++++++++++
interlacedata=interlacecode(encodeDATA,8,24);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++以下为QPSK调制部分+++++++++++++++++++++
QPSKdata=qpsk(interlacedata);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++生成训练序列+++++++++++++++++++++++++
if seq_num<3
trainsp_temp=seq_train();  
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++插入导频++++++++++++++++++++++++++++
PILOT=(1+j);
m_QPSKdata=QPSKdata;
data2fft_temp=[m_QPSKdata(1:8),PILOT,m_QPSKdata(9:16),PILOT,m_QPSKdata(17:24),PILOT,m_QPSKdata(25:32),PILOT,m_QPSKdata(33:40),PILOT,m_QPSKdata(41:48),m_QPSKdata(49:56),PILOT,m_QPSKdata(57:64),PILOT,m_QPSKdata(65:72),PILOT,m_QPSKdata(73:80),PILOT,m_QPSKdata(81:88),PILOT,m_QPSKdata(89:end)];
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

trainsp_temp2=[trainsp_temp,zeros(1,128)];
trainsp=[trainsp_temp2(65:256),trainsp_temp2(1:64)];

%++++++++++++++++++++++++++降PAPR矩阵变换++++++++++++++++++++++++
matix_data=nyquistimp_PS();
matrix_mult=data2fft_temp*matix_data;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data2fft2=[matrix_mult(65:128),zeros(1,128),matrix_mult(1:64)];

%++++++++++++++++++++++++++++ifft运算+++++++++++++++++++++++++++
if seq_num==1
    ifftin=trainsp;
elseif seq_num==2
    ifftin=trainsp;
else
    ifftin=data2fft2;
end
IFFTdata=fft_my(conj(ifftin)/256);
IFFTdata=conj(IFFTdata);
% figure
% plot(real(IFFTdata))
% xlabel('realIFFTdata')
% figure
% plot(imag(IFFTdata))
% xlabel('imagIFFTdata')  
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++以下为插入循环前后缀，2倍升采样+++++++++++++++
data2fir=add_CYC_upsample(IFFTdata,2);
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% +++++++++++++++++++++++++fir低通滤波++++++++++++++++++++++++++
guiyi_a=[0.0017216	0.010162	0.025512	0.028801	-0.0059219	-0.060115	-0.0496	0.091431	0.29636	0.3956	0.29636	0.091431	-0.0496	-0.060115	-0.0059219	0.028801	0.025512	0.010162	0.0017216 ];
%抽样截止频率为128kHZ,通带截止频率为20kHZ，阻带截止频率为40kHZ，带内纹波动小于1dB，带外衰减100dB
txFIRdatai=filter(guiyi_a,1,real(data2fir));
txFIRdataq=filter(guiyi_a,1,imag(data2fir));
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++发射机cic滤波++++++++++++++++++++++++++
CICidatai=cic_inter(txFIRdatai,20);
CICidataq=cic_inter(txFIRdataq,20);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++上变频++++++++++++++++++++++++++++
fwc_up=16;                     %控制字可以选择
DUCdata=up_convert_ofdm(fwc_up,CICidatai,CICidataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++高斯白噪声信道++++++++++++++++++++++++
[DUCdata,datamax]=guiyi_DUCdata(DUCdata);
awgn_data=awgn(DUCdata,SNR_System);  
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%*****************************接受机*****************************
%+++++++++++++++++++++++++++++下变频+++++++++++++++++++++++++++++
DUCdata_tmp=awgn_data;
fwc_down=fwc_down+(fre_offset*128/2560000);
r_fre_offset=2560000*((fwc_down-fwc_up)/128);
[DDCdatai,DDCdataq]=down_convert_ofdm(fwc_down,DUCdata_tmp);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++接收机cic滤波+++++++++++++++++++++++++
CICddatai=cic_deci(DDCdatai,40,40);
CICddataq=cic_deci(DDCdataq,40,40);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++fir低通滤波++++++++++++++++++++++++
guiyi_b=[ 0.019527	-0.03934	0.049055	-0.018102	-0.1003	0.5944	0.5944	-0.1003	-0.018102	0.049055	-0.03934	0.019527];
%抽样截止频率为64kHZ,通带截止频率为20kHZ，阻带截止频率为30kHZ，带内纹波动小于1dB，带外衰减60dB
rxFIRdatai=filter(guiyi_b,1,CICddatai);
rxFIRdataq=filter(guiyi_b,1,CICddataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++++量化++++++++++++++++++++++++++++
q_rxFIRdatai=sign(rxFIRdatai); 
q_rxFIRdataq=sign(rxFIRdataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++定时同步检测++++++++++++++++++++++++
if seq_num<3
time_syn(q_rxFIRdatai,q_rxFIRdataq);
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++频率同步+++++++++++++++++++++++++++
fre_offset=fre_syn(rxFIRdatai,rxFIRdataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
%+++++++++++++++++++++++++++++fft运算+++++++++++++++++++++++++++
if seq_num>2
   seq_num-2
   fftw=32+dingshi;
   rxFIRdata_syn=rxFIRdatai(fftw:fftw+255)+j*rxFIRdataq(fftw:fftw+255);
   FFTdata=fft_my(rxFIRdata_syn);
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++降PAPR逆矩阵变换++++++++++++++++++++++
fftdata_reg=[FFTdata(193:256),FFTdata(1:64)];
dematrix_data=fftdata_reg*pinv(matix_data);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++相位补偿+++++++++++++++++++++++++++
rx_qpsk_din_th=phase_comp(dematrix_data);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++QPSK解调部分++++++++++++++++++++++++
% figure
% plot(rx_qpsk_din_th,'.')
% xlabel('星座图')
datatemp4=deqpsk(rx_qpsk_din_th);
datatemp4=sign(datatemp4);
for m=1:192
    if datatemp4(m)==-1
        datatemp4(m)=1;
    elseif datatemp4(m)==1
        datatemp4(m)=0;
    end
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++信道解交织++++++++++++++++++++++++++++
interdout=interlacedecode(datatemp4,8,24);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++以下为viterbi译码部分++++++++++++++++++++++
decodeDATA=viterbi(G,k0,interdout);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++误比特统计++++++++++++++++++++++++++++
err_final=sum(abs(decodeDATA-datain)) 
err_int_final=err_int_final+err_final 
end
end
disp('------------------------------------------------------');
SNR_System
err_rate_final((SNR_System-SNR_Pre)./interval_SNR+1)=err_int_final/(90*(frame_num-2))
disp('------------------------------------------------------');

end

disp('--------------end-------------------');

SNR_System=SNR_Pre:interval_SNR:5;
figure
semilogy(SNR_System,err_rate_final,'b-*');
xlabel('信噪比/dB')
ylabel('误码率')
axis([-5,5,0,1])
grid on
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 