% 
%   Top level image reconstruction script
%
clear variables;
clc;

%   Initialize Parameters ->
dx = 0.002;                 % conveyor belt increments
y_dim = 0.270;               % dist between antennas 16.5cm
img_resolution = 'Low';    % Options: {Low, Medium, High, Max}
eps_r = 10;                % permittivity limit
increment = 0.1;           % permittivity incremental
%   Initialize Parameters <-

scan_dir_name = 'Scans\';           % top level dir for s2p scans
if not(isfolder(scan_dir_name))     % make sure scan folder exists
    mkdir(scan_dir_name)            % if not create folder
end

%   Get user input ->
scan_dir = dir(scan_dir_name);
scan_names = string({scan_dir(3:end).name});
if isempty(scan_names)
    errordlg('No scans found in Scan folder','File Error');
    clear variables;
    return;
end
prompt = 'Select Reference Scan';
[index,tf] = listdlg("PromptString",prompt,"SelectionMode","single", ...
    "ListString",scan_names);
if tf % input valid
    ref_scan_name = convertStringsToChars(scan_names(index));
end
prompt = 'Select Object Scan';
[index,tf] = listdlg("PromptString",prompt,"SelectionMode","single", ...
    "ListString",scan_names);
if tf % input valid
    obj_scan_name = convertStringsToChars(scan_names(index));
end
%   Get user input <-


%  NAME LOOPING FILE ->
img_dir_name = append(obj_scan_name,'_minus_', ref_scan_name);  % top level dir for image outputs
if not(isfolder(img_dir_name))  % make sure img folder exists
    mkdir(img_dir_name)         % if not create folder
end
%  NAME LOOPING FILE <-


%   Import scans ->
[ref_scan,~,~] = LoadScanData(ref_scan_name);
[obj_scan,scan_freq,num_chan] = LoadScanData(obj_scan_name);
%   Import scans <-

switch img_resolution % convert from text input
    case 'Max'
        img_res = 55;
    case 'High'
        img_res = 45;
    case 'Low'
        img_res = 20;
    otherwise
        img_res = 35;
end

%   Generate Domain ->
x_dim = dx * (num_chan - 1);
z_dim = 0.5; %Was originally 0.5, so we take height of antenna 0.065 and
% double it
[antenna_locations,channel_names] = GenerateAntenna(dx,num_chan,y_dim);
[points,axes_] = RectangularDomain(x_dim,y_dim,z_dim,img_res);
%   Generate Domain <-

%   Perform Subtraction ->
if (size(ref_scan) == size(obj_scan))
    sub_scan = normalize(obj_scan - ref_scan);
    %sub_scan = normalize(obj_scan);
else
    errordlg('Object scan and reference scan size mismatch', ...
        'Scan Error');
    return;
end%   Perform Subtraction <-

%   Plot Frequency Response with magnitude->
ch_num = 1;
chan_data = [ref_scan(:,ch_num),obj_scan(:,ch_num),sub_scan(:,ch_num)];
chan_mag = mag2db(abs(chan_data));
figure
plot(scan_freq,chan_mag)
title('Channel 1 Frequency Response w/ Mag')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
grid on
%   Plot Frequency Response with magnitude<-

%   Plot Frequency Response with Phase Angle->
ch_num = 1;
chan_data = [ref_scan(:,ch_num),obj_scan(:,ch_num),sub_scan(:,ch_num)];
chan_mag = (angle(chan_data));
figure
plot(scan_freq,chan_mag)
title('Channel 1 Frequency Response w/ Phase')
xlabel('Frequency (Hz)')
ylabel('Angle (degrees)')
grid on
%   Plot Frequency Response with Phase Angle <-

%   BW ->
% freq_out = scan_freq(10:131,:);
% scan_out = sub_scan(10:131,:);
scan_out = sub_scan;
freq_out = scan_freq;
bw = freq_out(end,1) - freq_out(1,1);
%   BW <-

%PLOT IMAGING DOMAIN FOR TESTING PURPOSES ->
% plot3(points(:,1), points(:,2), points(:,3), 'o' , ...
%     antenna_locations(:,1), antenna_locations(:,2), ...
%     antenna_locations(:,3), 'o');
% xlabel('X (m)');
% ylabel('Y (m)');
% zlabel('Z (m)');
% title('Imaging Domain')
% <- PLOT IMAGING DOMAIN FOR TESTING PURPOSES





%LOOPING BEGINS HERE (for 1 to eps_r by incrementing "increment")
for e=1.0:increment:eps_r

%   Beamforming ->
f = waitbar(0,'Please wait...');
pause(0.2)
delays = merit.beamform.get_delays(channel_names,antenna_locations, ...
    'relative_permittivity',e);
waitbar(.33,f,'Beamforming...');
%img = abs(merit.beamform(scan_out,freq_out,points,delays, ...
 %   merit.beamformers.CDAS,'gpu', true));
img = abs(merit.beamform(scan_out,freq_out,points,delays, ...
    merit.beamformers.DAS,'gpu', true));
waitbar(.67,f,'Beamforming...');
im_slice = merit.visualize.get_slice(img,points,axes_,'z',0);
waitbar(1,f,'Beamform Complete');
pause(0.2)
close(f)
%   Beamforming <-

%   Generate Image ->
er_str = "Permittivity: " + e;
bw_str = string(10^-9*bw);
bw_str = "BW: " + bw_str + " GHz";
dx_str = "DX: " + (dx * 10^3) + " mm";
y_str = "Y: " + (y_dim * 10^3) + "mm";
scan_subtitle = er_str + " , " + bw_str + " , " + dx_str + ' , ' + y_str;
scan_title = split(obj_scan_name,{'_' ' '});
scan_title = scan_title{1,1};
f = figure('visible','off');
%

%save("PBwObjminusAir.mat", "im_slice");
%load('PBminusAir.mat');
%load('PBwObjectminusAir.mat');
%im_slice = im_slice1 - im_slice0;


imagesc(axes_{1:2},im_slice);
title(scan_title,scan_subtitle);
xlabel('X')
ylabel('Y')
colormap('jet')
colorbar()
%   Generate Image <-

% Write Image to File ->
er_str = "_Er" + e;
bw_str = "_Bw" + (10^-9*bw);
dx_str = "_Dx" + (dx * 10^3) + "mm";
y_str = "_Y" + (y_dim * 10^3) + "mm";
img_data = er_str + bw_str + dx_str + y_str;
img_data = strrep(img_data,'.','p');
img_name = scan_title + img_data + ".png";
img_name = convertStringsToChars(img_name);
home_dir = cd(img_dir_name);
exportgraphics(f,img_name);
cd(home_dir);
% Write Image to File <-

end
% LOOPING ENDS HERE


