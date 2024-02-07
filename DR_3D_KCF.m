clc; clear all; close all;
% read video
VIDEO = VideoReader('test1.mp4');
% ��ʼ��֡����
frame_num = 1;
% ��ֹ���˶����жϷֿ�
NUM = 30;
% �趨��ֹ���˶����ж���ֵ��������Ϊ1������ÿ��ͼ��鶼���뷴����ٵ�ͼ�����ʱ����
response_threshold = 0.9;
% �ֿ��жϱ���
vidWidth = VIDEO.Width;
vidHeight = VIDEO.Height; 
temp_r = (vidHeight/NUM);
temp_c = (vidWidth/NUM);
window_sz = floor( [temp_r , temp_c]);

% KCF���ֵĳ�����
kernel_type = 'gaussian';
feature_type = 'hog';
interp_factor = 0.02;
kernel.sigma  = 0.5;
kernel.poly_a = 1;
kernel.poly_b = 9;
features.hog  = true;
features.gray = false;
features.hog_orientations = 9;
cell_size     = 4;
padding = 1.5;   % extra area surrounding the target
lambda  = 1e-4;  % regularization
output_sigma_factor = 0.1;  % spatial bandwidth (proportional to target)
% create regression labels, gaussian shaped, with a bandwidth proportional to target size
output_sigma = sqrt(prod([temp_r , temp_c])) * output_sigma_factor / cell_size;
yf = fft2(gaussian_shaped_labels(output_sigma, floor(window_sz / cell_size)));
%store pre-computed cosine window
cos_window = hann(size(yf,1)) * hann(size(yf,2))';

while hasFrame(VIDEO)
    frame = readFrame(VIDEO);
    
    % ѡȡ�м�һ�δ���
    if (319<frame_num) && (frame_num<434)
    
    if frame_num > 1
        for i = 1:temp_r:vidHeight
            for j = 1:temp_c:vidWidth
                for channel = 1:3
                    
                    temp_last = last_frame(i:i+temp_r , j:j+temp_c , channel);
                    temp_cur  = frame(i:i+temp_r , j:j+temp_c , channel);
                    
                    % ������Ӧֵ�����жϾ�ֹ���˶�
                    % ��ǰ֡��Ϊê�����ȼ���ģ��
                    xf = fft2(get_features(temp_cur, features, cell_size, cos_window));
                    % Kernel Ridge Regression, calculate alphas (in Fourier domain)
                    kf = gaussian_correlation(xf, xf, kernel.sigma);
                    % equation for fast training
                    alphaf = yf ./ (kf + lambda);
                    model_alphaf = alphaf;
                    model_xf = xf;
                    
                    % �ȼ���(��ǰһ֡ͬ��λ�õ�)��Ӧ
                    zf = fft2(get_features(temp_last, features, cell_size, cos_window));
                    kzf = gaussian_correlation(zf, model_xf, kernel.sigma);
                    % calculate response of the classifier at all shifts
                    response = real(ifft2(model_alphaf .* kzf));
                    
                    % ��Ӧֵ�ߵ�Ϊ��ֹ�飬ֱ��ʱ����
                    if response > response_threshold
                        output(i:i+temp_r , j:j+temp_c , channel) = (temp_last + temp_cur)./2;
                        % �˶��飬��ǰλ����Ϊê�������з�����٣��ҵ���һ֡��λ�ã�Ȼ����ʱ����
                    else
                        
                        % ��ǰһ֡�����˶�Ŀ���λ�ã�ǰһ֡Ϊ����֡
                        [vert_delta, horiz_delta] = find(response == max(response(:)), 1);
                        if vert_delta > size(zf,1) / 2,  %wrap around to negative half-space of vertical axis
                            vert_delta = vert_delta - size(zf,1);
                        end
                        if horiz_delta > size(zf,2) / 2,  %same for horizontal axis
                            horiz_delta = horiz_delta - size(zf,2);
                        end
                        % ����cell_size
                        vert_delta = cell_size * (vert_delta - 1);
                        horiz_delta = cell_size * (horiz_delta - 1);
                        % �ҵ�λ�ú��������λ�õ�ͼ�����ʱ����
                        % �жϸ��ٵ���ͼ����Ƿ񳬳��߽�
                        if ((1<i+horiz_delta) && (i+temp_r+horiz_delta<vidHeight) && (1<j+vert_delta) && (j+temp_c+vert_delta<vidWidth))
                            temptemp = last_frame(i+horiz_delta:i+temp_r+horiz_delta , j+vert_delta:j+temp_c+vert_delta , channel) + temp_cur;
                            output(i:i+temp_r , j:j+temp_c , channel) = (temptemp)/2;
                        else 
                            output(i:i+temp_r , j:j+temp_c , channel) =  medfilt2(temp_cur);
                        end
                    end
                end
            end
        end
    else
        output = frame;
    end
    
    imshow(output);
    imwrite(output,[num2str(frame_num),'.jpg']);
    
    end
    
    % ����ǰһ֡����ʱ����
    last_frame = frame;
    
    frame_num = frame_num + 1;
end