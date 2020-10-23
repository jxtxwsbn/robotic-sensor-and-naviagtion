buildingScene2 = imageDatastore('camera_pose/');
for i = 1:7
    I = readimage(buildingScene2, i);
warpedImage = imwarp(I, tforms(i), 'OutputView', panoramaView);
figure(i)
imshow(warpedImage)
end