whiskVid = VideoReader('/Volumes/cadPortSSD/nt16_2.avi');
tic
n=38504;
for n=38504:60000
    tempData=whiskVid.readFrame('native');
    tempWrite=tempData(:,:,1);
    imwrite(tempWrite,['~/Desktop/tifExport/image_' num2str(n) '.tif'])
    n=n+1;
end
toc

%%
aa=imread('~/Desktop/tifExport/image_1.tif');
aa=repmat(aa,1,1,60000);
for n=1:60000,aa(:,:,n)=imread(['~/Desktop/tifExport/image_' num2str(n) '.tif']);,end