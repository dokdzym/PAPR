%main_OFDM.m
%����һ�����������OFDMͨ��ϵͳ�ķ�����ƣ��������룬���ƣ�IFFT��
%���±�Ƶ����˹�ŵ���ģ��FFT��PAPR���ƣ�����ͬ��������ͽ����ģ
%�飬��ͳ��ϵͳ���ܵķ�����֤��ϵͳ��ƵĿɿ��ԡ�

clear all
close all
clc

%++++++++++++++++++++++++++ȫ�ֱ���++++++++++++++++++++++++++++++
% seq_num              ��ʾ��ǰ֡�ǵڼ�֡
% count_dds_up         �ϱ�Ƶ���Ŀ����ֵ��ۼ�
% count_dds_down       �±�Ƶ���Ŀ����ֵ��ۼӣ�������
% count_dds_down_tmp   �±�Ƶ���Ŀ����ֵ��ۼӣ�С����
% dingshi              ��ʱͬ���Ķ�λ
% m_syn                ��¼��ʱͬ���е������ƽ̨
global seq_num
global count_dds_up
global count_dds_down
global count_dds_down_tmp
global dingshi  
global m_syn
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% SNR_Pre              �趨���ڷ��������ȵĳ�ֵ
% interval_SNR         �趨���ڷ��������ȼ��
% frame_num            ÿһ��������·��������֡��
% err_int_final        ���ڼ���ÿ֡���ֵ��������
% fwc_down             �趨�Ľ��ջ���ʼ�ز�Ƶ�ʿ�����
% fre_offset           �趨���ջ���ʼ�ز�Ƶ��ƫ�Ƶ���������λΪHz��
% k0                   ÿ�ν���������������Ϣ������
% G                    �����������ɾ���
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

for seq_num=1:frame_num, %frame_num ֡��
    
%+++++++++++++++++++++++����Ϊ�������ݲ���+++++++++++++++++++++++
datain=randint(1,90);     
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++����Ϊ�ŵ�������벿��+++++++++++++++++++++
encodeDATA=cnv_encd(G,k0,datain);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++�ŵ���֯����+++++++++++++++++++++++++
interlacedata=interlacecode(encodeDATA,8,24);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++����ΪQPSK���Ʋ���+++++++++++++++++++++
QPSKdata=qpsk(interlacedata);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++����ѵ������+++++++++++++++++++++++++
if seq_num<3
trainsp_temp=seq_train();  
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++���뵼Ƶ++++++++++++++++++++++++++++
PILOT=(1+j);
m_QPSKdata=QPSKdata;
data2fft_temp=[m_QPSKdata(1:8),PILOT,m_QPSKdata(9:16),PILOT,m_QPSKdata(17:24),PILOT,m_QPSKdata(25:32),PILOT,m_QPSKdata(33:40),PILOT,m_QPSKdata(41:48),m_QPSKdata(49:56),PILOT,m_QPSKdata(57:64),PILOT,m_QPSKdata(65:72),PILOT,m_QPSKdata(73:80),PILOT,m_QPSKdata(81:88),PILOT,m_QPSKdata(89:end)];
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

trainsp_temp2=[trainsp_temp,zeros(1,128)];
trainsp=[trainsp_temp2(65:256),trainsp_temp2(1:64)];

%++++++++++++++++++++++++++��PAPR����任++++++++++++++++++++++++
matix_data=nyquistimp_PS();
matrix_mult=data2fft_temp*matix_data;
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

data2fft2=[matrix_mult(65:128),zeros(1,128),matrix_mult(1:64)];

%++++++++++++++++++++++++++++ifft����+++++++++++++++++++++++++++
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

%+++++++++++++++++++����Ϊ����ѭ��ǰ��׺��2��������+++++++++++++++
data2fir=add_CYC_upsample(IFFTdata,2);
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% +++++++++++++++++++++++++fir��ͨ�˲�++++++++++++++++++++++++++
guiyi_a=[0.0017216	0.010162	0.025512	0.028801	-0.0059219	-0.060115	-0.0496	0.091431	0.29636	0.3956	0.29636	0.091431	-0.0496	-0.060115	-0.0059219	0.028801	0.025512	0.010162	0.0017216 ];
%������ֹƵ��Ϊ128kHZ,ͨ����ֹƵ��Ϊ20kHZ�������ֹƵ��Ϊ40kHZ�������Ʋ���С��1dB������˥��100dB
txFIRdatai=filter(guiyi_a,1,real(data2fir));
txFIRdataq=filter(guiyi_a,1,imag(data2fir));
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++�����cic�˲�++++++++++++++++++++++++++
CICidatai=cic_inter(txFIRdatai,20);
CICidataq=cic_inter(txFIRdataq,20);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++�ϱ�Ƶ++++++++++++++++++++++++++++
fwc_up=16;                     %�����ֿ���ѡ��
DUCdata=up_convert_ofdm(fwc_up,CICidatai,CICidataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++��˹�������ŵ�++++++++++++++++++++++++
[DUCdata,datamax]=guiyi_DUCdata(DUCdata);
awgn_data=awgn(DUCdata,SNR_System);  
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%*****************************���ܻ�*****************************
%+++++++++++++++++++++++++++++�±�Ƶ+++++++++++++++++++++++++++++
DUCdata_tmp=awgn_data;
fwc_down=fwc_down+(fre_offset*128/2560000);
r_fre_offset=2560000*((fwc_down-fwc_up)/128);
[DDCdatai,DDCdataq]=down_convert_ofdm(fwc_down,DUCdata_tmp);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++���ջ�cic�˲�+++++++++++++++++++++++++
CICddatai=cic_deci(DDCdatai,40,40);
CICddataq=cic_deci(DDCdataq,40,40);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++fir��ͨ�˲�++++++++++++++++++++++++
guiyi_b=[ 0.019527	-0.03934	0.049055	-0.018102	-0.1003	0.5944	0.5944	-0.1003	-0.018102	0.049055	-0.03934	0.019527];
%������ֹƵ��Ϊ64kHZ,ͨ����ֹƵ��Ϊ20kHZ�������ֹƵ��Ϊ30kHZ�������Ʋ���С��1dB������˥��60dB
rxFIRdatai=filter(guiyi_b,1,CICddatai);
rxFIRdataq=filter(guiyi_b,1,CICddataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++++����++++++++++++++++++++++++++++
q_rxFIRdatai=sign(rxFIRdatai); 
q_rxFIRdataq=sign(rxFIRdataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++��ʱͬ�����++++++++++++++++++++++++
if seq_num<3
time_syn(q_rxFIRdatai,q_rxFIRdataq);
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++++Ƶ��ͬ��+++++++++++++++++++++++++++
fre_offset=fre_syn(rxFIRdatai,rxFIRdataq);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
%+++++++++++++++++++++++++++++fft����+++++++++++++++++++++++++++
if seq_num>2
   seq_num-2
   fftw=32+dingshi;
   rxFIRdata_syn=rxFIRdatai(fftw:fftw+255)+j*rxFIRdataq(fftw:fftw+255);
   FFTdata=fft_my(rxFIRdata_syn);
   %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++��PAPR�����任++++++++++++++++++++++
fftdata_reg=[FFTdata(193:256),FFTdata(1:64)];
dematrix_data=fftdata_reg*pinv(matix_data);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++��λ����+++++++++++++++++++++++++++
rx_qpsk_din_th=phase_comp(dematrix_data);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++++QPSK�������++++++++++++++++++++++++
% figure
% plot(rx_qpsk_din_th,'.')
% xlabel('����ͼ')
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

%+++++++++++++++++++++++++�ŵ��⽻֯++++++++++++++++++++++++++++
interdout=interlacedecode(datatemp4,8,24);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++����Ϊviterbi���벿��++++++++++++++++++++++
decodeDATA=viterbi(G,k0,interdout);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%+++++++++++++++++++++++++�����ͳ��++++++++++++++++++++++++++++
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
xlabel('�����/dB')
ylabel('������')
axis([-5,5,0,1])
grid on
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 