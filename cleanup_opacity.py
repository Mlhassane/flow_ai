import os
import re

lib_dir = r"e:\perso\flutter\flow\lib"

# Fonction pour corriger les withOpacity -> withValues(alpha: ...)
def replace_opacity():
    for root, dirs, files in os.walk(lib_dir):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                # Update withOpacity
                new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
                
                # Update prints to debugPrint
                if re.search(r'\bprint\(', new_content):
                    new_content = re.sub(r'\bprint\(', r'debugPrint(', new_content)
                    if 'import \'package:flutter/foundation.dart\';' not in new_content and 'import \'package:flutter/material.dart\';' not in new_content:
                        # Append the import at the top of the file
                        new_content = "import 'package:flutter/foundation.dart';\n" + new_content
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as file:
                        file.write(new_content)
                    print(f"Updated {f}")

replace_opacity()
print("Cleanup complete.")
