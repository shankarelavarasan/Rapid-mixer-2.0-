import os
import subprocess
from flask import Flask, request, jsonify, send_from_directory
from werkzeug.utils import secure_filename
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configuration
UPLOAD_FOLDER = 'uploads'
SEPARATED_FOLDER = 'separated'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['SEPARATED_FOLDER'] = SEPARATED_FOLDER

# Create directories if they don't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)
if not os.path.exists(SEPARATED_FOLDER):
    os.makedirs(SEPARATED_FOLDER)

@app.route('/split-audio', methods=['POST'])
def split_audio():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    if file:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # Use Demucs to separate stems
        model = "htdemucs"
        output_dir = os.path.join(app.config['SEPARATED_FOLDER'])
        
        command = [
            "python", "-m", "demucs",
            "--out", output_dir,
            "--name", model,
            filepath
        ]
        
        try:
            result = subprocess.run(command, check=True, capture_output=True, text=True)
            print(f"Demucs output: {result.stdout}")
        except subprocess.CalledProcessError as e:
            print(f"Error during stem separation: {e.stderr}")
            return jsonify({'error': 'Failed to process audio file', 'details': str(e)}), 500

        # Construct stem URLs
        base_url = request.host_url
        file_basename = os.path.splitext(filename)[0]
        stems_path = os.path.join(model, file_basename)
        
        stems = {}
        stem_files_path = os.path.join(output_dir, model, file_basename)

        if not os.path.exists(stem_files_path):
             return jsonify({'error': 'Separated files not found. Demucs might have failed.'}), 500

        for stem_file in os.listdir(stem_files_path):
            stem_name = os.path.splitext(stem_file)[0]
            stems[stem_name] = f'{base_url}separated/{model}/{file_basename}/{stem_file}'

        return jsonify(stems)

@app.route('/separated/<path:path>')
def send_separated(path):
    # The path from the URL will be e.g. htdemucs/filename/vocals.wav
    # We need to construct the full path to the file.
    # The 'separated' directory is the base.
    return send_from_directory(app.config['SEPARATED_FOLDER'], path)

@app.route('/health')
def health_check():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'uploads_dir_exists': os.path.exists(app.config['UPLOAD_FOLDER']),
        'separated_dir_exists': os.path.exists(app.config['SEPARATED_FOLDER'])
    })

@app.route('/test-demucs')
def test_demucs():
    """Test if Demucs is properly installed and accessible"""
    try:
        result = subprocess.run(['python', '-m', 'demucs', '--help'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            return jsonify({'status': 'Demucs is available'})
        else:
            return jsonify({'error': 'Demucs not working', 'details': result.stderr}), 500
    except Exception as e:
        return jsonify({'error': 'Demucs not found or not working', 'details': str(e)}), 500

@app.errorhandler(413)
def too_large(e):
    return jsonify({'error': 'File too large. Maximum file size is 16MB.'}), 413

@app.errorhandler(500)
def server_error(e):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    # For production deployment
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('DEBUG', 'False').lower() == 'true'
    app.run(host='0.0.0.0', port=port, debug=debug)