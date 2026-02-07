## Biomedical Signal Processing: Bubble Entropy Implementation

## Project Overview

This project focuses on the implementation and clinical validation of the **Bubble Entropy (BEn)** algorithm, an entropy measure designed to be almost free of parameters for time-series analysis.

Developed during my Erasmus+ exchange program at the **Universit?? degli Studi di Milano** for the **Biomedical Signal Processing** course. The study validates the discriminating power of BEn against the industry-standard **Sample Entropy (SampEn)** using real-world clinical data.

## Tech Stack & Architecture

-   **Language:** MATLAB

-   **Domain:** Biomedical Signal Processing, Heart Rate Variability (HRV)

-   **Data Source:** PhysioNet (NSR2DB and CHF2DB)

-   **Architecture:** Modular pipeline (ETL + Modeling + Visualization)

### Pipeline Structure:

1.  **Data Loading:** `load_data.m` extracts QRS locations and RR intervals from raw ECG.

2.  **Signal Conditioning:** `extract_rr_intervals.m` performs outlier removal (non-physiological beats) and adaptive detrending.

3.  **Entropy Kernels:**

    -   `bubble_entropy.m` & `count_bubble_swaps.m` (The core BEn implementation).

    -   `sample_entropy.m` (The benchmark implementation).

4.  **Analysis & Results:** `main_script.m` runs the full comparison and saves the computed metrics into `results.mat`.

5.  **Visualization:** `plot_results.m` and `plot_disorder_distribution.m` generate the statistical plots.

## Technical Highlights

-   **Paper-to-Code Implementation:** Translated the mathematical framework from the reference paper into functional code, specifically the transformation of Bubble Sort swap counts into a R??nyi Entropy measure.

-   **Parameter Robustness:** Validated that Bubble Entropy eliminates the need for the similarity threshold ($r$) and reduces sensitivity to the embedding dimension ($m$).

-   **Statistical Significance:** Proved that BEn provides superior discrimination ($p$ \< 0.05) between healthy subjects and patients with **Congestive Heart Failure (CHF)**, even in cases where Sample Entropy results were overlapping.

## Results

-   **`results.mat`**: Contains the pre-computed entropy values, p-values, and statistical distributions for both NSR and CHF groups across all tested dimensions.

-   **Clinical Insight:** The implementation confirms that BEn is a more reliable biomarker for heart rhythm complexity due to its parameter stability.

## Repository Structure

-   `/code`: Full suite of 8 MATLAB scripts.

-   `/docs`: Technical presentation (`Project_Presentation.pdf`).

-   `results.mat`: Saved output from the main analysis pipeline.

## Reference

Implementation and validation based on:

> *Manis, G., Aktaruzzaman, M., & Sassi, R. (2017). "Bubble entropy: An entropy almost free of parameters". IEEE Transactions on Biomedical Engineering.*
