clear;
%% impulse coding
fs = 48000;%���ò���Ƶ��
f = 18000;%ָ�������ź�Ƶ��
time = 0.0025;%ָ�����ɵ��źų���ʱ��
t = 0:1/fs:time;%����ÿ�����������ݶ�Ӧ��ʱ��
t = t(1:100);%��ȡ��100��ʱ���ϵĲ�����
impulse = sin(2*pi*f*t);%����Ƶ��Ϊf�������ź�

delta = 50;
pause0 = zeros(1,delta);%����00
pause1 = zeros(1,2*delta); %����01
pause2 = zeros(1,3*delta); %����10
pause3 = zeros(1,4*delta); %����11

str = 'Tsinghua University ';

message = string2bin( str )';%���ú������ַ���תΪ�����ƴ�
%��Ϊ������Ƶı�����ÿ����Ԫ����2��bit������Ҫ�Ѷ����ƴ�תΪ4���ƴ�
[~,m_Length] = size(message);
message4 = [];
for i = 1:m_Length/2
    % �Ѷ����ƴ��е�ÿ��λ���н�ϣ��õ��Ľ��ƴ�
    message4 = [message4,message(i*2-1)*2+message(i*2)];
end

output = [];
% �����Ľ��ƴ��е�ֵ����impulse�Ͷ�Ӧ�Ŀհ��ź���ӵ�����ź���
for i = 1:m_Length/2
    if message4(i)==0
        output = [output,impulse,pause0];
    elseif message4(i)==1
        output = [output,impulse,pause1];
    elseif message4(i)==2
        output = [output,impulse,pause2];
    else
        output = [output,impulse,pause3];
    end
end
% ������ź�ǰ��һ�οհף����ⲥ�������źŸտ�ʼ��λ�ó���ʧ��������
output = [pause3,output,impulse];
% ��figure�л��������ʱ���ź�
figure(1);
plot(output);
axis([-500 17500 -3 3]);
%data = data * 10000;
% ������ź�д�뵽��Ƶ�ļ��У���Ҫָ���ļ��������ݡ��Ͳ���Ƶ�ʡ�
audiowrite('message.wav',output,fs);
