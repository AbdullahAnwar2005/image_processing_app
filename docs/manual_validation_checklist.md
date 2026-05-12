# Manual Validation Checklist: Multimedia Expansion

This document outlines the manual verification steps for features that are difficult to fully automate, such as video frame extraction and gallery integration.

## 1. Multimedia Import (Phase 8)
- [ ] **Image Picking**: Verify that "Import Image" still opens the gallery and loads JPG/PNG correctly.
- [ ] **Video Picking**: Tap "Extract Frame from Video". Select a valid `.mp4` or `.mov` file.
- [ ] **Extraction Confirmation**: Verify a SnackBar appears: *"Video frame extracted successfully."*
- [ ] **Visual Check**: Verify the extracted frame is displayed in the comparison workspace.
- [ ] **Timestamp Accuracy**: Verify the frame is not black (should be around the 1-second mark).

## 2. Dynamic Image Pipeline
- [ ] **Grayscale on Video Frame**: Apply Grayscale to the extracted video frame.
- [ ] **Edge Detection on Video Frame**: Apply Sobel or Laplacian to the extracted video frame.
- [ ] **Geometric Transformation**: Rotate and Flip the video frame. Verify dimensions change correctly.
- [ ] **Histogram Sync**: Check if the histogram updates to reflect the distribution of the video frame.

## 3. Gallery Export
- [ ] **Save Image**: Apply a filter to an extracted video frame and tap "Export Image".
- [ ] **Verification**: Open the device gallery/photos app and verify the processed image exists with high quality.

## 4. Error Handling
- [ ] **Cancel Selection**: Open the picker and tap "Cancel". App should not crash or show an error.
- [ ] **Unsupported File**: Try to pick a non-media file if the picker allows. App should show a red SnackBar: *"Could not import image/video."*

---
*Verified by: [Your Name/ID]*
*Date: 2026-05-11*
