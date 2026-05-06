import os
import json
from datetime import datetime

def read_json_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return json.load(file)
    except Exception as e:
        print(f"Error reading JSON file {file_path}: {e}")
        return None

def write_json_file(data, file_path):
    try:
        with open(file_path, 'w') as file:
            json.dump(data, file, indent=4)
    except Exception as e:
        print(f"Error writing to JSON file {file_path}: {e}")

def get_timestamp():
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')

def create_directory(directory):
    try:
        os.makedirs(directory, exist_ok=True)
    except OSError as e:
        print(f"Error creating directory {directory}: {e}")

def remove_file(file_path):
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
    except OSError as e:
        print(f"Error removing file {file_path}: {e}")

def list_files_in_directory(directory):
    try:
        return [f for f in os.listdir(directory) if os.path.isfile(os.path.join(directory, f))]
    except Exception as e:
        print(f"Error listing files in directory {directory}: {e}")
        return []

def file_exists(file_path):
    return os.path.exists(file_path)

def get_file_size(file_path):
    try:
        return os.path.getsize(file_path)
    except OSError as e:
        print(f"Error getting file size for {file_path}: {e}")
        return None

def copy_file(source, destination):
    try:
        with open(source, 'rb') as src_file:
            with open(destination, 'wb') as dst_file:
                dst_file.write(src_file.read())
    except Exception as e:
        print(f"Error copying file from {source} to {destination}: {e}")

def move_file(source, destination):
    try:
        os.rename(source, destination)
    except OSError as e:
        print(f"Error moving file from {source} to {destination}: {e}")

def get_environment_variable(var_name):
    return os.getenv(var_name)

def set_environment_variable(var_name, var_value):
    os.environ[var_name] = var_value

def delete_environment_variable(var_name):
    if var_name in os.environ:
        del os.environ[var_name]

def read_text_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except Exception as e:
        print(f"Error reading text file {file_path}: {e}")
        return None

def write_text_file(data, file_path):
    try:
        with open(file_path, 'w') as file:
            file.write(data)
    except Exception as e:
        print(f"Error writing to text file {file_path}: {e}")

def append_to_text_file(data, file_path):
    try:
        with open(file_path, 'a') as file:
            file.write(data)
    except Exception as e:
        print(f"Error appending to text file {file_path}: {e}")

def get_current_working_directory():
    return os.getcwd()

def change_working_directory(new_directory):
    try:
        os.chdir(new_directory)
    except OSError as e:
        print(f"Error changing working directory to {new_directory}: {e}")

def list_directories_in_directory(directory):
    try:
        return [d for d in os.listdir(directory) if os.path.isdir(os.path.join(directory, d))]
    except Exception as e:
        print(f"Error listing directories in directory {directory}: {e}")
        return []

def get_file_extension(file_path):
    try:
        _, ext = os.path.splitext(file_path)
        return ext
    except Exception as e:
        print(f"Error getting file extension for {file_path}: {e}")
        return None

def rename_file(old_name, new_name):
    try:
        os.rename(old_name, new_name)
    except OSError as e:
        print(f"Error renaming file from {old_name} to {new_name}: {e}")

def is_directory_empty(directory):
    try:
        return len(os.listdir(directory)) == 0
    except Exception as e:
        print(f"Error checking if directory {directory} is empty: {e}")
        return None

def get_file_modification_time(file_path):
    try:
        return datetime.fromtimestamp(os.path.getmtime(file_path)).strftime('%Y-%m-%d %H:%M:%S')
    except OSError as e:
        print(f"Error getting modification time for {file_path}: {e}")
        return None

def get_file_creation_time(file_path):
    try:
        # Note: os.path.getctime() returns the creation time on Windows and the last metadata change time on Unix
        return datetime.fromtimestamp(os.path.getctime(file_path)).strftime('%Y-%m-%d %H:%M:%S')
    except OSError as e:
        print(f"Error getting creation time for {file_path}: {e}")
        return None

def get_file_access_time(file_path):
    try:
        return datetime.fromtimestamp(os.path.getatime(file_path)).strftime('%Y-%m-%d %H:%M:%S')
    except OSError as e:
        print(f"Error getting access time for {file_path}: {e}")
        return None

def is_directory(directory):
    return os.path.isdir(directory)

def is_file(file_path):
    return os.path.isfile(file_path)
