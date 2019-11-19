clear;
%% impulse coding
fs = 48000;%设置采样频率
f = 18000;%指定声音信号频率
time = 0.0025;%指定生成的信号持续时间
t = 0:1/fs:time;%设置每个采样点数据对应的时间
t = t(1:100);%截取出100个时间上的采样点
impulse = sin(2*pi*f*t);%生成频率为f的正弦信号

delta = 50;
pause0 = zeros(1,delta);%编码00
pause1 = zeros(1,2*delta); %编码01
pause2 = zeros(1,3*delta); %编码10
pause3 = zeros(1,4*delta); %编码11

str = 'Tsinghua University ';

message = string2bin( str )';%调用函数把字符串转为二进制串
%因为我们设计的编码是每个码元代表2个bit，这里要把二进制串转为4进制串
[~,m_Length] = size(message);
message4 = [];
for i = 1:m_Length/2
    % 把二进制串中的每两位进行结合，得到四进制串
    message4 = [message4,message(i*2-1)*2+message(i*2)];
end

output = [];
% 根据四进制串中的值，将impulse和对应的空白信号添加到输出信号中
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
% 在输出信号前加一段空白，避免播放器在信号刚开始的位置出现失真的情况。
output = [pause3,output,impulse];
% 在figure中画出输出的时域信号
figure(1);
plot(output);
axis([-500 17500 -3 3]);
%data = data * 10000;
% 将输出信号写入到音频文件中，需要指明文件名、数据、和采样频率。
audiowrite('message.wav',output,fs);
