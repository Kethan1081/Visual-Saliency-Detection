clc; clear; close all;

% Parameter settings
params.qnums = 256;		% ['Color Quantization']
params.alpha = 0.95;	% ['Parameter Selection']
params.delta = 0.25;
params.sigma = 0.2; 
% make folders
if exist('Superpixelimg','dir') ~= 7
	system('md Superpixelimg');
end

if exist('GloSalMaps','dir') ~= 7
	system('md GloSalMaps');
end

if exist('ThreshSalMaps','dir') ~= 7
	system('md ThreshSalMaps');
end

%% RPC
 %creating superpixels
 rgbfiles = dir('images\*.jpg');
for nums = 1:length(rgbfiles)
	tic;
	% read image
	filename = rgbfiles(nums).name;
	fprintf('%4d/%-4d:\t%s\t', nums, length(rgbfiles), filename);
	rgb = imread(['images\', filename]);
	[Superpixelimg] = Superpixel(rgb);
	% save result
	imwrite(Superpixelimg, ['Superpixelimg\', filename(1:end-4), '_RPC.jpg']);
	%imwrite(RegSalMap, ['RegSalMaps\', filename(1:end-4), '_RPC.png']);
	toc;
end

rgbfiles1 = dir('Superpixelimg\*.jpg');
for nums = 1:length(rgbfiles1)
	tic;
	% read image
	filename3 = rgbfiles1(nums).name;
	fprintf('%4d/%-4d:\t%s\t', nums, length(rgbfiles1), filename3);
	rgb3 = imread(['Superpixelimg\', filename3]);
	if ndims(rgb3) == 2
		rgb3 = repmat(rgb3, [1 1 3]);
	end
	[GloSalMap] = RpcSaliency(rgb3, params);
	% save result
	imwrite(GloSalMap, ['GloSalMaps\', filename3(1:end-4), '_RPC.png']);
	toc;
end
%finding threshold images of global saliency maps 
threshfiles1=dir('GloSalMaps\*.png');
for nums = 1:length(threshfiles1)
	tic;
	% read image
	filename1 = threshfiles1(nums).name;
	fprintf('%4d/%-4d:\t%s\t', nums, length(threshfiles1), filename1);
	rgb1 = imread(['GloSalMaps\', filename1]);
	%if ndims(rgb) == 2
		%rgb = repmat(rgb, [1 1 3]);
	%end
	[ThreshSalMaps] = threshSaliency(rgb1,rgb2);
	% save result
	imwrite(ThreshSalMaps, ['ThreshSalMaps\', filename1(1:end-4), '_RPC.png']);
	%imwrite(RegSalMap, ['RegSalMaps\', filename(1:end-4), '_RPC.png']);
	toc;
end