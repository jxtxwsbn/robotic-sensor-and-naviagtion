clc;
clear;
buildingScene = imageDatastore('building2/');
for k=1:numel(buildingScene.Files)
I = readimage(buildingScene, k);
for i= 490:510
    for j = 490:510
        I(i,j,:)=[255,0,0];
    end
end
imshow(I)
imwrite(I,strcat(num2str(k),'.jpg'));
end

