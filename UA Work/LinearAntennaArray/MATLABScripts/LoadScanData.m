function [scan,freq,num_chan] = LoadScanData(src_dir)
%ImportScan Import s2p data from directory
%   Inputs:
%           -> src_dir: name of the folder where s2p files are located
%   Outputs:
%           <- scan: matrix of sparameters for each channel
%           <- freq: column vector of frequencies
%           <- num_chan: number of scans
home_dir = cd('Scans');
scan_dir = dir([src_dir '/*.s2p']);
num_chan = length(scan_dir);
scan = [];
cd(src_dir);
for index = 1:length(scan_dir)
    scan_file = scan_dir(index).name;
    sp_obj = sparameters(scan_file);
    s21_obj = sp_obj.Parameters(2,1,:);
    s21_obj = squeeze(s21_obj);
    scan = cat(2,scan,s21_obj);
end
freq = sp_obj.Frequencies;
cd(home_dir);
end