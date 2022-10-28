function [GloSalMap] = RpcSaliency(rgb, params)
% Output:
% 	GloSalMap: Global saliency map
[Height, Width, ~] = size(rgb);


%% Color histogram [Subsection 'Global Color Saliency']
rgb_quan_colormap = reshape(RGB_Quan, Height*Width, 3);
[Colormap,~,RGB_Quan_Idx] = unique(rgb_quan_colormap, 'rows');
ColormapIdx = (1:size(Colormap,1))';
ColormapCount = accumarray(RGB_Quan_Idx,1);
[ColormapCountSort, ColormapIdxSort] = sort(ColormapCount,1,'descend');

%% Abandon infrequently occurring colors [Subsection 'Global Color Saliency']
tmpsum = 0;
for m = 1:size(ColormapCountSort)
	tmpsum = tmpsum + ColormapCountSort(m);
	if tmpsum > Height*Width * params.alpha
		break;
	end
end
reserved = m; % the number of high frequently occurring colors
if reserved == 1
	GloSalMap = zeros(Height,Width);
	RegSalMap = zeros(Height,Width);
	return;
end

ColormapIdxReserved = ColormapIdxSort(1:reserved);
ColormapReserved = Colormap(ColormapIdxReserved,:);
% replace infrequently occurring colors by the most similar colors in the color histogram['Global Color Saliency']
ColormapIdxCombine = [ColormapIdx, ColormapIdx];
for m = 1:length(ColormapIdx)
	if isempty(find(ColormapIdxCombine(m,1)==ColormapIdxReserved, 1))
		ColormapIdxCombine(m,2) = 0;
	end
end
tmpNonZeroIdx = find(ColormapIdxCombine(:,2)~=0);
tmpZeroIdx = find(ColormapIdxCombine(:,2)==0);
% recompute ColormapCount and ColormapSort
RGB_Quan_Idx_Combine = RGB_Quan_Idx;
for m = 1:Height*Width
	RGB_Quan_Idx_Combine(m) = ColormapIdxCombine(RGB_Quan_Idx(m),2);
end
ColormapCountCombine = accumarray(RGB_Quan_Idx_Combine,1);
[ColormapCountSortCombine, ~] = sort(ColormapCountCombine,1,'descend');
ColormapCountSortCombine = ColormapCountSortCombine(1:length(ColormapIdxReserved));

%% compute the difference between two high frequent colors in Lab color space
tmplen = length(ColormapIdxReserved);
tmpcolormap = im2double(ColormapReserved);
ColormapReservedDist = zeros(tmplen);
for m = 1:tmplen
	[ml,ma,mb] = RGB2Lab(tmpcolormap(m,1),tmpcolormap(m,2),tmpcolormap(m,3));
	for n = 1:tmplen
		[nl,na,nb] = RGB2Lab(tmpcolormap(n,1),tmpcolormap(n,2),tmpcolormap(n,3));
		ColormapReservedDist(m,n) = norm([ml,ma,mb]-[nl,na,nb], 2);
	end
end

%% Global color saliency ['Global Color Saliency']
tmplen = length(ColormapIdxReserved);
ColormapReservedSaliency = zeros(tmplen,1);
for m = 1:tmplen
	for n = 1:tmplen
		ColormapReservedSaliency(m,1) = ColormapReservedSaliency(m,1) + ColormapReservedDist(m,n)*ColormapCountSortCombine(n);
	end
end

%% Color space smoothing ['Global Color Saliency']
tmplen = length(ColormapIdxReserved);
[ColormapReservedDistSort, ColormapReservedDistSortIdx] = sort(ColormapReservedDist, 2, 'ascend');
tmpcnt = uint32(ceil(length(ColormapIdxReserved) * params.delta));
if tmpcnt == 1
	tmpcnt = 2;
end
T = zeros(tmplen,1);
for m = 1:tmplen
	T(m) = sum(ColormapReservedDistSort(m,1:tmpcnt));
end
ColormapReservedSaliencySmooth = zeros(tmplen,1);
for m = 1:tmplen
	tmpsum = 0;
	for n = 1:tmpcnt
		tmpsum = tmpsum + (T(m)-ColormapReservedDistSort(m,n))*ColormapReservedSaliency(ColormapReservedDistSortIdx(m,n));
	end
	ColormapReservedSaliencySmooth(m) = tmpsum/double(tmpcnt-1)/T(m);
end
% normalization
ColormapReservedSaliencySmooth = mapminmax(ColormapReservedSaliencySmooth',0,1);
%* Global saliency map
GloSalMap = zeros(Height,Width);
for m = 1:Height*Width
	tmpidx = RGB_Quan_Idx_Combine(m);
	GloSalMap(m) = ColormapReservedSaliencySmooth(ColormapIdxReserved==tmpidx);
end