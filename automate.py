import os
import yaml

# Specify the directory where your Markdown files are located
project_directory = "/Users/jamsimox/Work/Repos/aws-iot-fleetwise-evbatterymonitoring/docs"

# Create a dictionary to store navigation entries
nav_entries = {}

# Function to generate navigation entries recursively
def generate_nav_entries(directory, parent_path=""):
    for entry in os.listdir(directory):
        entry_path = os.path.join(directory, entry)
        
        if os.path.isdir(entry_path):
            # Recursively process subdirectories
            folder_name = entry
            if parent_path:
                folder_name = os.path.join(parent_path, folder_name)
            generate_nav_entries(entry_path, folder_name)
        elif entry.endswith(".md"):
            # Add Markdown files to navigation
            entry_name = entry[:-3]  # Remove ".md" extension
            if parent_path:
                entry_name = os.path.join(parent_path, entry_name)
            nav_entries[entry_name] = entry_path

# Start generating navigation entries from the project directory
generate_nav_entries(project_directory)

# Create the mkdocs.yml content
mkdocs_yaml = {
    "site_name": "CMS Technical Docs",
    "theme": "readthedocs",
    "nav": nav_entries
}

# Write the mkdocs.yml file in YAML format
with open("mkdocs.yml", "w") as mkdocs_file:
    yaml.dump(mkdocs_yaml, mkdocs_file, default_flow_style=False)

print("mkdocs.yml has been generated with organized navigation entries and theme settings.")
