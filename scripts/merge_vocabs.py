import sys

def load_vocab(file_path):
    """Loads a vocabulary file into a dictionary."""
    vocab = {}
    with open(file_path, 'r', encoding='utf-8', errors="replace") as f:
        for line in f:
            word, freq = line.strip("\n").rsplit(" ", maxsplit=1)
            if word in vocab:
                print(word)
            vocab[word] = int(freq)
    return vocab

def merge_vocab(reference_path, focus_path, merged_path):
    """Merges vocabularies by replacing reference frequencies with focus frequencies."""
    # Load reference and focus vocabularies
    reference_vocab = load_vocab(reference_path)
    focus_vocab = load_vocab(focus_path)
    
    # Create the merged vocabulary
    merged_vocab = {}
    for word in reference_vocab:
        # Replace frequency with focus_vocab frequency, or set to 0 if not found
        merged_vocab[word] = focus_vocab.get(word, 0)
    
    # Check if dicts are identical

    len_merged = len(merged_vocab)
    len_reference = len(reference_vocab)

    if len_reference != len_merged:
        print(f"Length of reference ({len_reference}) and merged ({len_merged}) vocab are not identical.")
        for word, freq in reference_vocab.items():
            if word not in merged_vocab:
                print(f"{word} is missing in merged vocab!")


    # Save the merged vocabulary to the output file
    with open(merged_path, 'w', encoding='utf-8') as f:
        for word, freq in merged_vocab.items():
            f.write(f"{word} {freq}\n")

if __name__ == "__main__":
    # Example usage:
    # python script.py reference_vocab.txt focus_vocab.txt merged_vocab.txt
    
    if len(sys.argv) != 4:
        print("Usage: python script.py <reference_vocab> <focus_vocab> <merged_vocab>")
        sys.exit(1)
    
    reference_vocab_path = sys.argv[1]
    focus_vocab_path = sys.argv[2]
    merged_vocab_path = sys.argv[3]
    
    merge_vocab(reference_vocab_path, focus_vocab_path, merged_vocab_path)