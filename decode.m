clear;
[data, fs] = audioread('../exa.wav');
%figure(1);
%plot(data);
hold on;

%% 对录音数据进行滤波
%定义一个带通滤波器
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,17500,18500,fs),'butter');
%用定义好的带通滤波器对data进行滤波
data = filter(hd,data);

%% 对数据进行带滑动窗口的傅里叶变换。得到每一段数据中18kHz信号的强度信息
f = 18000;%目标频率为18kHz
[n,~] = size(data);%获取数据的长度值
window = 100;%设置窗口大小为100个采样点
impulse_fft = zeros(n,1);%定义变量数组impulse_fft，用于存储每个时刻对应的数据段中18kHz信号的强度
for i= 1:1:n-window
    %对从当前点开始的window长度的数据进行傅里叶变换
    y = fft(data(i:i+window-1));
    y = abs(y);
    %得到目标频率傅里叶变换结果中对应的index
    index_impulse = round(f/fs*window);
    %考虑到声音通信过程中的频率偏移，我们取以目标频率为中心的5个频率采样点中最大的一个来代表目标频率的强度
    impulse_fft(i)=max(y(index_impulse-2:index_impulse+2));
end
% 在figure中展示每个窗口对应的18kHz信号的强度
%figure(2);
%plot(impulse_fft);

% 滑动平均（均值滤波）
sliding_window = 5;
for i= 1+sliding_window:1:n-sliding_window
    impulse_fft(i)=mean(impulse_fft(i-sliding_window:i+sliding_window));
end
% 在figure中展示平滑后的impulse_fft
%figure(2);
%plot(impulse_fft);
hold on;

% 取出impulse 起始位置（峰的中间位置）
position_impulse=[];%用于存储峰值的index
half_window = 50;
for i= half_window+1:1:n-half_window
    %进行峰值判断
    if impulse_fft(i)>0.3 && impulse_fft(i)==max(impulse_fft(i-half_window:i+half_window))
        position_impulse=[position_impulse,i];
    end
end

%% 在图中表示出脉冲起始位置并计算相邻两个脉冲之间的间隔
[~,N]= size(position_impulse);
%定义变量delta_impulse用于存储相邻两个脉冲之间的间隔
delta_impulse=zeros(1,N-1);
for i = 1:N-1
    %在18kHz信号的强度图中标出脉冲起始位置
    %figure(2);
    %plot([position_impulse(i),position_impulse(i)],[0,0.8],'m');
    %在时域信号上标出脉冲起始位置
    %figure(1);
    %plot([position_impulse(i),position_impulse(i)],[0,0.2],'m','linewidth',2);
    %计算两个相邻脉冲之间的间隔。-100是减去脉冲信号长度
    delta_impulse(i) = position_impulse(i+1) -  position_impulse(i) -100;
end

%% 解码
%由于每个码元对应2bit，所以先把间隔对应到4进制数
decode_message4 = zeros(1,N-1)-1;
de = 50;
for i = 1:N-1
    if delta_impulse(i) - de >-10 &&delta_impulse(i) - de <10
        decode_message4(i) = 0;
    elseif delta_impulse(i) - 2*de >-10 &&delta_impulse(i) - 2*de <10
        decode_message4(i) = 1;
    elseif delta_impulse(i) - 3*de >-10 &&delta_impulse(i) - 3*de <10
        decode_message4(i) = 2;
    elseif delta_impulse(i) - 4*de >-10 &&delta_impulse(i) - 4*de <10
        decode_message4(i) = 3;
    end
end
% 把四进制转化为二进制
decode_message = zeros(1,(N-1)*2)-1;
for i = 1:N-1
    if decode_message4(i) == 0
        decode_message(i*2-1)=0;
        decode_message(i*2)=0;
    elseif decode_message4(i) == 1
        decode_message(i*2-1)=0;
        decode_message(i*2)=1;
    elseif decode_message4(i) == 2
        decode_message(i*2-1)=1;
        decode_message(i*2)=0;
    elseif decode_message4(i) == 3
        decode_message(i*2-1)=1;
        decode_message(i*2)=1;
    end
end

%decode_message
%把二进制数据根据ascii码值解出对应的字符串
str = bin2string(decode_message)

