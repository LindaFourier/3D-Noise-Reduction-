clc; clear all; close all;
% read video
VIDEO = VideoReader('test1.mp4');
% ��ʼ��֡����
frame_num = 1;
% ��ֹ���˶����жϷֿ�
NUM = 3;
% �趨��ֹ���˶����ж���ֵ
PSNR_threshold = 50;
% �ֿ��жϱ���
vidWidth = VIDEO.Width;
vidHeight = VIDEO.Height;
temp_r = vidHeight/NUM;
temp_c = vidWidth/NUM;
while hasFrame(VIDEO)
    frame = readFrame(VIDEO);
    
    % 3֡ʱ���� ���м�֡Ϊê��֡
    if frame_num > 2
        for i = 1:temp_r:vidHeight
            for j = 1:temp_c:vidWidth
                for channel = 1:3
                    temp = frame(i:i+temp_r , j:j+temp_c , channel);
                    temp_last = last_frame(i:i+temp_r , j:j+temp_c , channel);
                    temp_before  = before_frame(i:i+temp_r , j:j+temp_c , channel);
                    peaksnr = psnr(temp_last,temp_before);
                    
                    if peaksnr > PSNR_threshold
                        output(i:i+temp_r , j:j+temp_c , channel) = medfilt2(temp_last);
                    else
                        output(i:i+temp_r , j:j+temp_c , channel) = (temp + temp_last + temp_before)./3;
                    end
                end
            end
        end        
        % ����ǰ��֡����ʱ����
        before_frame = last_frame;
        last_frame   = frame;
        
    elseif frame_num > 1
        output = frame;
        before_frame = last_frame;
        last_frame   = frame;
    else
        output = frame;
        last_frame   = frame;
    end
    
    imshow(output);
    
    
    
    frame_num = frame_num + 1;
end