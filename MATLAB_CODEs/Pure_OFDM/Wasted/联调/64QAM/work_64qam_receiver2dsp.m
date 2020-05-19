%QAM64receiver_dsp_system
%%产生均匀64qam序列 QAM64receiver_dsp_system设置为p
%端口初始化
OutputPort1=InputPort1;
bitSequence0=InputPort3.Sequence;%设置原始比特序列等于3输入口数据，用于计算BER
save('C:\Users\zym\Desktop\组内\研究生毕设\PAPR\联调\64QAM\work_64_bitSequence.txt','bitSequence0','-ascii');
I_Reciever=InputPort1.Sampled.Signal;
Q_Reciever=InputPort2.Sampled.Signal;
save('C:\Users\zym\Desktop\组内\研究生毕设\PAPR\联调\64QAM\work_64_I_Reciever.txt','I_Reciever','-ascii');
save('C:\Users\zym\Desktop\组内\研究生毕设\PAPR\联调\64QAM\work_64_Q_Reciever.txt','Q_Reciever','-ascii');