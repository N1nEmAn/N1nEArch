#!/bin/bash

# Define temporary file paths
TEMP_IMG="/tmp/flameshot_ocr_temp.png"
TEMP_IMG_PROCESSED="/tmp/flameshot_ocr_temp_processed.png" # Processed temporary image
TEMP_TXT="/tmp/flameshot_ocr_result.txt"

# 1. Use Flameshot to capture screenshot and save to a temporary file
flameshot gui -p "$TEMP_IMG"

# Check if screenshot was saved successfully
if [ ! -f "$TEMP_IMG" ]; then
  notify-send "Screenshot failed" "Flameshot could not save the screenshot file."
  exit 1
fi

# 2. Image pre-processing (using ImageMagick)
# IMPORTANT: Use 'magick' instead of 'convert' for ImageMagick v7+
# Grayscale -> Normalize contrast -> Binarize -> Deskew
magick "$TEMP_IMG" \
  -colorspace Gray \
  -normalize \
  -threshold 60% \
  -deskew 40% \
  "$TEMP_IMG_PROCESSED"

# Check if the processed image was generated
if [ ! -f "$TEMP_IMG_PROCESSED" ]; then
  notify-send "Image processing failed" "ImageMagick could not process the image."
  rm -f "$TEMP_IMG"
  exit 1
fi

# 3. Use Tesseract for OCR
# -l chi_sim+eng to recognize both Chinese and English
# --psm 3 for automatic page segmentation mode
# --oem 1 to prioritize LSTM neural network engine
tesseract "$TEMP_IMG_PROCESSED" "$TEMP_TXT" -l chi_sim+eng --psm 3 --oem 1

# Check if OCR was successful
if [ ! -f "$TEMP_TXT".txt ]; then
  notify-send "OCR failed" "Tesseract could not generate the text file. Check screenshot content or Tesseract installation."
  rm -f "$TEMP_IMG" "$TEMP_IMG_PROCESSED"
  exit 1
fi

# 4. Post-process OCR result and copy to clipboard
# 4.1. Read raw text from the OCR result file
OCR_RAW_TEXT=$(cat "$TEMP_TXT".txt)

# 4.2. Clean up text:
#    - First, replace all newlines with spaces.
#    - Then, replace multiple consecutive whitespace characters with a single space.
#    - Next, pass the processed text to Perl for multi-pass cleaning:
#      a. Unify full-width/half-width punctuation.
#      b. Normalize punctuation based on context (Chinese vs. English characters).
#      c. Remove all spaces within Chinese text segments.
#      d. Remove leading/trailing spaces.
CLEANED_TEXT=$(
  echo "$OCR_RAW_TEXT" |
    tr '\n' ' ' |
    sed 's/\s\s*/ /g' |
    perl -CSDA -Mutf8 -pe '
        # --- Perl code starts here ---

        # Punctuation full-width/half-width unification and preliminary normalization
        s/\(\s*/（/g; s/\s*\)/）/g; # Parentheses
        s/\<\s*/《/g; s/\s*\>/》/g; # Guarantees
        s/\.\.\./…/g;               # Ellipsis
        s/:/：/g; s/;/；/g; s/,/，/g; # Colon, semicolon, comma
        s/!/！/g; s/\?/？/g;          # Exclamation mark, question mark (FIXED)
        s/”/"/g; s/“/"/g;           # Double quotes
        s/\’/'\''/g; # Smart single quotes, right (FIXED)
        s/\‘/'\''/g; # Smart single quotes, left (FIXED)
        s/—/-/g; s/——/--/g; # Dashes

        # Chinese text segment internal space removal
        # Core logic: Match any continuous block of Chinese characters, Chinese punctuation, and whitespace,
        # and remove all whitespace within that block.
        s{ ([\x{4E00}-\x{9FFF}，。？！、；：“”‘’《》【】（）\s]+) }{
            my $chunk = $1;
            $chunk =~ s/\s//g;
            $chunk;
        }gex;

        # English/Numeric punctuation normalization (ensure English uses English punctuation, Chinese uses Chinese)
        # Match English/numeric followed by Chinese punctuation, attempt to convert to English punctuation
        s{([a-zA-Z0-9]+)([，。？！、；：“”‘’《》【】（）])}{
            my ($word, $punc) = ($1, $2);
            $punc = "," if $punc eq "，";
            $punc = "." if $punc eq "。";
            $punc = "!" if $punc eq "！";
            $punc = "?" if $punc eq "？";
            $punc = ";" if $punc eq "；";
            $punc = ":" if $punc eq "：";
            $punc = "(" if $punc eq "（";
            $punc = ")" if $punc eq "）";
            $punc = "[" if $punc eq "【";
            $punc = "]" if $punc eq "】";
            $punc = "<" if $punc eq "《";
            $punc = ">" if $punc eq "》";
            $word . $punc;
        }gex;

        # Match Chinese followed by English punctuation, attempt to convert to Chinese punctuation
        s{([\x{4E00}-\x{9FFF}]+)([,.;:?!()])}{
            my ($word, $punc) = ($1, $2);
            $punc = "，" if $punc eq ",";
            $punc = "。" if $punc eq ".";
            $punc = "！" if $punc eq "!";
            $punc = "？" if $punc eq "?";
            $punc = "；" if $punc eq ";";
            $punc = "：" if $punc eq ":";
            $punc = "（" if $punc eq "(";
            $punc = "）" if $punc eq ")";
            $word . $punc;
        }gex;

        # Remove leading and trailing whitespace
        s/^\s+//;
        s/\s+$//;

        # --- Perl code ends here ---
    ' # The Perl script is passed as a single string to -pe
)

# 4.3. Copy the cleaned text to the system clipboard
echo "$CLEANED_TEXT" | xclip -selection clipboard

# 5. Optional: Send a notification to the user that OCR is complete and copied to clipboard
# Extract the first 10 characters for preview; if text is shorter, show all.
TEXT_PREVIEW="${CLEANED_TEXT:0:20}"
notify-send "OCR complete!" "Screenshot text copied to clipboard!\nPreview: ${TEXT_PREVIEW}"

# 6. Clean up temporary files
rm -f "$TEMP_IMG" "$TEMP_IMG_PROCESSED" "$TEMP_TXT".txt

exit 0
