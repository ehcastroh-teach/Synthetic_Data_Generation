# Synthetic Data Generation

This repository teaches self-learners two complementary strategies for generating synthetic tabular data. The first approach treats a small, domain-specific seed CSV as an empirical distribution and bootstraps a larger dataset from it using custom pandas/NumPy sampling functions - then puts that data to work on real classification and regression problems. The second approach uses scikit-learn's built-in dataset generators (`make_regression`, `make_classification`, `make_blobs`, `make_circles`) to produce benchmark problems with fully controlled statistical properties, which lets you study how an algorithm behaves as a function of noise, class separation, or cluster geometry rather than real-world messiness.

## Learning Objectives

- Bootstrap a large synthetic dataset from a small seed CSV by writing type-aware column generators (binary, integer, float, categorical string) and composing them into a single pandas DataFrame
- Intentionally skew marginal distributions using a `change_split` utility to inject realistic class imbalance into synthetic data
- Apply four classifiers spanning the bias-variance spectrum (Logistic Regression, Decision Tree, Random Forest, Gradient Boosting) to a binary churn-prediction problem and compare their held-out accuracy
- Engineer a composite time feature (`PERIOD`) from raw year and quarter columns to improve temporal regression performance
- Fit Linear Regression on a log-transformed continuous target and interpret R-squared, MAE, and MSE outputs
- Generate regression benchmark problems with `make_regression` and distinguish informative features from noise distractors using the `coef` return value
- Generate classification problems with `make_classification` and understand how `class_sep` controls problem difficulty
- Generate clustering benchmark problems with `make_blobs` and `make_circles` and explain why isotropic distance metrics fail on non-convex geometry

## Data / File Dictionary

| File | Description |
|---|---|
| `01_synthetic_data_generation_applied.ipynb` | Builds a 500-row synthetic donor dataset from seed CSVs, runs churn classification across four models, and predicts continuous contribution amounts with regression |
| `02_synthetic_data_generation_sklearn.ipynb` | Generates regression, classification, and clustering benchmark datasets using sklearn's `make_*` generators with tunable noise and separation parameters |
| `synthetic_data_generation_applied_homework.ipynb` | Homework companion to Notebook 1 - guided exercises on building a synthetic dataset, classifying churn, and generalizing the generator pattern to the sklearn wine dataset |
| `synthetic_data_generation_sklearn_homework.ipynb` | Homework companion to Notebook 2 - guided exercises on the sklearn generators |
| `data_seeds/intern_dropouts_seed.csv` | 20-row seed of illustrative intern-dropout records; columns include Distance, GPA, Class, Gender, Ethnicity, Low-income, Sector, and Churned |
| `data_seeds/donation_history_seed.csv` | 20-row seed of illustrative donation-history records; columns include Quarter, Year, Method, Luncheon, Parent, Alumni, Board, and Amount |
| `requirements.txt` | Pinned Python package dependencies for reproducing the notebooks |

## Workflow Diagram

```
data_seeds/intern_dropouts_seed.csv         data_seeds/donation_history_seed.csv
          |                                              |
          v                                              v
01_synthetic_data_generation_applied.ipynb
  Part 1: Type-aware generators produce a 500-row synthetic table
  Part 2: Churn analysis - EDA, baseline, and four classifiers
  Part 3: Contribution prediction - feature engineering and regression models
          |
          | (independent - does not require output from Notebook 1)
          v
02_synthetic_data_generation_sklearn.ipynb
  Part 0: Why synthetic datasets exist
  Part 1: Regression  - make_regression, noise sweep
  Part 2: Classification - make_classification, class_sep sweep
  Part 3: Clustering - make_blobs (isotropic and anisotropic) and make_circles
```

## Step-by-Step Walkthrough

### Notebook 1 - Domain-specific synthetic data from a seed

**Part 1 starts from a practical problem:** real-world labeled datasets are scarce, slow to collect, and often cannot be shared due to privacy constraints. Rather than waiting, you treat a 20-row seed CSV as an empirical distribution. Each column is sampled independently to produce a table fifty times larger, preserving the rough shape of the original without copying any actual records.

A key design decision is writing separate generator functions for each column type - binary flags, integers, floats, and categorical strings - rather than a single monolithic sampler. This makes the assumption behind each column explicit and swappable. If you later discover that GPA is better modeled by a Gaussian than a uniform draw, you replace one function without touching the rest.

The `change_split` utility deliberately skews marginal distributions before label encoding. This matters because real populations are rarely balanced, and a classifier trained on a perfectly uniform synthetic dataset will behave differently from one trained on a skewed one.

**Part 2 uses the synthetic data to run a real modeling workflow.** Before fitting any model, the notebook establishes a majority-class baseline accuracy. Any model that cannot beat this number is not learning from the features. Four classifiers are then trained on the same train/test split so their accuracies are directly comparable: Logistic Regression as a linear baseline, Decision Tree as a single interpretable non-linear model, Random Forest as a variance-reducing ensemble of trees, and Gradient Boosting as a bias-reducing sequential ensemble.

**Part 3 applies the same generator pattern to a donation-history seed**, but now the target is continuous (donation amount) rather than binary. A `PERIOD` feature is engineered by combining the year and quarter columns into a single ordinal, which lets the regression model treat time as a monotone variable rather than two separate unordered categories. The target is log-transformed before fitting Linear Regression, because raw dollar amounts are right-skewed and the log scale brings the distribution closer to the normal assumption that OLS relies on. Logistic Regression on bucketed amounts is fit alongside it as a comparison - trading fine-grained amount prediction for calibrated class probabilities.

### Notebook 2 - Benchmark datasets with scikit-learn generators

This notebook approaches synthetic data from the opposite direction: instead of starting from domain knowledge, it uses generators whose data-generating process is fully known. This is the right tool when you want to isolate one axis of difficulty and watch how model performance responds.

**Part 1 demonstrates `make_regression`** with two cases - a noiseless linear problem and the same problem with Gaussian noise added. The noiseless case exists to confirm that your model can recover a known slope exactly; the noisy case shows how quickly the estimated coefficient drifts as noise grows. The `coef=True` parameter returns the ground-truth coefficients, so you can compare what the model learned against what the generator used.

**Part 2 demonstrates `make_classification`** with the `class_sep` parameter as the primary knob. Lower separation means class centroids are closer together, more points from one class land in the other class's territory, and any classifier will make more errors. Plotting every pair of features before fitting a model shows you exactly how separable the problem is.

**Part 3 covers three clustering geometries.** Isotropic blobs (`make_blobs`) are the easy case: every distance-based algorithm will agree on the partition. Anisotropic blobs are the same data after a linear transformation that stretches clusters into ellipses; KMeans, which assumes Euclidean distance is the right metric, will misassign points along the elongation axis. Concentric rings (`make_circles`) break linear separability entirely - there is no linear boundary that divides the inner ring from the outer ring, which motivates kernel methods and spectral clustering.

## How to Run

```bash
# Clone the repository
git clone https://github.com/ehcastroh-teach/Synthetic_Data_Generation.git
cd Synthetic_Data_Generation

# Install dependencies into a virtual environment
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Open the notebooks in order (Notebook 2 is independent and can be run first)
jupyter notebook 01_synthetic_data_generation_applied.ipynb
jupyter notebook 02_synthetic_data_generation_sklearn.ipynb

# Homework companions (after completing the lesson notebooks)
jupyter notebook synthetic_data_generation_applied_homework.ipynb
jupyter notebook synthetic_data_generation_sklearn_homework.ipynb
```

Run cells top to bottom in each notebook. The data seed CSVs must remain at `data_seeds/intern_dropouts_seed.csv` and `data_seeds/donation_history_seed.csv` relative to the working directory. The two lesson notebooks are independent of each other.

## Key Concepts Glossary

| Term | Definition |
|---|---|
| Synthetic data | Data that is algorithmically generated to resemble real data without coming from direct observation of the phenomenon |
| Seed dataset | A small real dataset used as a statistical reference for sampling; it is not used directly in analysis, only as a source of distributional information |
| Bootstrap sampling | Drawing samples with replacement from an observed distribution to produce a larger sample that preserves the marginal shape of the original |
| Label encoding | Converting categorical string values to integers so they can be passed to sklearn estimators that require numeric input |
| Churn | The event of a person (customer, donor, user) stopping their engagement; modeled here as a binary outcome per record |
| Class imbalance | A condition where one class in a classification problem has many more examples than another; it inflates majority-class accuracy and can hide poor minority-class performance |
| Informative feature | A feature generated by `make_regression` or `make_classification` that carries a non-zero coefficient in the true relationship; features that carry zero coefficient are noise distractors |
| Class separation (`class_sep`) | In `make_classification`, the scalar that controls how far apart the centroids of different class clusters are; higher separation yields a trivially separable problem |
| Isotropic blob | A cluster of points sampled from a spherical Gaussian; all directions have equal spread, which satisfies the assumptions of Euclidean distance metrics like KMeans |
| Anisotropic blob | A cluster produced by applying a linear transformation to a spherical blob; the resulting elliptical shape violates the equal-spread assumption of KMeans |
| Concentric rings | The geometry produced by `make_circles` - two classes arranged as inner and outer rings with no linear decision boundary separating them |
| Residual | The difference between a model's prediction and the true target value; patterns in residuals reveal violated model assumptions or missing features |
| Log-transformation | Applying a logarithm to a right-skewed continuous target before regression; this compresses large values and brings the distribution closer to the normality assumption that OLS requires |

## Further Reading

- scikit-learn User Guide - Dataset Generators
- scikit-learn User Guide - Ensemble Methods
- "An Introduction to Statistical Learning" - chapters on classification, regression, and resampling methods
- Synthetic Data Vault (SDV) documentation
- pandas Documentation - DataFrame Construction and Column Operations
- NumPy Documentation - Random Sampling Reference

## Credits and Acknowledgements

Seed datasets represent anonymized, illustrative records modeled after a non-profit volunteer and donor context. No real personal data was used.

---

## Contact

<div align="center">
  <img src="images/thumbnails/ehcastroh_teach_banner_flower.png" alt="ehcastroh" width="90" style="border-radius: 50%;" />

  <sub>ehcastroh</sub>

  <a href="https://github.com/ehcastroh">GitHub</a> · <a href="https://www.linkedin.com/in/ehcastroh/">LinkedIn</a>
</div>
