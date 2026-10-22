# Chewing Sound Classifier

An iOS app that listens to audio and classifies chewing sounds in real time, powered by a custom sound classification model trained with **Create ML** and run on-device with **Core ML** and Apple's **Sound Analysis** framework.


## Overview

This project explores whether everyday eating sounds can be recognised automatically. The app captures audio from the microphone, runs it through a Core ML model, and displays the predicted sound class along with a confidence score. Everything runs on-device, so no audio is uploaded or stored.

## Features

- Real-time audio classification from the microphone
- Custom Core ML model trained in Create ML (Sound Classification template)
- Confidence score for each prediction
- On-device inference with no network connection required


### Dataset

Audio clips are organised in one folder per class using this kaggle link : https://www.kaggle.com/datasets/mashijie/eating-sound-collection

