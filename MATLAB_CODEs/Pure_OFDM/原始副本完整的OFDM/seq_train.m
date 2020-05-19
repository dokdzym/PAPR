%************************beginning of file*****************************
%seq_train.m
%��������ͬ����ѵ������
function dout=seq_train()
%��һ֡������ѵ�����У��ڶ�֡������ѵ������
%ÿ����ѵ��������16�����ز���ɣ���ѵ������
%����α������о������ֵ��ƺ��0���پ���
%IFFT֮��õ��ġ�����������£����Ȳ��ó�ͷ
%ϵ��Ϊ[1 0 0 1 ]��4����λ�Ĵ�����������Ϊ
%15��α�������֮��ĩβ��0������QPSK����֮
%���α�������ֻ��16��������λ���ϳ��֣���
%���λ�ò�0����������Ϊ128�����У���������
%��128��0�������ݰ��ƺ���256���IFFT�任��
%�õ�16����16Ϊѭ����ѵ�����У�������ѭ��ǰ
%��׺�ͻ����20����ͬ�Ķ�ѵ�����С���ѵ����
%�еĲ���ͬ��ѵ�����С�

global seq_num  

if seq_num==1
   fbconnection=[1 0 0 1];
   QPSKdata_pn=[m_sequence(fbconnection),0];
   QPSKdata_pn=qpsk(QPSKdata_pn);
elseif seq_num==2
   fbconnection=[1 0 0 0 0 0 1];
   QPSKdata_pn=[m_sequence(fbconnection),0];
   QPSKdata_pn=qpsk(QPSKdata_pn);
end

countmod=0;
for k=1:128  
   if seq_num==1 
      if mod(k-1,16)==0                 %����16λѭ���Ķ�ѵ������   
        countmod=countmod+1;
        trainsp_temp(k)=QPSKdata_pn(countmod);
      else
        trainsp_temp(k)=0;
      end
   elseif seq_num==2 
      if mod(k-1,2)==0
        countmod=countmod+1;
        trainsp_temp(k)=QPSKdata_pn(countmod);
      else
        trainsp_temp(k)=0;
      end
   end
end

dout=trainsp_temp;
% ************************end of file***********************************