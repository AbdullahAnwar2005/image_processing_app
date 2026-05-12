# Image Filters Lab: 5-Minute Demo Script

This script provides a structured flow for presenting the Image Filters Lab app to an instructor or panel.

## 1. Introduction (30 Seconds)
- **Action**: Open the app to the **Empty State** landing page.
- **Narrative**: "Welcome to the Image Filters Lab. This is a Flutter-based multimedia application built for CPIT-380. Unlike standard apps, every algorithm here—from grayscale to edge detection—is implemented manually at the pixel level to demonstrate core multimedia principles."

## 2. Media Import & Pipeline (1 Minute)
- **Action**: Tap **"Process Image"** and pick a colorful photo.
- **Action**: Point out the **"Active Pipeline"** section (currently empty).
- **Narrative**: "The app uses a non-destructive pipeline. As we apply filters, notice the 'Active Pipeline' summary at the top. This tracks the order of operations, ensuring the results are mathematically consistent."

## 3. Intensity & Histograms (1 Minute)
- **Action**: Scroll to **"Pixel Operations"** and toggle **Grayscale**.
- **Action**: Expand the **"Histogram"** section. Change bin counts (16 $\rightarrow$ 256).
- **Action**: Toggle **Equalization**.
- **Narrative**: "We can analyze the image intensity through the histogram. By increasing the bin count, we see finer distribution details. Histogram Equalization allows us to enhance contrast by redistributing these intensities using a Cumulative Distribution Function (CDF)."

## 4. Spatial Filtering & Edges (1 Minute)
- **Action**: Toggle **Grayscale** off. Toggle **Edges**. Switch between **Sobel** and **Laplacian**.
- **Action**: Increase **Smoothing Strength** and switch to **Median**.
- **Narrative**: "Here we demonstrate spatial filtering. Sobel uses first-order derivatives to find gradients, while Laplacian uses second-order derivatives for fine details. For noise reduction, we've implemented linear filters like Weighted Average and non-linear ones like the Median filter, which is excellent for removing salt-and-pepper noise."

## 5. Geometry & Video (1 Minute)
- **Action**: Reset all. Rotate the image 90° and Flip it.
- **Action**: Go back to the main screen. Tap **"Extract Video Frame"**.
- **Action**: Pick a video, wait for extraction, and show the resulting frame in the workspace.
- **Narrative**: "The app supports geometric transformations like stateful rotations and reflections. We also expanded the scope to multimedia; here I've extracted a high-quality still frame from a video file. This frame is now part of our unified pipeline and can be processed exactly like an image."

## 6. Closing & Quality (30 Seconds)
- **Action**: Tap **"Export Final Image"**.
- **Action**: Mention the **"About"** section and the **41 automated tests**.
- **Narrative**: "To ensure reliability, the project includes 41 automated unit tests verifying the mathematical correctness of our algorithms. The app is optimized with slider debouncing and background isolates for a smooth user experience. Thank you!"

---
*Note: Ensure the device is in Light Mode for the best UI visibility during recording.*
