# MVL Face Datasets

## About the Project

_MVL Face Datasets_ is a collection of image processing pipelines written in MATLAB that generate variations of well-known face datasets. The current collection includes following pipelines:

* _KDEF-masked_ pipeline generates masked face images from the [Karolinska Directed Emotional Faces (KDEF) dataset](https://www.kdef.se).

* _CFD-masked_ pipeline generates masked face images from the [Chicago Face Database (CFD)](https://www.chicagofaces.org).

* _CFD-cutout_ pipeline generates color, grayscale, and lightness-matched face-cutout images from the [CFD](https://www.chicagofaces.org).

## Dependencies

All pipelines rely on [MatConvNet 1.0-beta25](https://github.com/vlfeat/matconvnet) and [OpenFace 2.2.0](https://github.com/TadasBaltrusaitis/OpenFace) for facial landmark detection. _CFD-cutout_ pipeline uses [SHINE toolbox](https://doi.org/10.3758/BRM.42.3.671) to match lightness histograms across images.

## Getting Started

Before running each pipeline, please run the following script to download and set up required libraries (MatConvNet, OpenFace, and SHINE toolbox):
```
>> Step0_Libraries
```

Pipelines can be found under the `pipelines/` directory.

### KDEF-masked

To generate masked face images from KDEF:
1) Download `KDEF_and_AKDEF.zip` file from [https://www.kdef.se](https://www.kdef.se) and unpack it.
2) Copy `KDEF/` directory and paste it under `pipelines/KDEF-masked/` directory.
3) Change the MATLAB working directory to the `pipelines/KDEF-masked/` directory.
4) Run the following scripts:
```
>> Step1_PrepareImages
>> Step2_DetectLandmarks
>> Step3_BuildDataset
```
5) Please check `imgs-dataset/` directory for masked face images, `dataset.xlsx` and `dataset.mat` files for the map of image names for each model × expression × angle.

### CFD-masked

To generate masked face images from CFD:
1) Download `cfd.zip` file from [https://www.chicagofaces.org](https://www.chicagofaces.org) and unpack it.
2) Copy `CFD/` directory (found under `CFD Version 3.0/Images/`) directory and paste it under `pipelines/CFD-masked/` directory.
3) Change the MATLAB working directory to the `pipelines/CFD-masked/` directory.
4) Run the following scripts:
```
>> Step1_PrepareImages
>> Step2_DetectLandmarks
>> Step3_BuildDataset
```
5) Please check _imgs-dataset/_ directory for masked face images, _dataset.xlsx_ and _dataset.mat_ files for the list of image names for each model.

### CFD-cutout

To generate face-cutout images from CFD:
1) Download `cfd.zip` file from [https://www.chicagofaces.org](https://www.chicagofaces.org) and unpack it.
2) Copy `CFD/` directory (found under `CFD Version 3.0/Images/`) directory and paste it under `pipelines/CFD-cutout/` directory.
3) Change the MATLAB working directory to the `pipelines/CFD-cutout/` directory.
4) Run the following scripts:
```
>> Step1_PrepareImages
>> Step2_DetectLandmarks
>> Step3_CutoutImages
>> Step4_BuildDataset
```
5) Please check _imgs-dataset/_ directory for face-cutout images, _dataset.xlsx_ and _dataset.mat_ files for the list of image names for each model.

## Acknowledgment

This work was supported by the National Research Foundation of Korea (NRF) grant funded by the Korea government (Ministry of Science and ICT) (No. 2022R1C1C1008628). 
