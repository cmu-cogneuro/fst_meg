function recon_averaging(pics1,configs_150,mask)

% Reconstructs face images from neural data and implements first step in
% assessing reconstruction performance.
%MDV Dec 2015

% Inputs:
%1. pics1 - structure with n face images in LAB color space
%2. configs_150 - MDS solution for neural data at current time point.
%Matrix must take the form n * p, where n is the number of face identities
%and p is the number of dimensions in the MDS solution.
%3. mask - binary image defining an oval mask. size must match the first two dimensions of face images. All processing of face images
%occurs within the mask.

% Copyright (C) Mark Vida
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


% SEtup environmental variables
k = 5; %number of faces included in average
n = 91; %number of face identities in set
height = 206; % height of face images
width = 150; %width of face images

% Pre-allocate space to store face images and reconstructions.
cors_lum = zeros(n,n,length(time));
cors_a = zeros(n,n,length(time));
cors_b = zeros(n,n,length(time));
curface_lum_all = zeros(height,width,n);
recons_lum_all = zeros(height,width,n);
curface_a_all = zeros(height,width,n);
recons_a_all = zeros(height,width,n);
curface_b_all = zeros(height,width,n);
recons_b_all = zeros(height,width,n);


%     Divide original face images into separate channels
for curFace = 1:n
    recon_lab = pics1(curFace).img;
    curface_lum_all(:,:,curFace) = recon_lab(:,:,1);
    curface_a_all(:,:,curFace) = recon_lab(:,:,2);
    curface_b_all(:,:,curFace) = recon_lab(:,:,3);
end


%    Calculate Euclidean distances between all face identities in MDS solution space
D = pdist2(configs_150,configs_150);
neighbors = zeros(n,k);  %Create variable to store faces similar to target face
%   Loop through target faces
for faces = 1:n
    %                 %Identify k faces closest to the target face in MDS
    %                 solution space
    curD = D(faces,:);
    [sortedValues sortIndex] = sort(curD,'ascend');
    neighbors(faces,:) = sortIndex(2:k+1);
end

%                 For each target face, average k closest face images
%                 within each image channel in LAB color space
for faces = 1:n
    currecon_lum = curface_lum_all(:,:,neighbors(faces,:));
    currecon_lum = mean(currecon_lum,3);
    currecon_all_lum(:,:,faces) = currecon_lum;
    
    currecon_a = curface_a_all(:,:,neighbors(faces,:));
    currecon_a = mean(currecon_a,3);
    currecon_all_a(:,:,faces) = currecon_a;
    
    currecon_b = curface_b_all(:,:,neighbors(faces,:));
    currecon_b = mean(currecon_b,3);
    currecon_all_b(:,:,faces) = currecon_b;
end

%Compute Pearson correlation between each reconstruction and each original
%face image. These correlations are used to assess reconstruction accuracy.
for curFace = 1:n
    for compFace = 1:n
%         Extract original images for comparison
        orig_lum = curface_lum_all(:,:,compFace);
        orig_a = curface_a_all(:,:,compFace);
        orig_b = curface_b_all(:,:,compFace);
%         Extract reconstruction for comparison
        currecon_lum = currecon_all_lum(:,:,curFace);
        currecon_a = currecon_all_a(:,:,curFace);
        currecon_b = currecon_all_b(:,:,curFace);
%         Compare reconstruction to original image
        corL = corr(currecon_lum(mask==1),orig_lum(mask==1));
        cora = corr(currecon_a(mask==1),orig_a(mask==1));
        corb = corr(currecon_b(mask==1),orig_b(mask==1));
        cors_lum(curFace,compFace) = corL;
        cors_a(curFace,compFace) = cora;
        cors_b(curFace,compFace) = corb;
    end
end

% Save reconstructions and correlations for next step.
save cors_lum.mat cors_lum
save recons_lum.mat currecon_all_lum
save cors_a.mat cors_a
save recons_a.mat currecon_all_a
save cors_b.mat cors_b
save recons_b.mat currecon_all_b
save neighbors.mat neighbors

