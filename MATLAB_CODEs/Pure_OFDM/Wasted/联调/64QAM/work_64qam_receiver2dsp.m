%QAM64receiver_dsp_system
%%��������64qam���� QAM64receiver_dsp_system����Ϊp
%�˿ڳ�ʼ��
OutputPort1=InputPort1;
bitSequence0=InputPort3.Sequence;%����ԭʼ�������е���3��������ݣ����ڼ���BER
save('C:\Users\zym\Desktop\����\�о�������\PAPR\����\64QAM\work_64_bitSequence.txt','bitSequence0','-ascii');
I_Reciever=InputPort1.Sampled.Signal;
Q_Reciever=InputPort2.Sampled.Signal;
save('C:\Users\zym\Desktop\����\�о�������\PAPR\����\64QAM\work_64_I_Reciever.txt','I_Reciever','-ascii');
save('C:\Users\zym\Desktop\����\�о�������\PAPR\����\64QAM\work_64_Q_Reciever.txt','Q_Reciever','-ascii');