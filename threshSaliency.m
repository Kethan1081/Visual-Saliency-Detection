function [ ThreshSalMap] = threshSaliency(rgb1)
c=rgb1;
a=c;
a(c>125)=255;
a(c<=125)=0;
ThreshSalMap=a;

end