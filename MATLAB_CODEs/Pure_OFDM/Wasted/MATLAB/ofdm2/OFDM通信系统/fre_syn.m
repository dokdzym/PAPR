%************************beginning of file*****************************
%fre_syn.m

function dout=fre_syn(datai,dataq)
%ʵ��ϵͳ��Ƶ��ͬ��

%Ƶƫ�Ĺ��Ʒ�Χ��֡���Ⱥ�ѭ�������������������
%��ϵͳ�У���ѵ�����е�Ƶƫ���Ʒ�ΧΪ ��2000Hz������ѵ
%������Ƶƫ���Ʒ�ΧΪ250Hz��ǰһ���нϴ�ľ�ƫ��Χ����
%��ֵ�õ��ķ���ϴ󣻺�һ�������ľ�ƫ��Χ��С������ֵ��
%���ķ����С��Ƶ�ʸ��ٿ�����ѭ��ǰ��׺�������ظ�������
%�ɣ���Ƶƫ���Ʒ�ΧΪ125Hz��

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% datai         �������ݵ�ʵ��
% dataq         �������ݵ��鲿
% dout          �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

global seq_num  
global dingshi  
global m_syn 


if seq_num==1
    if  m_syn(50)>10
     for m=1:128
         fre_back_tmp(m)=(datai(40+m-1)+j*dataq(40+m-1))*conj(datai(40+m-1+16)+j*dataq(40+m-1+16));
     end
     fre_back_sum=sum(fre_back_tmp);
     fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*16);
     fre_offset=fre_offset_tmp/0.005;
    end
elseif seq_num==2
    for m=1:128
          fre_back_tmp(m)=(datai(dingshi+m-1)+j*dataq(dingshi+m-1))*conj(datai(dingshi+m-1+128)+j*dataq(dingshi+m-1+128));
    end
       fre_back_sum=sum(fre_back_tmp);
       fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*128);
       fre_offset=fre_offset_tmp/0.005;

elseif seq_num>2
    for m=1:48
      fre_back_tmp(m)=(datai(dingshi+m)+j*dataq(dingshi+m))*conj(datai(dingshi+m+256)+j*dataq(dingshi+m+256));
    end
    fre_back_sum=sum(fre_back_tmp);
    fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*256);
    fre_offset= fre_offset_tmp/0.005;
end
dout=fre_offset;
% ************************end of file**********************************
