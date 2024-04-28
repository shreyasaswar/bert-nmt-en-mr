#!/bin/bash
# Adapted from https://github.com/facebookresearch/MIXER/blob/master/prepareData.sh

echo 'Setting up script directories and variables...'
# Clone repositories for tokenization and BPE scripts - Only if not present
if [ ! -d "mosesdecoder" ]; then
    echo 'Cloning Moses github repository (for tokenization scripts)...'
    git clone https://github.com/moses-smt/mosesdecoder.git
fi

if [ ! -d "subword-nmt" ]; then
    echo 'Cloning Subword NMT repository (for BPE pre-processing)...'
    git clone https://github.com/rsennrich/subword-nmt.git
fi

SCRIPTS=mosesdecoder/scripts
TOKENIZER=$SCRIPTS/tokenizer/tokenizer.perl
CLEAN=$SCRIPTS/training/clean-corpus-n.perl
NORM_PUNC=$SCRIPTS/tokenizer/normalize-punctuation.perl
REM_NON_PRINT_CHAR=$SCRIPTS/tokenizer/remove-non-printing-char.perl
BPEROOT=subword-nmt
BPE_TOKENS=40000

CORPORA=(
    "training/europarl-v7.de-en"
    "commoncrawl.de-en"
    "training/news-commentary-v12.de-en"
)

OUTDIR=wmt17_en_de
src=en
tgt=de
lang=en-de
prep=$OUTDIR
tmp=$prep/tmp
orig=orig
dev=dev/newstest2013

# Ensure directories are present
mkdir -p $orig $tmp $prep

# Directories setup confirmation
echo "Directories set up at $prep, $tmp, and $orig"

# Start processing with locally available data
echo "pre-processing train data..."
for l in $src $tgt; do
    rm $tmp/train.tags.$lang.tok.$l
    for f in "${CORPORA[@]}"; do
        cat $orig/$f.$l | \
            python custom_normalizer.py $l False "do_nothing" | \
            python custom_tokenizer.py | \
            perl $REM_NON_PRINT_CHAR >> $tmp/train.tags.$lang.tok.$l
    done
done

echo "pre-processing test data..."
for l in $src $tgt; do
    if [ "$l" == "$src" ]; then
        t="src"
    else
        t="ref"
    fi
    grep '<seg id' $orig/test-full/newstest2014-deen-$t.$l.sgm | \
        sed -e 's/<seg id="[0-9]*">\s*//g' | \
        sed -e 's/\s*<\/seg>\s*//g' | \
        sed -e "s/\’/\'/g" | \
    python custom_normalizer.py $l False "do_nothing" | \
    python custom_tokenizer.py > $tmp/test.$l
    echo ""
done



echo "splitting train and valid..."
for l in $src $tgt; do
    awk '{if (NR%100 == 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/valid.$l
    awk '{if (NR%100 != 0)  print $0; }' $tmp/train.tags.$lang.tok.$l > $tmp/train.$l
done

echo "Scripts setup completed."

echo "learn_bpe.py on individual language files..."
for l in $src $tgt; do
    BPE_CODE=$prep/code.$l
    echo "Learning BPE for $l..."
    python $BPEROOT/learn_bpe.py -s $BPE_TOKENS < $tmp/train.$l > $BPE_CODE

    echo "Applying BPE to $l..."
    for f in train.$l valid.$l test.$l; do
        echo "apply_bpe.py to ${f}..."
        python $BPEROOT/apply_bpe.py -c $BPE_CODE < $tmp/$f > $tmp/bpe.$f
    done
done

echo "Cleaning and preparing final training and validation data sets for each language..."
for l in $src $tgt; do
    # Clean and prepare training and validation datasets
    perl $CLEAN -ratio 1.5 $tmp/bpe.train.$l $src $tgt $prep/train.$l 1 250
    perl $CLEAN -ratio 1.5 $tmp/bpe.valid.$l $src $tgt $prep/valid.$l 1 250

    # Copy all processed files to the output directory
    cp $tmp/bpe.train.$l $prep/train.$l
    cp $tmp/bpe.valid.$l $prep/valid.$l
    cp $tmp/bpe.test.$l $prep/test.$l
done

# Optional: Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf $tmp

echo "All processing complete. Output files are located in $prep"

