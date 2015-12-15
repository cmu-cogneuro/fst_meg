function recon_accuracy(cors_lum,cors_a,cors_b,neighbours)

%Takes correlation matrices output by recon_averaging.m and computes reconstruction accuracy
%MDV Dec 2015

%Inputs:
%1. cors_lum, cors_a, cors_b - matrix of correlation values between
%reconstructions and original face image, of the form n * b, where n and b
%are the reconstructions and original face images, respectively.
%number 
%2. Matrix containing identities included in each reconstruction, of form n
%* k, where n is the number of identities reconstructed and k is the number
%of identities included in the reconstruction

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

%Setup environmental variables
n = 91; %number of face identities
k = 5; %number of faces included in reconstruction

% Loop through 3 image channels
for curChan = 1:3
    if curChan == 2
        cors_lum = cors_a;
    elseif curChan == 3
        cors_lum = cors_b;
    end
  
% Pre-allocate variables to save space
accuracy = zeros(n,1);

% Loop through reconstructions
for currecon = 1:n
currow = cors_lum(currecon,:); %Load correlations for current reconstructed identity
neighbours_currecon = neighbours(currecon,:); %Get neighbors for current reconstruction
orig_cor = currow(currecon);  %Isolate correlation between current reconstruction and corresponding orriginal identity
others_cor = currow;
others_cor([currecon neighbours_currecon])=[]; %Remove correlation between current reconstruction and corresponding original face image, and do so for images included in reconstruction.
acc_cases = sum(others_cor<orig_cor); %Find number of cases in which correlation with original target face is higher than correlation with non-target faces
accuracy(currecon) = acc_cases/(n-1-k); %Convert to proportion - note that denominator is the number of face identities in total excluding the target face and the faces included in the reconstruction.
% Do CI for accuracy here
end
end
save(sprintf('accuracy_%s.mat',num2str(curChan)),'accuracy') %Save accuracy


 
