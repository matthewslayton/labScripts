%addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/NIfTI_20140122');
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/NIfTI_20140122
%addpath('/Users/matthewslayton/Documents/Duke/Duke_Spring2022/FSL_class/indiv_masks_resliced/')
addpath /Users/matthewslayton/Library/CloudStorage/OneDrive-DukeUniversity/STAMP/indiv_masks_resliced/






%% you need the header info etc, so this is how
% pcunL
PcunL_1 = load_untouch_nii('Pcun_L_4_1.nii');
PcunL_2 = load_untouch_nii('Pcun_L_4_2.nii');
PcunL_3 = load_untouch_nii('Pcun_L_4_3.nii');
PcunL_4 = load_untouch_nii('Pcun_L_4_4.nii');
% don't forget to add the header info
PcunL.('hdr') = PcunL_1.hdr;
PcunL.('filetype') = 2;
PcunL.('fileprefix') = 'subcortical';
PcunL.('machine') = 'ieee-le';
PcunL.('ext') = [];
PcunL.img = PcunL_1.img+PcunL_2.img+PcunL_3.img+PcunL_4.img;
PcunL.('untouch') = 1;
% save
save_untouch_nii(PcunL,'PcunL.nii')



%%%
% I identified a subset of regions that I want to look at that have even a
% small change of being relevant to the representation of linguistic
% categories.

% Cun L, Cun R, FuG L, FuG R, Hipp L, Hipp R, IFG L, IFG R, IPL L, IPL R,
% ITG L, ITG R, MFG L, MFG R, MTG L, MTG R, PhG L, PhG R, PoG L, PoG R, PrG
% L, PrG R, pSTS L, pSTS R, SFG L, SFG R, SPL L, SPL R, STG L, STG R, 

%%%


cunL1 = load_untouch_nii('Cun_L_5_1.nii');
cunL2 = load_untouch_nii('Cun_L_5_2.nii');
cunL3 = load_untouch_nii('Cun_L_5_3.nii');
cunL4 = load_untouch_nii('Cun_L_5_4.nii');
cunL5 = load_untouch_nii('Cun_L_5_5.nii');
cunL1.img = cunL1.img+cunL2.img+cunL3.img+cunL4.img+cunL5.img;
save_untouch_nii(cunL1,'cunL.nii')

cunR1 = load_untouch_nii('Cun_R_5_1.nii');
cunR2 = load_untouch_nii('Cun_R_5_2.nii');
cunR3 = load_untouch_nii('Cun_R_5_3.nii');
cunR4 = load_untouch_nii('Cun_R_5_4.nii');
cunR5 = load_untouch_nii('Cun_R_5_5.nii');
cunR1.img = cunR1.img+cunR2.img+cunR3.img+cunR4.img+cunR5.img;
save_untouch_nii(cunR1,'cunR.nii')

fugL1 = load_untouch_nii('FuG_L_3_1.nii');
fugL2 = load_untouch_nii('FuG_L_3_2.nii');
fugL3 = load_untouch_nii('FuG_L_3_3.nii');
fugL1.img = fugL1.img+fugL2.img+fugL3.img;
save_untouch_nii(fugL1,'fugL.nii')

fugR1 = load_untouch_nii('FuG_R_3_1.nii');
fugR2 = load_untouch_nii('FuG_R_3_2.nii');
fugR3 = load_untouch_nii('FuG_R_3_3.nii');
fugR1.img = fugR1.img+fugR2.img+fugR3.img;
save_untouch_nii(fugR1,'fugR.nii')

hippL1 = load_untouch_nii('Hipp_L_2_1.nii');
hippL2 = load_untouch_nii('Hipp_L_2_2.nii');
hippL1.img = hippL1.img+hippL2.img;
save_untouch_nii(hippL1,'hippL.nii')

hippR1 = load_untouch_nii('Hipp_R_2_1.nii');
hippR2 = load_untouch_nii('Hipp_R_2_2.nii');
hippR1.img = hippR1.img+hippR2.img;
save_untouch_nii(hippR1,'hippR.nii')

ifgL1 = load_untouch_nii('IFG_L_6_1.nii');
ifgL2 = load_untouch_nii('IFG_L_6_2.nii');
ifgL3 = load_untouch_nii('IFG_L_6_3.nii');
ifgL4 = load_untouch_nii('IFG_L_6_4.nii');
ifgL5 = load_untouch_nii('IFG_L_6_5.nii');
ifgL6 = load_untouch_nii('IFG_L_6_6.nii');
ifgL1.img = ifgL1.img+ifgL2.img+ifgL3.img+ifgL4.img+ifgL5.img+ifgL6.img;
save_untouch_nii(ifgL1,'ifgL.nii')

ifgR1 = load_untouch_nii('IFG_R_6_1.nii');
ifgR2 = load_untouch_nii('IFG_R_6_2.nii');
ifgR3 = load_untouch_nii('IFG_R_6_3.nii');
ifgR4 = load_untouch_nii('IFG_R_6_4.nii');
ifgR5 = load_untouch_nii('IFG_R_6_5.nii');
ifgR6 = load_untouch_nii('IFG_R_6_6.nii');
ifgR1.img = ifgR1.img+ifgR2.img+ifgR3.img+ifgR4.img+ifgR5.img+ifgR6.img;
save_untouch_nii(ifgR1,'ifgR.nii')

iplL1 = load_untouch_nii('IPL_L_6_1.nii');
iplL2 = load_untouch_nii('IPL_L_6_2.nii');
iplL3 = load_untouch_nii('IPL_L_6_3.nii');
iplL4 = load_untouch_nii('IPL_L_6_4.nii');
iplL5 = load_untouch_nii('IPL_L_6_5.nii');
iplL6 = load_untouch_nii('IPL_L_6_6.nii');
iplL1.img = iplL1.img+iplL2.img+iplL3.img+iplL4.img+iplL5.img+iplL6.img;
save_untouch_nii(iplL1,'iplL.nii')

iplR1 = load_untouch_nii('IPL_R_6_1.nii');
iplR2 = load_untouch_nii('IPL_R_6_2.nii');
iplR3 = load_untouch_nii('IPL_R_6_3.nii');
iplR4 = load_untouch_nii('IPL_R_6_4.nii');
iplR5 = load_untouch_nii('IPL_R_6_5.nii');
iplR6 = load_untouch_nii('IPL_R_6_6.nii');
iplR1.img = iplR1.img+iplR2.img+iplR3.img+iplR4.img+iplR5.img+iplR6.img;
save_untouch_nii(iplR1,'iplR.nii')

itgL1 = load_untouch_nii('ITG_L_7_1.nii');
itgL2 = load_untouch_nii('ITG_L_7_2.nii');
itgL3 = load_untouch_nii('ITG_L_7_3.nii');
itgL4 = load_untouch_nii('ITG_L_7_4.nii');
itgL5 = load_untouch_nii('ITG_L_7_5.nii');
itgL6 = load_untouch_nii('ITG_L_7_6.nii');
itgL7 = load_untouch_nii('ITG_L_7_7.nii');
itgL1.img = itgL1.img+itgL2.img+itgL3.img+itgL4.img+itgL5.img+itgL6.img+itgL7.img;
save_untouch_nii(itgL1,'itgL.nii')

itgR1 = load_untouch_nii('ITG_R_7_1.nii');
itgR2 = load_untouch_nii('ITG_R_7_2.nii');
itgR3 = load_untouch_nii('ITG_R_7_3.nii');
itgR4 = load_untouch_nii('ITG_R_7_4.nii');
itgR5 = load_untouch_nii('ITG_R_7_5.nii');
itgR6 = load_untouch_nii('ITG_R_7_6.nii');
itgR7 = load_untouch_nii('ITG_R_7_7.nii');
itgR1.img = itgR1.img+itgR2.img+itgR3.img+itgR4.img+itgR5.img+itgR6.img+itgR7.img;
save_untouch_nii(itgR1,'itgR.nii')

mfgL1 = load_untouch_nii('MFG_L_7_1.nii');
mfgL2 = load_untouch_nii('MFG_L_7_2.nii');
mfgL3 = load_untouch_nii('MFG_L_7_3.nii');
mfgL4 = load_untouch_nii('MFG_L_7_4.nii');
mfgL5 = load_untouch_nii('MFG_L_7_5.nii');
mfgL6 = load_untouch_nii('MFG_L_7_6.nii');
mfgL7 = load_untouch_nii('MFG_L_7_7.nii');
mfgL1.img = mfgL1.img+mfgL2.img+mfgL3.img+mfgL4.img+mfgL5.img+mfgL6.img+mfgL7.img;
save_untouch_nii(mfgL1,'mfgL.nii')

mfgR1 = load_untouch_nii('MFG_R_7_1.nii');
mfgR2 = load_untouch_nii('MFG_R_7_2.nii');
mfgR3 = load_untouch_nii('MFG_R_7_3.nii');
mfgR4 = load_untouch_nii('MFG_R_7_4.nii');
mfgR5 = load_untouch_nii('MFG_R_7_5.nii');
mfgR6 = load_untouch_nii('MFG_R_7_6.nii');
mfgR7 = load_untouch_nii('MFG_R_7_7.nii');
mfgR1.img = mfgR1.img+mfgR2.img+mfgR3.img+mfgR4.img+mfgR5.img+mfgR6.img+mfgR7.img;
save_untouch_nii(mfgR1,'mfgR.nii')

mtgL1 = load_untouch_nii('MTG_L_4_1.nii');
mtgL2 = load_untouch_nii('MTG_L_4_2.nii');
mtgL3 = load_untouch_nii('MTG_L_4_3.nii');
mtgL4 = load_untouch_nii('MTG_L_4_4.nii');
mtgL1.img = mtgL1.img+mtgL2.img+mtgL3.img+mtgL4.img;
save_untouch_nii(mtgL1,'mtgL.nii')

mtgR1 = load_untouch_nii('MTG_R_4_1.nii');
mtgR2 = load_untouch_nii('MTG_R_4_2.nii');
mtgR3 = load_untouch_nii('MTG_R_4_3.nii');
mtgR4 = load_untouch_nii('MTG_R_4_4.nii');
mtgR1.img = mtgR1.img+mtgR2.img+mtgR3.img+mtgR4.img;
save_untouch_nii(mtgR1,'mtgR.nii')

phgL1 = load_untouch_nii('PhG_L_6_1.nii');
phgL2 = load_untouch_nii('PhG_L_6_2.nii');
phgL3 = load_untouch_nii('PhG_L_6_3.nii');
phgL4 = load_untouch_nii('PhG_L_6_4.nii');
phgL5 = load_untouch_nii('PhG_L_6_5.nii');
phgL6 = load_untouch_nii('PhG_L_6_6.nii');
phgL1.img = phgL1.img+phgL2.img+phgL3.img+phgL4.img+phgL5.img+phgL6.img;
save_untouch_nii(phgL1,'phgL.nii')

phgR1 = load_untouch_nii('PhG_R_6_1.nii');
phgR2 = load_untouch_nii('PhG_R_6_2.nii');
phgR3 = load_untouch_nii('PhG_R_6_3.nii');
phgR4 = load_untouch_nii('PhG_R_6_4.nii');
phgR5 = load_untouch_nii('PhG_R_6_5.nii');
phgR6 = load_untouch_nii('PhG_R_6_6.nii');
phgR1.img = phgR1.img+phgR2.img+phgR3.img+phgR4.img+phgR5.img+phgR6.img;
save_untouch_nii(phgR1,'phgR.nii')

pogL1 = load_untouch_nii('PoG_L_4_1.nii');
pogL2 = load_untouch_nii('PoG_L_4_2.nii');
pogL3 = load_untouch_nii('PoG_L_4_3.nii');
pogL4 = load_untouch_nii('PoG_L_4_4.nii');
pogL1.img = pogL1.img+pogL2.img+pogL3.img+pogL4.img;
save_untouch_nii(pogL1,'pogL.nii')

pogR1 = load_untouch_nii('PoG_R_4_1.nii');
pogR2 = load_untouch_nii('PoG_R_4_2.nii');
pogR3 = load_untouch_nii('PoG_R_4_3.nii');
pogR4 = load_untouch_nii('PoG_R_4_4.nii');
pogR1.img = pogR1.img+pogR2.img+pogR3.img+pogR4.img;
save_untouch_nii(pogR1,'pogR.nii')

prgL1 = load_untouch_nii('PrG_L_6_1.nii');
prgL2 = load_untouch_nii('PrG_L_6_2.nii');
prgL3 = load_untouch_nii('PrG_L_6_3.nii');
prgL4 = load_untouch_nii('PrG_L_6_4.nii');
prgL5 = load_untouch_nii('PrG_L_6_5.nii');
prgL6 = load_untouch_nii('PrG_L_6_6.nii');
prgL1.img = prgL1.img+prgL2.img+prgL3.img+prgL4.img+prgL5.img+prgL6.img;
save_untouch_nii(prgL1,'prgL.nii')

prgR1 = load_untouch_nii('PrG_R_6_1.nii');
prgR2 = load_untouch_nii('PrG_R_6_2.nii');
prgR3 = load_untouch_nii('PrG_R_6_3.nii');
prgR4 = load_untouch_nii('PrG_R_6_4.nii');
prgR5 = load_untouch_nii('PrG_R_6_5.nii');
prgR6 = load_untouch_nii('PrG_R_6_6.nii');
prgR1.img = prgR1.img+prgR2.img+prgR3.img+prgR4.img+prgR5.img+prgR6.img;
save_untouch_nii(prgR1,'prgR.nii')

pstsL1 = load_untouch_nii('pSTS_L_2_1.nii');
pstsL2 = load_untouch_nii('pSTS_L_2_2.nii');
pstsL1.img = pstsL1.img+pstsL2.img;
save_untouch_nii(pstsL1,'pstsL.nii')

pstsR1 = load_untouch_nii('pSTS_R_2_1.nii');
pstsR2 = load_untouch_nii('pSTS_R_2_2.nii');
pstsR1.img = pstsR1.img+pstsR2.img;
save_untouch_nii(pstsR1,'pstsR.nii')

sfgL1 = load_untouch_nii('SFG_L_7_1.nii');
sfgL2 = load_untouch_nii('SFG_L_7_2.nii');
sfgL3 = load_untouch_nii('SFG_L_7_3.nii');
sfgL4 = load_untouch_nii('SFG_L_7_4.nii');
sfgL5 = load_untouch_nii('SFG_L_7_5.nii');
sfgL6 = load_untouch_nii('SFG_L_7_6.nii');
sfgL7 = load_untouch_nii('SFG_L_7_7.nii');
sfgL1.img = sfgL1.img+sfgL2.img+sfgL3.img+sfgL4.img+sfgL5.img+sfgL6.img+sfgL7.img;
save_untouch_nii(sfgL1,'sfgL.nii')

sfgR1 = load_untouch_nii('SFG_R_7_1.nii');
sfgR2 = load_untouch_nii('SFG_R_7_2.nii');
sfgR3 = load_untouch_nii('SFG_R_7_3.nii');
sfgR4 = load_untouch_nii('SFG_R_7_4.nii');
sfgR5 = load_untouch_nii('SFG_R_7_5.nii');
sfgR6 = load_untouch_nii('SFG_R_7_6.nii');
sfgR7 = load_untouch_nii('SFG_R_7_7.nii');
sfgR1.img = sfgR1.img+sfgR2.img+sfgR3.img+sfgR4.img+sfgR5.img+sfgR6.img+sfgR7.img;
save_untouch_nii(sfgR1,'sfgR.nii')

splL1 = load_untouch_nii('SPL_L_5_1.nii');
splL2 = load_untouch_nii('SPL_L_5_2.nii');
splL3 = load_untouch_nii('SPL_L_5_3.nii');
splL4 = load_untouch_nii('SPL_L_5_4.nii');
splL5 = load_untouch_nii('SPL_L_5_5.nii');
splL1.img = splL1.img+splL2.img+splL3.img+splL4.img+splL5.img;
save_untouch_nii(splL1,'splL.nii')

splR1 = load_untouch_nii('SPL_R_5_1.nii');
splR2 = load_untouch_nii('SPL_R_5_2.nii');
splR3 = load_untouch_nii('SPL_R_5_3.nii');
splR4 = load_untouch_nii('SPL_R_5_4.nii');
splR5 = load_untouch_nii('SPL_R_5_5.nii');
splR1.img = splR1.img+splR2.img+splR3.img+splR4.img+splR5.img;
save_untouch_nii(splR1,'splR.nii')

stgL1 = load_untouch_nii('STG_L_6_1.nii');
stgL2 = load_untouch_nii('STG_L_6_2.nii');
stgL3 = load_untouch_nii('STG_L_6_3.nii');
stgL4 = load_untouch_nii('STG_L_6_4.nii');
stgL5 = load_untouch_nii('STG_L_6_5.nii');
stgL6 = load_untouch_nii('STG_L_6_6.nii');
stgL1.img = stgL1.img+stgL2.img+stgL3.img+stgL4.img+stgL5.img+stgL6.img;
save_untouch_nii(stgL1,'stgL.nii')

stgR1 = load_untouch_nii('STG_R_6_1.nii');
stgR2 = load_untouch_nii('STG_R_6_2.nii');
stgR3 = load_untouch_nii('STG_R_6_3.nii');
stgR4 = load_untouch_nii('STG_R_6_4.nii');
stgR5 = load_untouch_nii('STG_R_6_5.nii');
stgR6 = load_untouch_nii('STG_R_6_6.nii');
stgR1.img = stgR1.img+stgR2.img+stgR3.img+stgR4.img+stgR5.img+stgR6.img;
save_untouch_nii(stgR1,'stgR.nii')


GyriOfInterest={'Amy','Hipp'}; %%%% etc

for gyr = 1:length(GyriOfInterest)
    curgyr = GyriOfInterest(gyr,1);

    fileName = strcat(curgyr,'L_2_1');

    %second for loop to count how many files there are and how to add the
    %numbers
Amy1= load_untouch_nii('Amyg_L_2_1.nii');
% we get a struct
% want IMG which is the 3D matrix of 1s and 0s
% will have to decide if you want to combine hemispheres, but the voxels
% won't be continuous, so maybe not
Amy2 = load_untouch_nii('Amyg_L_2_2.nii');

Amy1.img = Amy1.img+Amy2.img;


save_untouch_nii(Amy1,'Amyg.nii')

end


Gyriofinterest={'Amy','Hipp'};
for gyr=1:length(Gyriofinterest}
  curgyr=Gyriofinterest(gyr,1)
  filename=strcat(curgyri,'L_2_1')
Amy1=load_untouch_nii('Amyg_L_2_1.nii');
Amy2=load_untouch_nii('Amyg_L_2_2.nii');
Amy1.img=Amy1.img+Amy2.img;
save_untouch_nii(Amy1, 'Amyg.nii');
end