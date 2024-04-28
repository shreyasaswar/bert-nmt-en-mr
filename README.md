# BERT-Fused Neural Machine Translation for Low-Resource Languages

This repository presents an implementation of BERT-Fused Neural Machine Translation (NMT) model tailored for low-resource language pairs, with a specific focus on the English-Marathi translation task.

If you find this work helpful in your research, please cite the original reasearch as:

@inproceedings{
Zhu2020Incorporating,
title={Incorporating BERT into Neural Machine Translation},
author={Jinhua Zhu and Yingce Xia and Lijun Wu and Di He and Tao Qin and Wengang Zhou and Houqiang Li and Tieyan Liu},
booktitle={International Conference on Learning Representations},
year={2020},
url={https://openreview.net/forum?id=Hyl7ygStwB}
}


## Motivation

- Address the disparity in NMT advancements, which have primarily focused on high-resource languages, leaving behind low-resource languages like Marathi.
- Contribute to the growing body of research on leveraging advanced NMT techniques, particularly those involving contextual word embeddings like BERT, for languages with scarce digital resources.

## Project Overview

The project was carried out in two distinct phases:

### Phase 1: Replication of BERT-Fused NMT for English-German

- Replicated the BERT-Fused NMT model for the English-German language pair, following the methodology outlined in the original paper by Zhu et al. (2020).
- Involved understanding the BERT-Fused NMT architecture, training on various datasets (e.g., IWSLT14), and adapting training settings and hyperparameters.
- Successful replication validated our implementation and paved the way for Phase 2.

### Phase 2: Adaptation for English-Marathi Translation

#### Data Preparation

- **Data Collection**: Sourced from the Samanantar Dataset (AI4Bharat initiative), reduced to 1.1 million high-quality sentence pairs after manual curation.
- **Validation and Testing**: Utilized widely accepted sets like IN22 and FLORES-22 Indic dev set.
- **Preprocessing**: Tailored tokenization, normalization, and BPE for English and Marathi, including data binarization and vocabulary building.

#### Model Architecture and Training

- **Architecture**: `transformer_iwslt_de_en` infused with `bert-base-multilingual-cased`.
- **Hyperparameter Tuning**: Rigorously selected hyperparameters for optimizer, learning rate, and dropout rate.
- **Training Process**: Fine-tuned BERT-Fused NMT model on the English-Marathi parallel corpus, leveraging NVIDIA GPUs.

#### Evaluation

- Standard NMT metrics: BLEU, ROUGE, BERT scores.
- Qualitative analysis of sample translation outputs.

## Results and Analysis

- **BLEU Score Improvement**: BERT-Fused NMT outperformed Vanilla NMT (BLEU 21.03 vs. 20.03).
- **Qualitative Analysis**: BERT-Fused model produced more contextually appropriate translations.
- **Comparative Context**: Higher BLEU score than reported scores for English-Marathi in IndicTrans2 framework.
- **Computational Overhead**: BERT-Fused NMT required extended training time and computational resources.

## Limitations and Future Work

- **Data Availability**: Sourced data from alternative source (http://www.cs.cmu.edu/~pengchey/iwslt2014_ende.zip) due to unavailability of anticipated dataset.
- **Library Compatibility**: Addressed incompatibilities with CUDA and PyTorch versions through targeted modifications.
- **Computational Resources**: Scaled down the amount of training data to manage limited computational resources.
- **Corpus Integrity**: Performed extensive sanity checks and manual curation to ensure data quality.

Future improvements:
- Incorporate language-specific preprocessing steps to address linguistic nuances.
- Explore advanced BPE techniques for better subword representations.
- Employ a larger corpus to enhance training and improve translation quality.

## Installation and Usage

### Requirements

- PyTorch version == 1.5.0
- Python version == 3.6
- huggingface/transformers version == 3.5.0

### Steps

1. Clone the repository:

```bash
git clone https://github.com/bert-nmt/bert-nmt
cd bertnmt
```

2. Install dependencies:

```bash
pip install --editable .
```

3. Preprocess data:

```bash
python preprocess.py --source-lang en --target-lang mr \
                     --trainpref data/train --validpref data/valid --testpref data/test \
                     --destdir processed_data --joined-dictionary --bert-model-name bert-base-uncased
```

4. Train the BERT-Fused NMT model:

```bash
#!/usr/bin/env bash
nvidia-smi
cd /yourpath/bertnmt
python3 -c "import torch; print(torch.__version__)"

src=en
tgt=mr
bedropout=0.5
ARCH=transformer_s2_iwslt_de_en
DATAPATH=/yourdatapath
SAVEDIR=checkpoints/iwed_${src}_${tgt}_${bedropout}
mkdir -p $SAVEDIR

if [ ! -f $SAVEDIR/checkpoint_nmt.pt ]; then
    cp /your_pretrained_nmt_model $SAVEDIR/checkpoint_nmt.pt
fi

# ... (training script continues)
```

5. Generate translations using `generate.py` or `interactive.py` scripts.

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions, please open an issue or submit a pull request.

## References

1. Zhu, J., Xia, Y., Wu, L., He, D., Qin, T., Zhou, W., Li, H., & Liu, T. Y. (2020). Incorporating BERT into Neural Machine Translation. arXiv preprint arXiv:2002.06823.
2. AI4Bharat IndicTrans2 Project: https://github.com/AI4Bharat/IndicTrans2

## Acknowledgments

I express my gratitude to the authors of the original paper, Zhu et al., for their groundbreaking work, and to the AI4Bharat initiative for providing valuable resources for Indian languages.
