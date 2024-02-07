clc; clear all; close all;
% read video
VIDEO = VideoReader('test2.mp4');
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
    
    if frame_num > 1
        for i = 1:temp_r:vidHeight
            for j = 1:temp_c:vidWidth
                for channel = 1:3
                    temp_last = last_frame(i:i+temp_r , j:j+temp_c , channel);
                    temp_cur  = frame(i:i+temp_r , j:j+temp_c , channel);
                    peaksnr = psnr(temp_last,temp_cur); 
                    
                    if peaksnr > PSNR_threshold
                        output(i:i+temp_r , j:j+temp_c , channel) = medfilt2(temp_cur);
                    else
                        output(i:i+temp_r , j:j+temp_c , channel) = (temp_last + temp_cur)./2;
                    end
                end
            end
        end
    else
        output = frame;
    end
    
    imshow(output);
    
    % ����ǰһ֡����ʱ����
    last_frame = frame;
    
    frame_num = frame_num + 1;
end