<img width="1627" height="939" alt="image" src="https://github.com/user-attachments/assets/9912e56f-b47a-40e9-a4bd-81e47bd4ecb6" />

# PPD and DVA Calculator

This repository contains a MATLAB app for converting between:

- display size in centimeters
- display size in pixels
- degrees of visual angle (DVA)
- pixels per degree (PPD)

The app also lets you model horizontal and vertical subject eye-position offsets relative to the screen center, then visualizes the resulting geometry in side and front views.

## File

- `ppd_dva_app.m`: main MATLAB UI app

## What the App Does

The app builds a small interactive GUI with:

- editable display parameters
- conversion controls for DVA, diameter in centimeters, and diameter in pixels
- subject eye-position offsets in X and Y
- a side-view geometry plot
- a front-view schematic plot
- a text panel showing computed values and formulas

The stimulus is modeled as a centered circle on the screen.

## Default Parameters

When launched, the app starts with:

- screen width: `70 cm`
- horizontal resolution: `1920 px`
- viewing distance: `80 cm`
- eye offset X: `0 cm`
- eye offset Y: `0 cm`
- convert from: `DVA (deg)`
- value: `3`
- display rounding: `2`

## Inputs

The GUI exposes these inputs:

- `Screen width (cm)`
- `Screen X pixels`
- `Viewing distance D (cm)`
- `Convert from`
- `Value`
- `Subject offset X (cm)`
- `Subject offset Y (cm)`
- `Display rounding`

`Convert from` supports:

- `DVA (deg)`
- `Diameter (cm)`
- `Diameter (px)`

## Outputs

The app computes and displays:

- horizontal pixel density in `px/cm`
- horizontal and vertical `px/deg` at screen center
- stimulus diameter in `cm` and `px`
- stimulus radius in `cm` and `px`
- angular diameter in X and Y
- mean angular diameter
- eye-to-screen-center distance

## Geometry Notes

- The observer eye position is modeled as `[eyeX, eyeY, -D]`.
- The screen center is modeled as `[0, 0, 0]`.
- Horizontal and vertical angular diameters can differ when the observer is off-axis.
- When converting from DVA, the app solves for the circle diameter whose mean angular size matches the requested DVA.

## How to Run

Open MATLAB in this folder and run:

```matlab
ppd_dva_app
```
