clear;
[data, fs] = audioread('../exa.wav');
%figure(1);
%plot(data);
hold on;

%% ��¼�����ݽ����˲�
%����һ����ͨ�˲���
hd = design(fdesign.bandpass('N,F3dB1,F3dB2',6,17500,18500,fs),'butter');
%�ö���õĴ�ͨ�˲�����data�����˲�
data = filter(hd,data);

%% �����ݽ��д��������ڵĸ���Ҷ�任���õ�ÿһ��������18kHz�źŵ�ǿ����Ϣ
f = 18000;%Ŀ��Ƶ��Ϊ18kHz
[n,~] = size(data);%��ȡ���ݵĳ���ֵ
window = 100;%���ô��ڴ�СΪ100��������
impulse_fft = zeros(n,1);%�����������impulse_fft�����ڴ洢ÿ��ʱ�̶�Ӧ�����ݶ���18kHz�źŵ�ǿ��
for i= 1:1:n-window
    %�Դӵ�ǰ�㿪ʼ��window���ȵ����ݽ��и���Ҷ�任
    y = fft(data(i:i+window-1));
    y = abs(y);
    %�õ�Ŀ��Ƶ�ʸ���Ҷ�任����ж�Ӧ��index
    index_impulse = round(f/fs*window);
    %���ǵ�����ͨ�Ź����е�Ƶ��ƫ�ƣ�����ȡ��Ŀ��Ƶ��Ϊ���ĵ�5��Ƶ�ʲ�����������һ��������Ŀ��Ƶ�ʵ�ǿ��
    impulse_fft(i)=max(y(index_impulse-2:index_impulse+2));
end
% ��figure��չʾÿ�����ڶ�Ӧ��18kHz�źŵ�ǿ��
%figure(2);
%plot(impulse_fft);

% ����ƽ������ֵ�˲���
sliding_window = 5;
for i= 1+sliding_window:1:n-sliding_window
    impulse_fft(i)=mean(impulse_fft(i-sliding_window:i+sliding_window));
end
% ��figure��չʾƽ�����impulse_fft
%figure(2);
%plot(impulse_fft);
hold on;

% ȡ��impulse ��ʼλ�ã�����м�λ�ã�
position_impulse=[];%���ڴ洢��ֵ��index
half_window = 50;
for i= half_window+1:1:n-half_window
    %���з�ֵ�ж�
    if impulse_fft(i)>0.3 && impulse_fft(i)==max(impulse_fft(i-half_window:i+half_window))
        position_impulse=[position_impulse,i];
    end
end

%% ��ͼ�б�ʾ��������ʼλ�ò�����������������֮��ļ��
[~,N]= size(position_impulse);
%�������delta_impulse���ڴ洢������������֮��ļ��
delta_impulse=zeros(1,N-1);
for i = 1:N-1
    %��18kHz�źŵ�ǿ��ͼ�б��������ʼλ��
    %figure(2);
    %plot([position_impulse(i),position_impulse(i)],[0,0.8],'m');
    %��ʱ���ź��ϱ��������ʼλ��
    %figure(1);
    %plot([position_impulse(i),position_impulse(i)],[0,0.2],'m','linewidth',2);
    %����������������֮��ļ����-100�Ǽ�ȥ�����źų���
    delta_impulse(i) = position_impulse(i+1) -  position_impulse(i) -100;
end

%% ����
%����ÿ����Ԫ��Ӧ2bit�������ȰѼ����Ӧ��4������
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
% ���Ľ���ת��Ϊ������
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
%�Ѷ��������ݸ���ascii��ֵ�����Ӧ���ַ���
str = bin2string(decode_message)

