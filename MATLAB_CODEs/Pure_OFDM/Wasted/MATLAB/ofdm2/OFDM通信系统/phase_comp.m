%************************beginning of file*****************************
%phase_comp.m
%实现OFDM符号的相位补偿

function   dout=phase_comp(din)

%使用导频的相位信息来调整有效数据的偏移相位，
%以实现正确的QPSK解调

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        输入数据
% dout       输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

qpsk_din=[din(1:8),din(10:17),din(19:26),din(28:35),din(37:44),din(46:53),din(54:61),din(63:70),din(72:79),din(81:88),din(90:97),din(99:106)];
pilot=[din(9),din(18),din(27),din(36),din(45),din(62),din(71),din(80),din(89),din(98)];
ang_offset=angle(sum((1-j)*pilot));
qpsk_din=qpsk_din*exp(-j*ang_offset);
dout=qpsk_din;
% ************************end of file***********************************
